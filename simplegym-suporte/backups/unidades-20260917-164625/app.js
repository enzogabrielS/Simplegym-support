const XP_PER_WORKOUT = 60;
const scriptSource = document.currentScript?.src || new URL('assets/js/app.js', document.baseURI).href;

const WEEK_DAYS = [
  { key: 'domingo', label: 'Dom', short: 'D' },
  { key: 'segunda', label: 'Seg', short: 'S' },
  { key: 'terca', label: 'Ter', short: 'T' },
  { key: 'quarta', label: 'Qua', short: 'Q' },
  { key: 'quinta', label: 'Qui', short: 'Q' },
  { key: 'sexta', label: 'Sex', short: 'S' },
  { key: 'sabado', label: 'Sáb', short: 'S' }
];

const DEFAULT_SCHEDULE = {
  domingo: [], segunda: [], terca: [], quarta: [], quinta: [], sexta: [], sabado: []
};

function clone(value) { return structuredClone(value); }
function escapeHTML(value = '') { return String(value).replace(/[&<>'"]/g, character => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#039;', '"': '&quot;' }[character])); }
function titleCase(value) { return value ? `${value.charAt(0).toUpperCase()}${value.slice(1)}` : ''; }
function deviceDate() { return new Date(); }
function todayKey() { return WEEK_DAYS[deviceDate().getDay()].key; }
function todayDateKey() {
  return localDateKey(deviceDate());
}
function localDateKey(date) {
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  return localDate.toISOString().slice(0, 10);
}
function dateKeyOffset(offset) {
  const date = deviceDate();
  date.setDate(date.getDate() + offset);
  return localDateKey(date);
}
function getDay(key) { return WEEK_DAYS.find(day => day.key === key); }

const state = {
  exercises: [],
  muscleGroups: [],
  levels: [],
  customExercises: [],
  exerciseDefaults: {},
  user: null,
  planDraft: null,
  customExerciseReturn: 'plan',
  plans: [],
  schedule: clone(DEFAULT_SCHEDULE),
  streak: 0, xp: 0, totalWorkouts: 0, activityMinutes: 0,
  completedDates: {}, freeDayCheckins: {}, theme: 'dark',
  selectedDay: todayKey(),
  session: null
};

const modalBackdrop = document.getElementById('modal-backdrop');
const modalContent = document.getElementById('modal-content');
const toast = document.getElementById('toast');
let toastTimer;
let lastModalTrigger = null;
let libraryConfigDraft = null;
let dataVersion = 0;
let ready = false;
let saveQueue = Promise.resolve(true);
let latestSnapshot = '';
let needsSave = false;
let saveConflict = false;

function refreshIcons() { if (window.lucide) window.lucide.createIcons(); }
async function saveWithButton(button, callback) {
  if (button.disabled) return;
  button.disabled = true;
  button.setAttribute('aria-busy', 'true');
  try { await callback(); }
  finally { button.disabled = false; button.removeAttribute('aria-busy'); }
}
function saveState() {
  if (!ready) return Promise.resolve(false);
  const snapshot = JSON.stringify({
    plans: state.plans, schedule: state.schedule, streak: state.streak, xp: state.xp,
    totalWorkouts: state.totalWorkouts, completedDates: state.completedDates, freeDayCheckins: state.freeDayCheckins,
    activityMinutes: state.activityMinutes, theme: state.theme,
    customExercises: state.customExercises, exerciseDefaults: state.exerciseDefaults, session: state.session
  });
  latestSnapshot = snapshot;
  needsSave = true;
  const status = document.getElementById('save-status');
  saveQueue = saveQueue.then(async () => {
    if (saveConflict) return false;
    status.hidden = false;
    status.querySelector('span').textContent = 'Salvando…';
    status.querySelector('button').hidden = true;
    try {
      const result = await SimpleGymAPI.request('dados.php', { state: JSON.parse(snapshot), version: dataVersion });
      dataVersion = result.version;
      if (snapshot === latestSnapshot) { needsSave = false; status.hidden = true; }
      return true;
    } catch (error) {
      saveConflict = error.status === 409;
      status.querySelector('span').textContent = error.status === 401
        ? 'Sua sessão expirou. Entre novamente para continuar.'
        : error.message || 'Falha ao salvar. Confira a conexão.';
      const button = status.querySelector('button');
      button.hidden = false;
      button.dataset.action = saveConflict || error.status === 401 ? 'reload-app' : 'retry-save';
      button.textContent = saveConflict || error.status === 401 ? 'Recarregar' : 'Tentar novamente';
      return false;
    }
  });
  return saveQueue;
}
async function logout() {
  if (state.session && !state.session.paused) pauseSession();
  if (!(await saveQueue) || needsSave) {
    if (!(await saveState())) { showToast('Aguarde o salvamento dos seus dados antes de sair.'); return; }
  }
  try {
    await SimpleGymAPI.request('sair.php', {});
    ready = false;
    state.user = null;
    window.location.replace(new URL('../../auth/login.php', scriptSource).href);
  } catch (error) { showToast(error.message); }
}
function getPlan(id) { return state.plans.find(plan => plan.id === id); }
function getExercise(id) { return state.exercises.find(exercise => exercise.id === id); }
function getMuscleGroup(id) { return state.muscleGroups.find(group => group.id === id); }
function getExerciseGroupIds(exercise) {
  return exercise?.muscleGroups || [];
}
function getExerciseGroupNames(exercise) {
  const groupIds = getExerciseGroupIds(exercise);
  return groupIds.map(getMuscleGroup).filter(Boolean).map(group => group.name);
}
function isValidExercise(exercise) {
  return Boolean(
    exercise &&
    typeof exercise.id === 'string' &&
    typeof exercise.name === 'string' &&
    typeof exercise.photo === 'string' &&
    typeof exercise.description === 'string' &&
    typeof exercise.howTo === 'string' &&
    Array.isArray(exercise.muscleGroups) &&
    Array.isArray(exercise.muscles)
  );
}
function isValidMuscleGroup(group) {
  return Boolean(group && typeof group.id === 'string' && typeof group.name === 'string');
}
function isValidLevel(level) {
  return Boolean(
    level &&
    Number.isInteger(level.level) &&
    Number.isFinite(level.minXp) &&
    typeof level.title === 'string' &&
    typeof level.description === 'string'
  );
}
function getLevelForXp(xp) {
  return [...state.levels].sort((a, b) => a.minXp - b.minXp).filter(level => level.minXp <= xp).at(-1) || state.levels[0];
}
function getNextLevel(level) {
  return [...state.levels].sort((a, b) => a.minXp - b.minXp).find(item => item.minXp > level.minXp);
}
function formatActivity(minutes) {
  if (minutes > 0 && minutes < 1) return '<1min';
  const value = Math.max(0, Math.round(Number(minutes) || 0));
  const hours = Math.floor(value / 60);
  const remainingMinutes = value % 60;
  if (hours && remainingMinutes) return `${hours}h ${remainingMinutes}min`;
  if (hours) return `${hours}h`;
  return `${remainingMinutes}min`;
}
function calculateCurrentStreak() {
  if (!Object.keys(state.completedDates).length) return state.streak;
  let offset = state.completedDates[todayDateKey()] ? 0 : -1;
  let streak = 0;
  while (state.completedDates[dateKeyOffset(offset)]) {
    streak += 1;
    offset -= 1;
  }
  return streak;
}
function syncStreak() {
  if (Object.keys(state.completedDates).length) state.streak = calculateCurrentStreak();
}
function themeLabel(theme) {
  return ({ dark: 'Tema escuro', light: 'Tema claro', violet: 'Tema violeta' })[theme] || 'Tema escuro';
}
function plansForDay(dayKey) { return (state.schedule[dayKey] || []).map(getPlan).filter(Boolean); }
function exercisesForPlans(plans) {
  return plans.flatMap(plan => plan.exercises.map((config, index) => ({ planId: plan.id, planName: plan.name, index, config, exercise: getExercise(config.exerciseId) })).filter(item => item.exercise));
}
function weightText(config) { return config.weight > 0 ? `${config.weight} kg` : 'peso corporal'; }
function isCardioExercise(exerciseId) { return getExercise(exerciseId)?.type === 'cardio'; }
function repetitionUnit(exerciseId, full = false) {
  if (isCardioExercise(exerciseId)) return full ? 'minutos' : 'min';
  if (exerciseId === 'prancha') return full ? 'segundos' : 'seg';
  return full ? 'repetições' : 'rep.';
}
function configSummary(config) {
  const weight = isCardioExercise(config.exerciseId) ? '' : ` · ${weightText(config)}`;
  return `${config.sets} séries · ${config.reps} ${repetitionUnit(config.exerciseId)}${weight}`;
}
function defaultExerciseConfig(exerciseId) {
  if (state.exerciseDefaults[exerciseId]) return clone(state.exerciseDefaults[exerciseId]);
  if (isCardioExercise(exerciseId)) return { exerciseId, sets: 1, reps: 20, weight: 0 };
  if (exerciseId === 'prancha') return { exerciseId, sets: 3, reps: 30, weight: 0 };
  return { exerciseId, sets: 3, reps: 12, weight: 0 };
}
function configurationControls(config, action = 'change-config', attributes = '') {
  const timed = isCardioExercise(config.exerciseId) || config.exerciseId === 'prancha';
  const fields = [['sets', 'Séries', config.sets, ''], ['reps', timed ? 'Duração' : 'Repetições', config.reps, ` ${repetitionUnit(config.exerciseId)}`]];
  if (!isCardioExercise(config.exerciseId)) fields.push(['weight', 'Carga', config.weight, ' kg']);
  return `<div class="config-grid">${fields.map(([field, label, value, suffix]) => {
    const button = delta => `<button type="button" data-action="${action}" ${attributes} data-field="${field}" data-delta="${delta}" aria-label="${delta < 0 ? 'Diminuir' : 'Aumentar'} ${label} em ${Math.abs(delta)}">${field === 'weight' ? (delta > 0 ? '+' : '−') + Math.abs(delta) : `<i data-lucide="${delta < 0 ? 'minus' : 'plus'}"></i>`}</button>`;
    return `<div class="config-card ${field === 'weight' ? 'weight-config' : ''}"><small>${label}</small><div class="config-control">${field === 'weight' ? button(-5) : ''}${button(-1)}<strong data-config-value="${field}" data-suffix="${suffix}">${value}${suffix}</strong>${button(1)}${field === 'weight' ? button(5) : ''}</div></div>`;
  }).join('')}</div>`;
}
function adjustConfig(config, field, delta) {
  if (!['sets', 'reps', 'weight'].includes(field) || ![-5, -1, 1, 5].includes(Number(delta))) return;
  const min = field === 'weight' ? 0 : 1;
  const max = field === 'sets' ? 100 : 10000;
  config[field] = Math.min(max, Math.max(min, Math.round((Number(config[field]) + Number(delta)) * 100) / 100));
  const value = modalContent.querySelector(`[data-config-value="${field}"]`);
  if (value) value.textContent = config[field] + value.dataset.suffix;
}
function isCustomExercise(exerciseId) { return state.customExercises.some(exercise => exercise.id === exerciseId); }
function planLetter(index) { return String.fromCharCode(65 + (index % 26)); }

