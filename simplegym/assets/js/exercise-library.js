// Adaptações editoriais em português. Os registros originais permanecem no banco.
const exerciseGuidance = {
  'puxada-alta':['Ajuste o apoio das coxas e mantenha os pés no chão.','Puxe a barra até a parte superior do peito, sem balançar o tronco.','Retorne lentamente, controlando a carga.'],
  'supino-reto':['Deite no banco com os pés apoiados e segure a barra com firmeza.','Desça a barra em direção ao peito, mantendo os ombros apoiados.','Empurre para cima com controle. Use apoio de segurança.'],
  'remada-baixa':['Sente-se com os pés apoiados e o tronco firme.','Puxe a alça até o abdômen, levando os cotovelos para trás.','Estenda os braços lentamente, sem arredondar as costas.'],
  desenvolvimento:['Sente-se com o tronco apoiado e os halteres na altura dos ombros.','Empurre os halteres para cima sem arquear a lombar.','Desça lentamente até a posição inicial.'],
  agachamento:['Apoie a barra na parte superior das costas e firme os pés.','Flexione quadris e joelhos, mantendo os calcanhares apoiados.','Suba com controle. Use suporte de segurança e uma amplitude confortável.'],
  'leg-press':['Apoie as costas no encosto e coloque os pés na plataforma.','Flexione os joelhos sem tirar o quadril do apoio.','Empurre a plataforma sem travar os joelhos.'],
  'rosca-direta':['Segure a barra com as palmas voltadas para cima.','Flexione os cotovelos sem balançar o tronco.','Desça a barra de forma controlada.'],
  esteira:['Ajuste a velocidade antes de começar e use a trava de segurança.','Caminhe ou corra com postura ereta, em ritmo confortável.','Reduza a velocidade aos poucos antes de sair.'],
  bicicleta:['Ajuste o banco para manter uma leve flexão no joelho ao pedalar.','Mantenha o tronco estável e pedale de forma contínua.','Escolha uma resistência confortável e reduza o ritmo ao terminar.'],
  corda:['Segure a corda com os cotovelos próximos ao corpo.','Gire pelos punhos e faça saltos baixos.','Aterrisse suavemente, mantendo um ritmo confortável.'],
  prancha:['Apoie os antebraços e as pontas dos pés no chão.','Mantenha o corpo alinhado e contraia o abdômen.','Respire normalmente, sem deixar o quadril cair.'],
  flexao:['Apoie as mãos um pouco além da largura dos ombros.','Desça o peito com o corpo alinhado e o abdômen firme.','Empurre o chão até retornar à posição inicial.'],
  'barra-fixa':['Segure uma barra firme com as palmas voltadas para a frente.','Puxe o corpo levando os cotovelos para baixo, sem impulso.','Desça lentamente até estender os braços de forma confortável.'],
  'remada-invertida':['Segure uma barra fixa e mantenha o corpo inclinado e alinhado.','Puxe o peito em direção à barra.','Estenda os braços com controle, sem deixar o quadril cair.'],
  'remada-invertida-joelhos':['Segure uma barra fixa com os joelhos flexionados e os pés apoiados.','Leve o peito até a barra mantendo o tronco firme.','Retorne devagar, controlando a descida.'],
  paralelas:['Apoie-se em barras paralelas estáveis.','Flexione os cotovelos em uma amplitude confortável para os ombros.','Empurre as barras para subir sem usar impulso.'],
  'flexao-fechada':['Apoie as mãos próximas, abaixo da linha do peito.','Flexione os cotovelos próximos ao corpo, mantendo o tronco alinhado.','Empurre o chão e retorne com controle.'],
  'flexao-fechada-joelhos':['Apoie os joelhos e as mãos próximas no chão.','Desça o peito mantendo o tronco alinhado com as coxas.','Empurre o chão para retornar, sem dobrar o quadril.'],
  'avanco-livre':['Em pé, dê um passo à frente.','Flexione os joelhos mantendo o tronco ereto e o pé dianteiro apoiado.','Empurre o chão para voltar e alterne as pernas.'],
  'abdominal-solo':['Deite com os joelhos dobrados e os pés apoiados.','Eleve levemente os ombros contraindo o abdômen, sem puxar o pescoço.','Retorne devagar ao chão.'],
  'panturrilha-livre':['Fique em pé e use um apoio firme para se equilibrar.','Eleve os calcanhares, apoiando-se na parte da frente dos pés.','Desça devagar, sem perder o equilíbrio.'],
  'elevacao-lateral':['Segure os halteres ao lado do corpo, com leve flexão nos cotovelos.','Eleve os braços lateralmente até uma altura confortável.','Desça lentamente, sem balançar o tronco.'],
  'supino-inclinado':['Deite no banco inclinado com os pés firmes e os ombros apoiados.','Desça a barra em direção à parte superior do peito.','Empurre com controle. Use apoio de segurança.'],
  'triceps-corda':['Segure a corda na polia alta e mantenha os cotovelos junto ao corpo.','Estenda os braços, afastando levemente as pontas da corda.','Retorne devagar sem mover os ombros.'],
  'mesa-flexora':['Deite na máquina e ajuste o rolo acima dos calcanhares.','Flexione os joelhos levando os calcanhares em direção ao quadril.','Retorne devagar, mantendo o quadril apoiado.'],
  'cadeira-flexora':['Ajuste os apoios da máquina e mantenha as costas no encosto.','Flexione os joelhos, puxando o rolo para baixo e para trás.','Retorne lentamente, sem levantar o quadril.'],
  'agachamento-goblet':['Segure um halter junto ao peito e afaste os pés confortavelmente.','Flexione quadris e joelhos mantendo o tronco firme.','Suba empurrando o chão, sem tirar os calcanhares do apoio.'],
  'avanco-halteres':['Segure os halteres ao lado do corpo e dê um passo à frente.','Flexione os joelhos mantendo o tronco ereto.','Empurre o chão para voltar e alterne as pernas.'],
  'panturrilha-halteres':['Segure os halteres ao lado do corpo, em uma base estável.','Eleve os calcanhares sem balançar o tronco.','Desça lentamente e mantenha o equilíbrio.']
};
const libraryFilter = { query:'', mode:null, muscle:'' };
function exerciseEquipment(exercise) {
  return ({'body only':'Peso corporal',bodyweight:'Peso corporal',barbell:'Barra',dumbbell:'Halteres',cable:'Polia',machine:'Máquina','leverage machine':'Máquina','sled machine':'Leg press',rope:'Corda',bands:'Elástico',kettlebells:'Kettlebell',other:'Outro equipamento'})[exercise.equipment] || ({esteira:'Esteira',bicicleta:'Bicicleta',corda:'Corda'})[exercise.id] || 'Não especificado';
}
function exerciseLevel(exercise) { return ({beginner:'Iniciante',intermediate:'Intermediário',expert:'Avançado'})[exercise.level] || ''; }
function exerciseFocus(exercise) { return exercise.primaryMuscles?.[0] || exercise.muscles?.[0] || getExerciseGroupNames(exercise)[0] || 'Corpo'; }
function foldExerciseText(text) { return String(text).normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase(); }
function renderExerciseLibrary() {
  const root=document.getElementById('saved-exercises');
  const mode=libraryFilter.mode || state.trainingPreference || 'ambas';
  const query=foldExerciseText(libraryFilter.query.trim());
  const entries=state.exercises.filter(exercise => {
    const custom=isCustomExercise(exercise.id);
    return (custom || mode==='ambas' || !exercise.modality || exercise.modality==='ambas' || exercise.modality===mode)
      && (!libraryFilter.muscle || getExerciseGroupIds(exercise).includes(libraryFilter.muscle))
      && (!query || foldExerciseText([exercise.name,exerciseEquipment(exercise),...getExerciseGroupNames(exercise),...(exercise.muscles||[])].join(' ')).includes(query));
  });
  const sections=[['musculacao','Musculação','Força com equipamentos'],['calistenia','Calistenia','Controle do próprio corpo'],['ambas','Para qualquer rotina','Core e condicionamento'],['custom','Criados por você','Seu jeito de treinar']];
  root.innerHTML=`<div class="library-result" role="status">${entries.length} ${entries.length===1?'exercício encontrado':'exercícios encontrados'}</div>`+sections.map(([key,title,subtitle])=>{
    const list=entries.filter(exercise => isCustomExercise(exercise.id) ? key==='custom' : (exercise.modality||'ambas')===key);
    if(!list.length)return '';
    return `<section class="library-section"><header><div><h3>${title}</h3><p>${subtitle}</p></div><span>${list.length}</span></header><div class="library-grid">${list.map(exercise=>`<button class="library-card" data-action="edit-saved-exercise" data-exercise-id="${escapeHTML(exercise.id)}" data-index="-1" aria-label="Ver ${escapeHTML(exercise.name)}"><span class="library-art"><img loading="lazy" src="${escapeHTML(exercise.diagram||exercise.photo)}" alt="${exercise.diagram?'Músculos trabalhados':'Imagem do exercício'}" referrerpolicy="no-referrer"><span class="library-badge">${isCustomExercise(exercise.id)?'Seu exercício':escapeHTML(exerciseFocus(exercise))}</span></span><span class="library-card-body"><strong>${escapeHTML(exercise.name)}</strong><span class="library-equipment"><i data-lucide="${exercise.equipment==='body only'?'person-standing':'dumbbell'}"></i>${escapeHTML(exerciseEquipment(exercise))}</span><span class="library-card-foot"><small>${escapeHTML(exerciseLevel(exercise)||'Ver detalhes')}</small><i data-lucide="arrow-up-right"></i></span></span></button>`).join('')}</div></section>`;
  }).join('')+(!entries.length?'<div class="library-empty"><i data-lucide="search"></i><h3>Nenhum exercício encontrado</h3><p>Tente outro nome ou mude os filtros.</p><button type="button" data-library-reset>Limpar filtros</button></div>':'');
  document.querySelectorAll('[data-library-mode]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.libraryMode===mode)));
  const select=document.getElementById('library-muscle');
  if(select && select.options.length!==state.muscleGroups.length+1)select.innerHTML='<option value="">Todos os músculos</option>'+state.muscleGroups.map(g=>`<option value="${escapeHTML(g.id)}">${escapeHTML(g.name)}</option>`).join('');
  if(select)select.value=libraryFilter.muscle;
  refreshIcons();
}
function exercisePlanLinks(exercise) {
  const occurrences=state.plans.flatMap(plan=>plan.exercises.map((config,index)=>({plan,config,index}))).filter(item=>item.config.exerciseId===exercise.id);
  if(!occurrences.length)return '';
  return `<details class="exercise-extra"><summary>Ajustar nos meus treinos (${occurrences.length})</summary><div class="exercise-plan-links">${occurrences.map(({plan,index})=>`<button type="button" data-action="edit-saved-exercise" data-plan-id="${escapeHTML(plan.id)}" data-index="${index}">${escapeHTML(plan.name)} · exercício ${index+1}</button>`).join('')}</div></details>`;
}
document.addEventListener('input',event=>{if(event.target.id==='library-search'){libraryFilter.query=event.target.value;renderExerciseLibrary();}});
document.addEventListener('change',event=>{if(event.target.id==='library-muscle'){libraryFilter.muscle=event.target.value;renderExerciseLibrary();}});
document.addEventListener('click',event=>{
  const button=event.target.closest('[data-library-mode]');
  if(button){libraryFilter.mode=button.dataset.libraryMode;renderExerciseLibrary();}
  if(event.target.closest('[data-library-reset]')){libraryFilter.query='';libraryFilter.mode='ambas';libraryFilter.muscle='';document.getElementById('library-search').value='';renderExerciseLibrary();}
});