function showToast(message) {
  toast.querySelector('span').textContent = message;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 2800);
}
function openModal(markup, options = {}) {
  const modal = document.getElementById('modal');
  const wasOpen = modalBackdrop.classList.contains('open');
  const previousScroll = modal.scrollTop;
  if (!wasOpen) {
    const activeElement = document.activeElement;
    lastModalTrigger = activeElement instanceof HTMLElement ? activeElement : null;
  }
  modalContent.innerHTML = markup;
  delete modalContent.dataset.savingId;
  modalBackdrop.classList.add('open');
  modalBackdrop.setAttribute('aria-hidden', 'false');
  modal.scrollTop = options.preserveScroll ? previousScroll : 0;
  refreshIcons();
  if (!wasOpen) requestAnimationFrame(() => modalBackdrop.querySelector('.modal-close')?.focus());
}
function closeModal() {
  // Mova o foco para fora do modal antes de escondê-lo dos leitores de tela.
  if (lastModalTrigger && document.contains(lastModalTrigger)) lastModalTrigger.focus();
  modalBackdrop.classList.remove('open');
  modalBackdrop.setAttribute('aria-hidden', 'true');
  lastModalTrigger = null;
}

function renderHome() {
  const selected = state.selectedDay;
  const today = todayKey();
  const selectedPlans = plansForDay(selected);
  const entries = exercisesForPlans(selectedPlans);
  document.getElementById('date-label').textContent = new Intl.DateTimeFormat('pt-BR', { weekday: 'long', day: 'numeric', month: 'long' }).format(new Date()).toUpperCase();
  document.getElementById('streak-number').textContent = state.streak;
  document.getElementById('xp-number').textContent = state.xp;
  document.getElementById('week-days').innerHTML = WEEK_DAYS.map(day => {
    const active = day.key === selected ? 'selected' : '';
    const scheduled = (state.schedule[day.key] || []).length ? 'scheduled' : '';
    return `<button class="week-day ${active} ${scheduled}" data-action="select-day" data-day="${day.key}" aria-label="Ver treino de ${day.label}"><span>${day.short}</span><strong>${day.label.slice(-1) === 'm' ? 'D' : day.label.slice(0, 1)}</strong><i></i></button>`;
  }).join('');
  const dayLabel = titleCase(getDay(selected).label);
  document.getElementById('day-context').textContent = selectedPlans.length ? `${dayLabel}: ${selectedPlans.map(plan => plan.name).join(' + ')}` : `${dayLabel}: dia livre`;
  document.getElementById('today-list').innerHTML = entries.slice(0, 4).map(item => `
    <article class="exercise-card">
      <div class="exercise-thumb"><img src="${escapeHTML(item.exercise.photo)}" alt="Exemplo de ${escapeHTML(item.exercise.name)}" /></div>
      <div><h3>${escapeHTML(item.exercise.name)}</h3><p>${escapeHTML(item.planName)}</p><small><i data-lucide="layers-3"></i>${configSummary(item.config)}</small></div>
      <button class="exercise-info" data-action="open-exercise" data-plan-id="${item.planId}" data-index="${item.index}" aria-label="Ver detalhes de ${escapeHTML(item.exercise.name)}"><i data-lucide="info"></i></button>
    </article>`).join('');
  const emptyWorkout = document.getElementById('empty-workout');
  const isFreeDay = entries.length === 0;
  const canCheckIn = selected === today;
  const checkedIn = Boolean(state.freeDayCheckins[todayDateKey()]) && canCheckIn;
  emptyWorkout.hidden = !isFreeDay;
  if (isFreeDay) {
    emptyWorkout.innerHTML = canCheckIn
      ? `<i data-lucide="${checkedIn ? 'circle-check-big' : 'calendar-heart'}"></i><strong>${checkedIn ? 'Check-in de dia livre realizado' : 'Hoje é um dia livre'}</strong><p>${checkedIn ? 'Sua pausa foi registrada. Volte quando estiver pronto para o próximo treino.' : 'Que tal um cardio hoje? Uma caminhada leve também conta como movimento.'}</p>`
      : '<i data-lucide="calendar-plus"></i><strong>Nenhum treino para este dia</strong><p>Organize os grupos musculares na sua agenda semanal.</p><button class="outline-button" data-action="open-schedule">Organizar agenda</button>';
  }
  const startButton = document.getElementById('home-start');
  const pausedSession = state.session && state.session.paused;
  const finishedToday = Boolean(state.completedDates[todayDateKey()]) && selected === today;
  const isCurrentDay = selected === today;
  const canCheckInToday = isFreeDay && isCurrentDay && !checkedIn;
  startButton.disabled = (!entries.length && !canCheckInToday) || finishedToday || !isCurrentDay;
  startButton.classList.toggle('paused', pausedSession);
  if (!isCurrentDay) startButton.innerHTML = '<i data-lucide="x"></i> Disponível apenas no dia';
  else if (isFreeDay && checkedIn) startButton.innerHTML = '<i data-lucide="check"></i> Check-in realizado';
  else if (isFreeDay) startButton.innerHTML = '<i data-lucide="calendar-check-2"></i> Fazer check-in de dia livre';
  else if (pausedSession) startButton.innerHTML = '<i data-lucide="play"></i> Retomar treino';
  else if (finishedToday) startButton.innerHTML = '<i data-lucide="check"></i> Treino concluído';
  else startButton.innerHTML = '<i data-lucide="play"></i> Iniciar treino';
  refreshIcons();
}

function renderProfile() {
  const name = state.user?.nome || 'Meu perfil';
  const initials = name.split(/\s+/).slice(0, 2).map(part => part[0]).join('').toUpperCase();
  document.querySelector('.profile-hero h2').textContent = name;
  document.querySelector('.profile-avatar').textContent = initials;
  document.querySelector('.avatar-button').textContent = initials;
  const level = getLevelForXp(state.xp);
  const nextLevel = getNextLevel(level);
  const progress = nextLevel
    ? Math.min(100, Math.max(0, ((state.xp - level.minXp) / (nextLevel.minXp - level.minXp)) * 100))
    : 100;

  document.getElementById('profile-level').textContent = `Nível ${level.level} · ${level.title}`;
  document.getElementById('profile-level-description').textContent = level.description;
  document.getElementById('profile-level-progress').style.width = `${progress}%`;
  document.getElementById('profile-xp').textContent = state.xp;
  document.getElementById('profile-next-xp').textContent = nextLevel ? nextLevel.minXp : state.xp;
  document.getElementById('profile-xp-copy').textContent = nextLevel
    ? `XP para o nível ${nextLevel.level}`
    : 'nível máximo alcançado';
  document.getElementById('profile-streak').textContent = state.streak;
  document.getElementById('profile-workouts').textContent = state.totalWorkouts;
  document.getElementById('profile-activity').textContent = formatActivity(state.activityMinutes);
  document.getElementById('appearance-current').textContent = themeLabel(state.theme);
}

function renderPlans() {
  document.getElementById('plans-count').textContent = `${state.plans.length} ${state.plans.length === 1 ? 'treino salvo' : 'treinos salvos'}`;
  document.getElementById('saved-plans').innerHTML = state.plans.map((plan, index) => `
    <button class="plan-card" data-action="view-plan" data-plan-id="${plan.id}">
      <span class="plan-letter">${planLetter(index)}</span>
      <span><p>${escapeHTML(plan.groups.join(' · ').toUpperCase())}</p><h3>${escapeHTML(plan.name)}</h3><small>${plan.exercises.length} exercícios · editável</small></span>
      <i data-lucide="chevron-right"></i>
    </button>`).join('');
  const savedExerciseEntries = state.plans.flatMap(plan => plan.exercises.map((config, index) => ({ plan, config, index, exercise: getExercise(config.exerciseId) })).filter(item => item.exercise));
  const usedExerciseIds = new Set(savedExerciseEntries.map(item => item.exercise.id));
  state.exercises.filter(exercise => !usedExerciseIds.has(exercise.id)).forEach(exercise => savedExerciseEntries.push({ plan: null, config: null, index: -1, exercise }));
  const exerciseLibrary = state.muscleGroups.map(group => {
    const entries = savedExerciseEntries.filter(item => getExerciseGroupIds(item.exercise).includes(group.id));
    if (!entries.length) return '';
    return `<section class="exercise-group library-group"><div class="exercise-group-heading"><strong>${escapeHTML(group.name)}</strong><span>${entries.length} ${entries.length === 1 ? 'exercício' : 'exercícios'}</span></div><div class="saved-exercises">${entries.map(item => `
      <button class="saved-exercise-card" data-action="edit-saved-exercise" data-plan-id="${item.plan?.id || ''}" data-index="${item.index}" data-exercise-id="${item.exercise.id}">
        <img src="${escapeHTML(item.exercise.photo)}" alt="" />
        <span><p>${item.plan ? escapeHTML(item.plan.name.toUpperCase()) : 'BIBLIOTECA DE EXERCÍCIOS'}</p><strong>${escapeHTML(item.exercise.name)}${isCustomExercise(item.exercise.id) ? '<em class="custom-exercise-indicator">Seu</em>' : ''}</strong><small>${configSummary(item.config || defaultExerciseConfig(item.exercise.id))}</small></span>
        <i data-lucide="pencil"></i>
      </button>`).join('')}</div></section>`;
  }).join('');
  document.getElementById('saved-exercises').innerHTML = exerciseLibrary || '<p class="simple-copy">Crie um treino ou um exercício personalizado para montar sua biblioteca.</p>';
  document.getElementById('schedule-list').innerHTML = WEEK_DAYS.map(day => {
    const plans = plansForDay(day.key);
    const description = plans.length ? plans.map(plan => plan.name).join(' + ') : 'Sem treino programado';
    return `<button class="schedule-day ${day.key === todayKey() ? 'current' : ''}" data-action="edit-day" data-day="${day.key}"><span class="day-name">${day.label}</span><span><strong>${escapeHTML(description)}</strong><small>${plans.length ? `${plans.length} ${plans.length === 1 ? 'grupo de treino' : 'grupos de treino'}` : 'Toque para organizar'}</small></span><i data-lucide="chevron-right"></i></button>`;
  }).join('');
  refreshIcons();
}
function renderAll() { renderHome(); renderPlans(); renderProfile(); }

function navigate(page) {
  document.querySelectorAll('.page').forEach(section => section.classList.toggle('active', section.dataset.page === page));
  document.querySelectorAll('.nav-item').forEach(button => button.classList.toggle('active', button.dataset.nav === page));
  document.querySelector(`.page[data-page="${page}"]`).scrollTop = 0;
}
function selectTab(name) {
  document.querySelectorAll('[data-tab]').forEach(button => button.classList.toggle('selected', button.dataset.tab === name));
  document.querySelectorAll('[data-panel]').forEach(panel => panel.classList.toggle('active', panel.dataset.panel === name));
}

function openPlanView(planId) {
  const plan = getPlan(planId);
  if (!plan) return;
  const index = state.plans.indexOf(plan);
  openModal(`
    <div class="modal-plan-header"><span class="modal-letter">${planLetter(index)}</span><div><h2 class="modal-title" id="modal-title">${escapeHTML(plan.name)}</h2><p class="modal-subtitle">${escapeHTML(plan.groups.join(' · '))}</p></div></div>
    <button class="modal-top-action" data-action="open-plan-form" data-plan-id="${plan.id}">Editar</button>
    <div class="modal-exercises">${plan.exercises.map((config, itemIndex) => {
      const exercise = getExercise(config.exerciseId);
      return `<button class="modal-exercise" data-action="open-exercise" data-plan-id="${plan.id}" data-index="${itemIndex}"><span>${String(itemIndex + 1).padStart(2, '0')}</span><span><strong>${escapeHTML(exercise?.name || 'Exercício')}</strong><small>${configSummary(config)}</small></span><i data-lucide="sliders-horizontal"></i></button>`;
    }).join('')}</div>
    <div class="modal-button-row"><button class="modal-cta secondary" data-action="open-plan-form" data-plan-id="${plan.id}">Editar treino</button><button class="modal-cta" data-action="start-plan" data-plan-id="${plan.id}">Começar</button></div>
    <button class="danger-button" data-action="confirm-delete-plan" data-plan-id="${plan.id}">Excluir treino</button>`);
}

function openSavedExerciseEditor(planId, index, exerciseId = '') {
  const plan = planId ? getPlan(planId) : null;
  const config = plan?.exercises[Number(index)] || null;
  const exercise = config ? getExercise(config.exerciseId) : getExercise(exerciseId);
  if (!exercise) return;
  libraryConfigDraft = clone(config || defaultExerciseConfig(exercise.id));
  const custom = isCustomExercise(exercise.id);
  const groupOptions = custom ? `<div class="custom-group-picker">${state.muscleGroups.map(group => `<label><input type="checkbox" data-edit-custom-group value="${group.id}" ${getExerciseGroupIds(exercise).includes(group.id) ? 'checked' : ''} /><span>${escapeHTML(group.name)}</span></label>`).join('')}</div>` : `<div class="muscle-pills">${getExerciseGroupNames(exercise).map(group => `<span>${escapeHTML(group)}</span>`).join('')}</div>`;
  openModal(`
    <h2 class="modal-title" id="modal-title">${custom ? 'Editar exercício' : escapeHTML(exercise.name)}</h2>
    <p class="modal-subtitle">${plan ? `${escapeHTML(plan.name)} · ` : ''}Ajuste séries, repetições e carga.</p>
    <div class="exercise-detail-photo"><img src="${escapeHTML(exercise.photo)}" alt="Exemplo de ${escapeHTML(exercise.name)}" /></div>
    ${configurationControls(libraryConfigDraft, 'change-library-config')}
    <p class="form-hint">${config ? 'Os ajustes valem para este exercício neste treino.' : 'Os ajustes serão usados quando você adicionar este exercício a um novo treino.'}</p>
    ${custom ? `
      <div class="form-group"><label for="edit-custom-name">Nome</label><input id="edit-custom-name" value="${escapeHTML(exercise.name)}" maxlength="55" /></div>
      <div class="form-group"><label for="edit-custom-photo-url">Link da foto</label><input id="edit-custom-photo-url" type="url" inputmode="url" value="${exercise.photo.startsWith('data:') ? '' : escapeHTML(exercise.photo)}" placeholder="Mantenha em branco para usar a foto atual" /></div>
      <div class="form-group"><label for="edit-custom-photo-file">Nova foto do dispositivo</label><input id="edit-custom-photo-file" class="file-input" type="file" accept="image/*" /></div>
      <div class="form-group"><label for="edit-custom-muscles">Músculos em foco</label><input id="edit-custom-muscles" value="${escapeHTML(exercise.muscles.join(', '))}" maxlength="100" /></div>
      <div class="form-group"><label for="edit-custom-description">Descrição</label><textarea id="edit-custom-description" maxlength="300">${escapeHTML(exercise.description)}</textarea></div>
      <div class="form-group"><label for="edit-custom-how-to">Como executar</label><textarea id="edit-custom-how-to" maxlength="400">${escapeHTML(exercise.howTo)}</textarea></div>
      <div class="form-group"><label>Grupos musculares</label>${groupOptions}</div>
    ` : `<div class="detail-copy"><strong>Grupos musculares</strong>${groupOptions}</div><div class="detail-copy"><strong>Descrição</strong><p>${escapeHTML(exercise.description)}</p></div><p class="form-hint">Nome, foto, descrição e grupos pertencem ao catálogo padrão e não podem ser alterados.</p>`}
    <button class="modal-cta" style="margin-top:20px" data-action="save-saved-exercise" data-plan-id="${plan?.id || ''}" data-index="${index}" data-exercise-id="${exercise.id}">Salvar alterações</button>`);
}

async function saveSavedExerciseEditor(planId, index, exerciseId = '') {
  const plan = planId ? getPlan(planId) : null;
  const config = plan?.exercises[Number(index)] || null;
  const exercise = config ? getExercise(config.exerciseId) : getExercise(exerciseId);
  if (!exercise) return;
  if (!libraryConfigDraft || libraryConfigDraft.exerciseId !== exercise.id) return;
  const configuration = clone(libraryConfigDraft);
  if (isCustomExercise(exercise.id)) {
    const name = document.getElementById('edit-custom-name').value.trim();
    const photoUrl = document.getElementById('edit-custom-photo-url').value.trim();
    const photoFile = document.getElementById('edit-custom-photo-file').files[0];
    const muscles = document.getElementById('edit-custom-muscles').value.split(',').map(muscle => muscle.trim()).filter(Boolean);
    const description = document.getElementById('edit-custom-description').value.trim();
    const howTo = document.getElementById('edit-custom-how-to').value.trim();
    const muscleGroups = [...document.querySelectorAll('[data-edit-custom-group]:checked')].map(input => input.value);
    if (!name || !muscles.length || !description || !howTo || !muscleGroups.length) { showToast('Preencha os dados do exercício personalizado.'); return; }
    let photo = exercise.photo;
    try {
      if (photoFile) photo = await readDeviceImage(photoFile);
      else if (photoUrl) {
        if (!/^https?:\/\//i.test(photoUrl)) throw new Error('Use um link de imagem válido.');
        photo = photoUrl;
      }
    } catch (error) { showToast(error.message); return; }
    const updatedExercise = { ...exercise, name, photo, muscles, description, howTo, muscleGroups };
    state.customExercises = state.customExercises.map(item => item.id === exercise.id ? updatedExercise : item);
    state.exercises = state.exercises.map(item => item.id === exercise.id ? updatedExercise : item);
  }
  if (config) Object.assign(config, configuration);
  else state.exerciseDefaults[exercise.id] = configuration;
  if (!(await saveState())) return;
  renderAll();
  closeModal();
  navigate('workouts');
  selectTab('exercises');
  showToast('Exercício atualizado.');
}

function openPlanForm(planId = '', draft = null) {
  const plan = planId ? getPlan(planId) : null;
  const activeDraft = draft || state.planDraft;
  const selectedIds = activeDraft?.selectedIds || plan?.exercises.map(config => config.exerciseId) || [];
  const selectedOrder = new Map(selectedIds.map((id, index) => [id, index + 1]));
  const exerciseSections = state.muscleGroups.map(group => {
    const exercises = state.exercises.filter(exercise => getExerciseGroupIds(exercise).includes(group.id));
    if (!exercises.length) return '';
    return `<section class="exercise-group"><div class="exercise-group-heading"><strong>${escapeHTML(group.name)}</strong><span>${exercises.length} ${exercises.length === 1 ? 'exercício' : 'exercícios'}</span></div><div class="exercise-picker">${exercises.map(exercise => { const order = selectedOrder.get(exercise.id); return `<button class="exercise-choice ${order ? 'selected' : ''}" data-action="toggle-plan-exercise" data-exercise-id="${exercise.id}" data-order="${order || ''}" aria-pressed="${Boolean(order)}"><i>${order ? String(order).padStart(2, '0') : ''}</i><span>${escapeHTML(exercise.name)}</span></button>`; }).join('')}</div></section>`;
  }).join('');
  openModal(`
    <h2 class="modal-title" id="modal-title">${plan ? 'Editar treino' : 'Novo treino'}</h2>
    <p class="modal-subtitle">${plan ? 'Atualize a estrutura do seu treino salvo.' : 'Escolha os exercícios e salve para usar quando quiser.'}</p>
    <div class="form-group"><label for="plan-name">Nome do treino</label><input id="plan-name" value="${escapeHTML(activeDraft?.name ?? plan?.name ?? '')}" placeholder="Ex.: Peito e tríceps" maxlength="40" /></div>
    <div class="form-group"><label for="plan-groups">Grupos musculares</label><input id="plan-groups" value="${escapeHTML(activeDraft?.groups ?? plan?.groups.join(', ') ?? '')}" placeholder="Ex.: Peito, tríceps" maxlength="65" /><p class="form-hint">Separe mais de um grupo por vírgula.</p></div>
    <div class="form-group"><div class="exercise-form-heading"><label>Exercícios</label><button class="add-exercise-button" data-action="open-custom-exercise" data-plan-id="${plan?.id || ''}" data-return="plan"><i data-lucide="plus"></i> Novo exercício</button></div><p class="form-hint">Toque nos itens na ordem em que deseja executá-los.</p><div class="exercise-groups">${exerciseSections}</div></div>
    <button class="modal-cta" style="margin-top:20px" data-action="save-plan" data-plan-id="${plan?.id || ''}">${plan ? 'Salvar alterações' : 'Salvar treino'}</button>`);
  modalContent.dataset.selectedExerciseIds = selectedIds.join(',');
  state.planDraft = null;
}

async function savePlan(planId = '') {
  const name = document.getElementById('plan-name').value.trim();
  const groups = document.getElementById('plan-groups').value.split(',').map(group => group.trim()).filter(Boolean);
  const selectedIds = (modalContent.dataset.selectedExerciseIds || '').split(',').filter(Boolean);
  if (!name || !groups.length || !selectedIds.length) { showToast('Preencha o nome, os grupos e selecione exercícios.'); return; }
  const oldPlan = planId ? getPlan(planId) : null;
  const exercises = selectedIds.map(id => oldPlan?.exercises.find(config => config.exerciseId === id) || defaultExerciseConfig(id));
  const id = planId || modalContent.dataset.savingId || `treino-${Date.now()}`;
  modalContent.dataset.savingId = id;
  const plan = { id, name, groups, exercises };
  if (oldPlan) state.plans = state.plans.map(item => item.id === planId ? plan : item);
  else state.plans = [...state.plans.filter(item => item.id !== id), plan];
  state.planDraft = null;
  if (!(await saveState())) return;
  renderAll(); closeModal(); navigate('workouts'); selectTab('saved'); showToast(oldPlan ? 'Treino atualizado com sucesso.' : 'Novo treino salvo com sucesso.');
}
function togglePlanExercise(choice) {
  const exerciseId = choice.dataset.exerciseId;
  const selectedIds = (modalContent.dataset.selectedExerciseIds || '').split(',').filter(Boolean);
  const selectedIndex = selectedIds.indexOf(exerciseId);
  if (selectedIndex >= 0) selectedIds.splice(selectedIndex, 1);
  else selectedIds.push(exerciseId);
  modalContent.dataset.selectedExerciseIds = selectedIds.join(',');

  document.querySelectorAll('.exercise-choice').forEach(item => {
    const order = selectedIds.indexOf(item.dataset.exerciseId) + 1;
    const isSelected = order > 0;
    item.classList.toggle('selected', isSelected);
    item.dataset.order = isSelected ? order : '';
    item.setAttribute('aria-pressed', String(isSelected));
    item.querySelector('i').textContent = isSelected ? String(order).padStart(2, '0') : '';
  });
}
function capturePlanDraft(planId = '') {
  state.planDraft = {
    planId,
    name: document.getElementById('plan-name')?.value || '',
    groups: document.getElementById('plan-groups')?.value || '',
    selectedIds: (modalContent.dataset.selectedExerciseIds || '').split(',').filter(Boolean)
  };
}
function openCustomExerciseForm(planId = '', returnTo = 'plan') {
  if (returnTo === 'plan') capturePlanDraft(planId);
  else state.planDraft = null;
  state.customExerciseReturn = returnTo;
  openModal(`
    <h2 class="modal-title" id="modal-title">Novo exercício</h2>
    <p class="modal-subtitle">Ele ficará salvo na sua conta, na seção dos grupos escolhidos.</p>
    <div class="form-group"><label for="custom-exercise-name">Nome</label><input id="custom-exercise-name" placeholder="Ex.: Elevação lateral" maxlength="55" /></div>
    <div class="form-group"><label for="custom-photo-url">Link da foto</label><input id="custom-photo-url" type="url" inputmode="url" placeholder="https://exemplo.com/foto.jpg" /><p class="form-hint">Use um link de imagem ou envie uma foto abaixo.</p></div>
    <div class="form-group"><label for="custom-photo-file">Foto do dispositivo</label><input id="custom-photo-file" class="file-input" type="file" accept="image/*" /></div>
    <div class="form-group"><label for="custom-muscles">Músculos em foco</label><input id="custom-muscles" placeholder="Ex.: Deltoide lateral, trapézio" maxlength="100" /></div>
    <div class="form-group"><label for="custom-description">Descrição</label><textarea id="custom-description" placeholder="Explique o objetivo do exercício." maxlength="300"></textarea></div>
    <div class="form-group"><label for="custom-how-to">Como executar</label><textarea id="custom-how-to" placeholder="Descreva a execução com segurança." maxlength="400"></textarea></div>
    <div class="form-group"><label>Grupos musculares</label><div class="custom-group-picker">${state.muscleGroups.map(group => `<label><input type="checkbox" data-custom-group value="${group.id}" /><span>${escapeHTML(group.name)}</span></label>`).join('')}</div></div>
    <button class="modal-cta" style="margin-top:20px" data-action="save-custom-exercise">Salvar exercício</button>`);
}
function readDeviceImage(file) {
  return new Promise((resolve, reject) => {
    if (!file || !file.type.startsWith('image/')) { reject(new Error('Selecione uma imagem válida.')); return; }
    const reader = new FileReader();
    reader.onerror = () => reject(new Error('Não foi possível ler a imagem.'));
    reader.onload = () => {
      const image = new Image();
      image.onerror = () => reject(new Error('Não foi possível processar a imagem.'));
      image.onload = () => {
        const maxSide = 900;
        const scale = Math.min(1, maxSide / Math.max(image.width, image.height));
        const canvas = document.createElement('canvas');
        canvas.width = Math.max(1, Math.round(image.width * scale));
        canvas.height = Math.max(1, Math.round(image.height * scale));
        canvas.getContext('2d').drawImage(image, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL('image/jpeg', .82));
      };
      image.src = reader.result;
    };
    reader.readAsDataURL(file);
  });
}
async function saveCustomExercise() {
  const name = document.getElementById('custom-exercise-name').value.trim();
  const photoUrl = document.getElementById('custom-photo-url').value.trim();
  const photoFile = document.getElementById('custom-photo-file').files[0];
  const muscles = document.getElementById('custom-muscles').value.split(',').map(muscle => muscle.trim()).filter(Boolean);
  const description = document.getElementById('custom-description').value.trim();
  const howTo = document.getElementById('custom-how-to').value.trim();
  const muscleGroups = [...document.querySelectorAll('[data-custom-group]:checked')].map(input => input.value);
  if (!name || !muscles.length || !description || !howTo || !muscleGroups.length || (!photoUrl && !photoFile)) {
    showToast('Preencha todos os campos e escolha uma foto.');
    return;
  }
  let photo = photoUrl;
  try {
    if (photoFile) photo = await readDeviceImage(photoFile);
    else if (!/^https?:\/\//i.test(photo)) throw new Error('Use um link de imagem válido.');
  } catch (error) {
    showToast(error.message);
    return;
  }
  const id = modalContent.dataset.savingId || `personalizado-${Date.now()}`;
  modalContent.dataset.savingId = id;
  const exercise = { id, name, photo, description, howTo, muscles, muscleGroups, ...(muscleGroups.includes('cardio') ? { type: 'cardio' } : {}) };
  state.customExercises = [...state.customExercises.filter(item => item.id !== id), exercise];
  state.exercises = [...state.exercises.filter(item => item.id !== id), exercise];
  if (!(await saveState())) return;
  const draft = state.planDraft;
  if (state.customExerciseReturn === 'library') {
    state.customExerciseReturn = 'plan';
    renderAll();
    closeModal();
    navigate('workouts');
    selectTab('exercises');
  } else openPlanForm(draft?.planId || '', draft);
  showToast('Exercício personalizado salvo.');
}

function openScheduleEditor(dayKey) {
  const day = getDay(dayKey);
  const selected = new Set(state.schedule[dayKey] || []);
  openModal(`
    <h2 class="modal-title" id="modal-title">${day.label}: grupos de treino</h2>
    <p class="modal-subtitle">Você pode escolher mais de um treino para o mesmo dia.</p>
    <div class="modal-exercises">${state.plans.length ? state.plans.map(plan => `<label class="check-row"><input type="checkbox" data-schedule-plan value="${plan.id}" ${selected.has(plan.id) ? 'checked' : ''}/><span><strong>${escapeHTML(plan.name)}</strong><small>${escapeHTML(plan.groups.join(' · '))}</small></span></label>`).join('') : '<p class="simple-copy">Crie pelo menos um treino antes de montar a agenda.</p>'}</div>
    <button class="modal-cta" data-action="save-day" data-day="${dayKey}">Salvar agenda de ${day.label}</button>`);
}
function saveDay(dayKey) {
  state.schedule[dayKey] = [...document.querySelectorAll('[data-schedule-plan]:checked')].map(input => input.value);
  state.selectedDay = dayKey;
  saveState(); renderAll(); closeModal(); showToast('Agenda semanal atualizada.');
}

function openExerciseDetail(planId, index, preserveScroll = false) {
  const plan = getPlan(planId);
  const config = plan?.exercises[Number(index)];
  const exercise = config && getExercise(config.exerciseId);
  if (!plan || !config || !exercise) return;
  openModal(`
    <h2 class="modal-title" id="modal-title">${escapeHTML(exercise.name)}</h2>
    <p class="modal-subtitle">${escapeHTML(plan.name)} · ajuste livremente antes do treino</p>
    <div class="exercise-detail-photo"><img src="${escapeHTML(exercise.photo)}" alt="Exemplo de execução de ${escapeHTML(exercise.name)}" /></div>
    <div class="detail-copy"><strong>Grupos musculares</strong><div class="muscle-pills">${getExerciseGroupNames(exercise).map(group => `<span>${escapeHTML(group)}</span>`).join('')}</div></div>
    <div class="detail-copy"><strong>Músculos em foco</strong><p>${escapeHTML(exercise.muscles.join(' · '))}</p></div>
    <div class="detail-copy"><strong>O que você treina</strong><p>${escapeHTML(exercise.description)}</p></div>
    <div class="detail-copy"><strong>Como executar</strong><p>${escapeHTML(exercise.howTo)}</p></div>
    ${configurationControls(config, 'change-config', `data-plan-id="${plan.id}" data-index="${index}"`)}
    <button class="modal-cta" style="margin-top:18px" data-action="close-modal">Salvar ajustes</button>`, { preserveScroll });
}
function changeConfig(planId, index, field, delta) {
  const config = getPlan(planId)?.exercises[Number(index)];
  if (!config) return;
  adjustConfig(config, field, delta);
  saveState(); renderAll();
}
function checkInFreeDay() {
  if (state.selectedDay !== todayKey()) {
    showToast('O check-in de dia livre só pode ser feito no dia atual.');
    return;
  }
  const date = todayDateKey();
  if (plansForDay(todayKey()).length) return;
  if (state.freeDayCheckins[date]) return;
  state.freeDayCheckins[date] = true;
  saveState();
  renderHome();
  showToast('Pausa registrada. Cuidar da recuperação também faz parte do treino.');
}

function startWorkout(planIds, options = {}) {
  if (!options.allowRepeat && state.selectedDay !== todayKey()) {
    showToast('Os treinos só podem ser iniciados no dia atual.');
    return;
  }
  if (state.session) { state.session.paused ? resumeSession() : openSession(); return; }
  const scheduled = state.schedule[todayKey()] || [];
  if (!planIds.length || planIds.some(id => !scheduled.includes(id))) { showToast('Este treino não está programado para hoje.'); return; }
  const plans = planIds.map(getPlan).filter(Boolean);
  const exercises = exercisesForPlans(plans).map(item => ({ planId: item.planId, planName: item.planName, exerciseId: item.config.exerciseId, sets: item.config.sets, reps: item.config.reps, weight: item.config.weight }));
  if (!exercises.length) { showToast('Selecione exercícios antes de iniciar um treino.'); return; }
  state.session = {
    planIds,
    exercises,
    exerciseIndex: 0,
    completedSets: 0,
    paused: false,
    startedAt: Date.now(),
    activeMilliseconds: 0,
    rewardXp: options.rewardXp !== false && !state.completedDates[todayDateKey()]
  };
  saveState();
  openSession();
}
function openSession() {
  const session = state.session;
  const item = session?.exercises[session.exerciseIndex];
  const exercise = item && getExercise(item.exerciseId);
  if (!session || !item || !exercise) return;
  const progress = session.exercises.map((_, index) => `<i class="${index <= session.exerciseIndex ? 'active' : ''}"></i>`).join('');
  const sets = Array.from({ length: item.sets }, (_, index) => `<span class="${index < session.completedSets ? 'done' : ''}">${index + 1}</span>`).join('');
  openModal(`
    <div class="session-progress">${progress}</div>
    <div class="session-photo"><img src="${escapeHTML(exercise.photo)}" alt="${escapeHTML(exercise.name)}" /><span><i data-lucide="info"></i> Exemplo de execução</span></div>
    <div class="session-info"><p class="micro-title">EXERCÍCIO ${session.exerciseIndex + 1} DE ${session.exercises.length}</p><h2 class="modal-title" id="modal-title">${escapeHTML(exercise.name)}</h2><p>${configSummary(item).replace('rep.', 'repetições').replace(' min', ' minutos').replace(' seg', ' segundos')}</p></div>
    <div class="set-indicators">${sets}</div>
    <div class="session-buttons"><button class="pause" data-action="pause-session"><i data-lucide="pause"></i> Pausar</button><button class="finish-set" data-action="complete-set">Concluir série</button></div>`);
}
function pauseSession() {
  if (!state.session || state.session.paused) return;
  state.session.activeMilliseconds = Number(state.session.activeMilliseconds || 0) + Math.max(0, Date.now() - Number(state.session.startedAt || Date.now()));
  state.session.paused = true;
  saveState();
  closeModal(); renderHome(); showToast('Treino pausado. Você pode retomar quando quiser.');
}
function resumeSession() {
  if (!state.session) return;
  state.session.paused = false;
  state.session.startedAt = Date.now();
  saveState();
  openSession();
}
function completeSet() {
  const session = state.session;
  if (!session || session.paused) return;
  checkpointActivity();
  const item = session.exercises[session.exerciseIndex];
  session.completedSets += 1;
  if (session.completedSets < item.sets) { saveState(); openSession(); showToast('Série registrada. Continue assim!'); return; }
  session.exerciseIndex += 1;
  session.completedSets = 0;
  if (session.exerciseIndex >= session.exercises.length) finishWorkout();
  else { saveState(); openSession(); showToast('Exercício concluído! Próximo movimento.'); }
}
function finishWorkout() {
  if (!state.session) return;
  const date = todayDateKey();
  const isFirstWorkoutToday = !state.completedDates[date];
  const activeMilliseconds = Number(state.session?.activeMilliseconds || 0) + Math.max(0, Date.now() - Number(state.session?.startedAt || Date.now()));
  const activityAdded = activeMilliseconds / 60000;
  const earnsXp = state.session?.rewardXp !== false && isFirstWorkoutToday;
  const completedPlanIds = [...(state.session?.planIds || [])];

  // Repetições contam como atividade, mas não concedem XP novamente.
  if (earnsXp) {
    state.xp += XP_PER_WORKOUT;
    state.totalWorkouts += 1;
  }
  state.activityMinutes += activityAdded;

  if (isFirstWorkoutToday && earnsXp) {
    state.completedDates[date] = true;
    state.streak = calculateCurrentStreak();
  }
  state.session = null;
  saveState(); renderAll();
  openModal(`<div class="celebration"><span class="celebration-badge"><i data-lucide="party-popper"></i></span><p class="micro-title">TREINO CONCLUÍDO</p><h2 class="modal-title" id="modal-title">Você conseguiu!</h2><p>Mais um passo para a sua evolução. A sequência continua acesa.</p><div class="reward-grid"><article><strong>${earnsXp ? `+${XP_PER_WORKOUT} XP` : 'Sem XP'}</strong><span>${earnsXp ? 'experiência ganha' : 'treino repetido'}</span></article><article><strong>+${escapeHTML(formatActivity(activityAdded))}</strong><span>em atividade</span></article><article><strong>${state.streak} dias 🔥</strong><span>${isFirstWorkoutToday ? 'nova sequência' : 'sequência mantida'}</span></article></div><div class="modal-button-row"><button class="modal-cta secondary" data-action="repeat-workout" data-plan-ids="${completedPlanIds.join(',')}">Repetir sem XP</button><button class="modal-cta" data-action="finish-celebration">Concluir</button></div></div>`);
}

function confirmDeletePlan(planId) {
  const plan = getPlan(planId);
  if (!plan) return;
  openModal(`<div class="simple-icon"><i data-lucide="triangle-alert"></i></div><h2 class="modal-title" id="modal-title">Excluir treino?</h2><p class="simple-copy">“${escapeHTML(plan.name)}” será removido da agenda semanal e não poderá ser recuperado.</p><div class="modal-button-row"><button class="modal-cta secondary" data-action="view-plan" data-plan-id="${planId}">Cancelar</button><button class="modal-cta" style="background:#ff7d6d" data-action="delete-plan" data-plan-id="${planId}">Excluir</button></div>`);
}
function deletePlan(planId) {
  state.plans = state.plans.filter(plan => plan.id !== planId);
  WEEK_DAYS.forEach(day => { state.schedule[day.key] = (state.schedule[day.key] || []).filter(id => id !== planId); });
  saveState(); renderAll(); closeModal(); showToast('Treino excluído da sua biblioteca.');
}

function applyTheme(theme, announce = true) {
  if (!['dark', 'light', 'violet'].includes(theme)) return;
  state.theme = theme;
  document.body.dataset.theme = theme;
  saveState();
  renderProfile();
  if (announce) showToast(`${themeLabel(theme)} aplicado.`);
}
function openAppearanceModal() {
  const themes = [
    { id: 'dark', name: 'Escuro', description: 'Contraste confortável para treinar à noite.' },
    { id: 'light', name: 'Claro', description: 'Visual leve e luminoso para o dia.' },
    { id: 'violet', name: 'Violeta', description: 'Uma variação escura com toque roxo.' }
  ];
  openModal(`<div class="simple-icon"><i data-lucide="palette"></i></div><h2 class="modal-title" id="modal-title">Aparência</h2><p class="simple-copy">Escolha o tema que combina melhor com sua rotina. A preferência fica salva na sua conta.</p><div class="theme-options">${themes.map(theme => `<button class="theme-option ${state.theme === theme.id ? 'selected' : ''}" data-action="set-theme" data-theme="${theme.id}" aria-pressed="${state.theme === theme.id}"><span class="theme-preview ${theme.id}"><i></i><i></i></span><span><strong>${theme.name}</strong><small>${theme.description}</small></span><i data-lucide="${state.theme === theme.id ? 'check-circle-2' : 'circle'}"></i></button>`).join('')}</div><button class="modal-cta secondary" data-action="close-modal">Concluir</button>`);
}

function accountPassword(id, label, autocomplete) {
  return `<label class="account-label" for="${id}">${label}</label><div class="account-password"><input id="${id}" name="${id}" type="password" autocomplete="${autocomplete}" required maxlength="72"><button type="button" data-account-toggle="${id}" aria-label="Mostrar ${label.toLowerCase()}" aria-pressed="false">Mostrar</button></div>`;
}
function openAccount(mode = 'name') {
  const user = state.user;
  if (!user) return;
  let fields = '';
  if (mode === 'name') fields = `<label class="account-label" for="account-name">Como podemos chamar você?</label><input id="account-name" name="name" value="${escapeHTML(user.nome)}" autocomplete="name" minlength="2" maxlength="80" required><p class="account-hint">Esse nome aparece no seu perfil. Seu e-mail permanece o mesmo.</p>`;
  if (mode === 'password') fields = `<p class="account-hint">Confirme sua senha atual. Após a troca, será necessário entrar novamente em todos os dispositivos.</p>${accountPassword('currentPassword', 'Senha atual', 'current-password')}${accountPassword('newPassword', 'Nova senha', 'new-password')}${accountPassword('confirmPassword', 'Repita a nova senha', 'new-password')}<p class="account-hint">Use pelo menos 8 caracteres. A senha atual nunca é exibida ou recuperada.</p>`;
  if (mode === 'delete') fields = `<div class="account-warning"><strong>Esta ação é permanente</strong><p>Sua conta, treinos, exercícios pessoais, histórico e preferências serão apagados. Os exercícios padrão do aplicativo não serão excluídos.</p></div>${accountPassword('currentPassword', 'Senha atual', 'current-password')}<label class="account-label" for="account-confirmation">Digite EXCLUIR para confirmar</label><input id="account-confirmation" name="confirmation" required pattern="EXCLUIR" autocomplete="off" placeholder="EXCLUIR">`;
  const title = mode === 'password' ? 'Alterar senha' : mode === 'delete' ? 'Excluir conta' : 'Dados da conta';
  openModal(`<section class="account-panel"><div class="account-heading"><span class="account-avatar">${escapeHTML(user.nome.trim().slice(0, 1).toUpperCase())}</span><div><p class="micro-title">SUA CONTA</p><h2 class="modal-title" id="modal-title">${title}</h2></div></div><div class="account-email"><span>E-mail de acesso</span><strong>${escapeHTML(user.email)}</strong></div><nav class="account-tabs" aria-label="Configurações da conta"><button type="button" data-account-mode="name" aria-pressed="${mode === 'name'}">Dados pessoais</button><button type="button" data-account-mode="password" aria-pressed="${mode === 'password'}">Segurança</button></nav><form id="account-form" data-mode="${mode}">${fields}<p class="account-error" role="alert" hidden></p><button type="submit" class="modal-cta ${mode === 'delete' ? 'account-delete' : ''}">${mode === 'name' ? 'Salvar nome' : mode === 'password' ? 'Alterar senha' : 'Excluir minha conta definitivamente'}</button></form>${mode !== 'delete' ? '<div class="account-danger-zone"><span>Gerenciar seus dados</span><button type="button" data-account-mode="delete">Excluir minha conta</button></div>' : '<button type="button" class="account-back" data-account-mode="name">Cancelar e voltar</button>'}</section>`);
}
document.addEventListener('click', event => {
  const mode = event.target.closest('[data-account-mode]');
  if (mode) { openAccount(mode.dataset.accountMode); return; }
  const toggle = event.target.closest('[data-account-toggle]');
  if (!toggle) return;
  const input = document.getElementById(toggle.dataset.accountToggle);
  const show = input.type === 'password';
  input.type = show ? 'text' : 'password';
  toggle.textContent = show ? 'Ocultar' : 'Mostrar';
  toggle.setAttribute('aria-label', `${show ? 'Ocultar' : 'Mostrar'} senha`);
  toggle.setAttribute('aria-pressed', String(show));
});
document.addEventListener('submit', async event => {
  const form = event.target;
  if (form.id !== 'account-form') return;
  event.preventDefault();
  const button = form.querySelector('[type="submit"]');
  if (button.disabled) return;
  const errorBox = form.querySelector('.account-error');
  errorBox.hidden = true;
  const payload = Object.fromEntries(new FormData(form));
  payload.action = form.dataset.mode;
  await saveWithButton(button, async () => {
    try {
      if (payload.action !== 'name') {
        if (state.session && !state.session.paused) pauseSession();
        if (!(await saveQueue) || needsSave) {
          if (!(await saveState())) throw new Error('Salve as alterações pendentes antes de continuar.');
        }
      }
      const result = await SimpleGymAPI.request('conta.php', payload);
      if (result.logout) {
        ready = false;
        state.user = null;
        window.location.replace(new URL('../../auth/login.php', scriptSource).href);
        return;
      }
      state.user = result.user;
      renderProfile();
      showToast(result.message);
      openAccount();
    } catch (error) {
      errorBox.textContent = error.message || 'Não foi possível atualizar sua conta.';
      errorBox.hidden = false;
    }
  });
});

function openSimpleModal(type) {
  if (type === 'edit-profile') { openAccount(); return; }
  if (type === 'terms') {
    openModal(`<h2 class="modal-title" id="modal-title">Termo de responsabilidade</h2>${document.getElementById('responsibility-terms-template').innerHTML}<button class="modal-cta secondary" data-action="close-modal">Fechar</button>`);
    return;
  }
  const entries = {
    goals: ['target', 'Meta semanal', 'Sua meta é fazer 4 treinos por semana. Você pode aumentar ou reduzir essa frequência sempre que precisar.'],
    privacy: ['shield-check', 'Privacidade e dados', 'Seus treinos e exercícios ficam salvos na sua conta. Use Sair da conta para encerrar o acesso neste dispositivo.'],
  };
  if (type === 'appearance') { openAppearanceModal(); return; }
  if (type === 'reminders') {
    openModal(`<div class="simple-icon"><i data-lucide="bell-ring"></i></div><h2 class="modal-title" id="modal-title">Lembretes</h2><p class="simple-copy">Defina como o SimpleGym deve ajudar você a manter a rotina.</p><div class="switch-row"><div><strong>Lembrete de treino</strong><small>Terças e quintas, às 18h</small></div><button class="switch on" data-action="toggle-switch" aria-label="Ativar lembretes"></button></div><button class="modal-cta" style="margin-top:18px" data-action="close-modal">Salvar preferência</button>`);
    return;
  }
  const [icon, title, text] = entries[type] || ['sparkles', 'SimpleGym', 'Tudo pronto para o seu próximo treino.'];
  openModal(`<div class="simple-icon"><i data-lucide="${icon}"></i></div><h2 class="modal-title" id="modal-title">${title}</h2><p class="simple-copy">${text}</p><button class="modal-cta" data-action="close-modal">Entendi</button>`);
}

document.addEventListener('click', event => {
  const target = event.target.closest('[data-action], [data-nav], [data-tab]');
  if (!target) return;
  if (!ready && !['reload-app'].includes(target.dataset.action)) return;
  if (target.dataset.nav) { navigate(target.dataset.nav); return; }
  if (target.dataset.tab) { selectTab(target.dataset.tab); return; }
  const action = target.dataset.action;
  if (action === 'select-day') { state.selectedDay = target.dataset.day; renderHome(); }
  else if (action === 'open-workouts') { navigate('workouts'); }
  else if (action === 'open-profile') { navigate('profile'); }
  else if (action === 'open-schedule') { navigate('workouts'); selectTab('schedule'); }
  else if (action === 'create-plan') openPlanForm();
  else if (action === 'view-plan') openPlanView(target.dataset.planId);
  else if (action === 'open-plan-form') openPlanForm(target.dataset.planId);
  else if (action === 'toggle-plan-exercise') togglePlanExercise(target);
  else if (action === 'open-custom-exercise') openCustomExerciseForm(target.dataset.planId, target.dataset.return);
  else if (action === 'save-custom-exercise') saveWithButton(target, saveCustomExercise);
  else if (action === 'edit-saved-exercise') openSavedExerciseEditor(target.dataset.planId, target.dataset.index, target.dataset.exerciseId);
  else if (action === 'save-saved-exercise') saveWithButton(target, () => saveSavedExerciseEditor(target.dataset.planId, target.dataset.index, target.dataset.exerciseId));
  else if (action === 'save-plan') saveWithButton(target, () => savePlan(target.dataset.planId));
  else if (action === 'edit-day') openScheduleEditor(target.dataset.day);
  else if (action === 'save-day') saveDay(target.dataset.day);
  else if (action === 'open-exercise') openExerciseDetail(target.dataset.planId, target.dataset.index);
  else if (action === 'change-config') changeConfig(target.dataset.planId, target.dataset.index, target.dataset.field, target.dataset.delta);
  else if (action === 'change-library-config' && libraryConfigDraft) adjustConfig(libraryConfigDraft, target.dataset.field, target.dataset.delta);
  else if (action === 'retry-save') saveState();
  else if (action === 'reload-app') window.location.reload();
  else if (action === 'free-day-checkin') checkInFreeDay();
  else if (action === 'start-day-workout') {
    if (!exercisesForPlans(plansForDay(state.selectedDay)).length) checkInFreeDay();
    else startWorkout(state.schedule[state.selectedDay] || []);
  }
  else if (action === 'start-plan') startWorkout([target.dataset.planId]);
  else if (action === 'pause-session') pauseSession();
  else if (action === 'complete-set') completeSet();
  else if (action === 'confirm-delete-plan') confirmDeletePlan(target.dataset.planId);
  else if (action === 'delete-plan') deletePlan(target.dataset.planId);
  else if (action === 'repeat-workout') startWorkout(target.dataset.planIds.split(',').filter(Boolean), { allowRepeat: true, rewardXp: false });
  else if (action === 'finish-celebration') { closeModal(); navigate('home'); showToast('Treino salvo. Até o próximo treino!'); }
  else if (action === 'set-theme') { applyTheme(target.dataset.theme); openAppearanceModal(); }
  else if (action === 'toggle-switch') { target.classList.toggle('on'); showToast(target.classList.contains('on') ? 'Lembretes ativados.' : 'Lembretes desativados.'); }
  else if (action === 'close-modal') closeModal();
  else if (action === 'logout') logout();
  else openSimpleModal(action);
});

modalBackdrop.addEventListener('click', event => { if (event.target === modalBackdrop) closeModal(); });
document.addEventListener('keydown', event => { if (event.key === 'Escape') closeModal(); });
document.addEventListener('dblclick', event => event.preventDefault(), { passive: false });

async function initializeApp() {
  try {
    const { user } = await SimpleGymAPI.request('sessao.php');
    if (!user) { window.location.replace(new URL('../../auth/login.php', scriptSource).href); return; }
    const data = await SimpleGymAPI.request('dados.php');
    Object.assign(state, data.state, { user, selectedDay: todayKey() });
    dataVersion = data.version;
    // Dados demonstrativos antigos não são importados para contas reais.
    try {
      localStorage.removeItem('simplegym-data-v2');
      localStorage.removeItem('simplegym-paused-session-v2');
    } catch { /* O app também funciona quando o armazenamento local está bloqueado. */ }
    state.exercises = [...data.catalog.exercises, ...state.customExercises];
    state.muscleGroups = data.catalog.muscleGroups;
    state.levels = data.catalog.levels;
    // Reabrir uma sessão salva não contabiliza o período em que o app ficou fechado.
    if (state.session && !state.session.paused) {
      state.session.paused = true;
      state.session.startedAt = Date.now();
    }
    syncStreak();
    document.body.dataset.theme = state.theme;
    renderAll();
    ready = true;
    document.body.classList.remove('app-loading');
    document.getElementById('app-load-status').hidden = true;
  } catch (error) {
    if (error.status === 401) { window.location.replace(new URL('../../auth/login.php', scriptSource).href); return; }
    const status = document.getElementById('app-load-status');
    status.querySelector('p').textContent = error.message || 'Não foi possível carregar sua conta.';
    status.querySelector('button').hidden = false;
  }
}
window.addEventListener('online', () => { if (needsSave && ready && !saveConflict) saveState(); });
function checkpointActivity() {
  if (!state.session || state.session.paused) return;
  const now = Date.now();
  state.session.activeMilliseconds += Math.max(0, now - state.session.startedAt);
  state.session.startedAt = now;
}
setInterval(() => {
  if (ready && state.session && !state.session.paused && !needsSave) {
    checkpointActivity();
    saveState();
  }
}, 30000);
window.addEventListener('beforeunload', event => { if (needsSave) { event.preventDefault(); event.returnValue = ''; } });
window.addEventListener('pageshow', event => { if (event.persisted) window.location.reload(); });
initializeApp();
