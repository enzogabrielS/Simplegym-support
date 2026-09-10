import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const base = process.env.SIMPLEGYM_TEST_URL || 'http://localhost:8080';
const php = process.env.SIMPLEGYM_TEST_PHP;
const ext = process.env.SIMPLEGYM_TEST_PHP_EXT;
if (!php || !ext) throw new Error('Informe SIMPLEGYM_TEST_PHP e SIMPLEGYM_TEST_PHP_EXT para limpar as contas de teste.');
const run = Date.now() + '-' + randomBytes(4).toString('hex');
const emails = [`teste-${run}-a@simplegym.test`, `teste-${run}-b@simplegym.test`];
const password = randomBytes(20).toString('hex');
let assertions = 0;
function check(actual, expected) { assert.deepEqual(actual, expected); assertions++; }
class Client {
  cookies = new Map();
  csrf = '';
  async request(path, data, useCsrf = true) {
    const response = await fetch(base + path, {
      method: data === undefined ? 'GET' : 'POST', redirect: 'manual',
      headers: { Cookie: [...this.cookies].map(([k, v]) => `${k}=${v}`).join('; '),
        ...(data === undefined ? {} : { 'Content-Type': 'application/json', ...(useCsrf ? { 'X-CSRF-Token': this.csrf } : {}) }) },
      ...(data === undefined ? {} : { body: JSON.stringify(data) })
    });
    for (const cookie of response.headers.getSetCookie()) {
      const [key, ...parts] = cookie.split(';')[0].split('=');
      const value = parts.join('=');
      if (/max-age=0/i.test(cookie)) this.cookies.delete(key);
      else this.cookies.set(key, value);
    }
    const text = await response.text();
    let body;
    try { body = JSON.parse(text); } catch { body = text; }
    if (body.csrf) this.csrf = body.csrf;
    return { status: response.status, body, headers: response.headers };
  }
  api(file, data, csrf = true) { return this.request('/assets/php/' + file + '.php', data, csrf); }
}
const clientA = new Client();
const clientB = new Client();
try {
  check((await clientA.request('/index.php')).status, 302);
  check((await clientA.api('dados')).status, 401);
  check((await clientA.request('/views/app.php')).status, 404);
  check((await clientA.request('/assets/php/config.local.php')).status, 404);
  check((await clientA.api('sessao')).body.user, null);
  check((await clientA.api('cadastrar', { name: 'Conta Teste A', email: emails[0], password }, false)).status, 419);
  check((await clientA.api('cadastrar', { name: 'Conta Teste A', email: emails[0], password: '123' })).status, 422);
  const registration = await clientA.api('cadastrar', { name: 'Conta Teste A', email: emails[0], password });
  check(registration.status, 201);
  assert.ok(registration.headers.getSetCookie().some(c => /simplegym_lembrar=.*HttpOnly/i.test(c) && /SameSite=Lax/i.test(c)));
  assertions++;
  check((await clientA.api('sessao')).body.user.email, emails[0]);
  check((await clientA.request('/index.php')).status, 200);
  check((await clientA.request('/auth/login.php')).status, 302);
  const original = (await clientA.api('dados')).body;
  check(original.version, 0);
  for (const field of ['xp', 'streak', 'totalWorkouts', 'activityMinutes']) check(original.state[field], 0);
  check(original.state.plans, []);
  check(original.state.customExercises, []);
  check(original.state.session, null);
  const state = structuredClone(original.state);
  state.exerciseDefaults['supino-reto'] = { exerciseId: 'supino-reto', sets: 4, reps: 15, weight: 26 };
  state.customExercises.push({ id: 'personalizado-teste', name: 'Exercício pessoal', description: 'Descrição do teste.', howTo: 'Execução do teste.', muscles: ['Peitoral'], muscleGroups: ['peito'], photo: 'data:image/png;base64,iVBORw0KGgo=' });
  state.plans.push({ id: 'treino-teste', name: 'Meu treino', groups: ['Peito'], exercises: [state.exerciseDefaults['supino-reto'], { exerciseId: 'personalizado-teste', sets: 2, reps: 8, weight: 4 }] });
  state.schedule.terca = ['treino-teste'];
  state.xp = 60; state.streak = 1; state.totalWorkouts = 1; state.activityMinutes = 1.25;
  state.completedDates['2026-09-08'] = true;
  state.theme = 'light';
  state.session = { planIds: ['treino-teste'], exercises: state.plans[0].exercises, exerciseIndex: 0, completedSets: 1, paused: true, startedAt: Date.now(), activeMilliseconds: 1200, rewardXp: false };
  check((await clientA.api('dados', { state, version: 0 }, false)).status, 419);
  check((await clientA.api('dados', { state, version: 0 })).status, 200);
  check((await clientA.api('dados')).body.state, state);
  check((await clientA.api('dados', { state, version: 0 })).status, 409);
  const invalid = structuredClone(state);
  invalid.plans[0].exercises[0].sets = -1;
  check((await clientA.api('dados', { state: invalid, version: 1 })).status, 422);
  const overwriteCatalog = structuredClone(state);
  overwriteCatalog.customExercises[0].id = 'supino-reto';
  check((await clientA.api('dados', { state: overwriteCatalog, version: 1 })).status, 422);
  await clientB.api('sessao');
  check((await clientB.api('cadastrar', { name: 'Conta duplicada', email: emails[0], password })).status, 409);
  check((await clientB.api('entrar', { email: emails[0], password: 'senha-incorreta' })).status, 401);
  check((await clientB.api('cadastrar', { name: 'Conta Teste B', email: emails[1], password })).status, 201);
  await clientB.api('sessao');
  check((await clientB.api('dados')).body.state, original.state);
  const remember = clientA.cookies.get('simplegym_lembrar');
  const reopened = new Client();
  reopened.cookies.set('simplegym_lembrar', remember);
  check((await reopened.api('sessao')).body.user.email, emails[0]);
  check((await reopened.api('dados')).body.state, state);
  const tampered = new Client();
  tampered.cookies.set('simplegym_lembrar', remember.slice(0, -1) + (remember.endsWith('a') ? 'b' : 'a'));
  check((await tampered.api('sessao')).body.user, null);
  check((await clientA.api('sair', {}, false)).status, 419);
  check((await clientA.api('sair', {})).status, 200);
  check((await clientA.api('dados')).status, 401);
  check((await clientA.request('/index.php')).status, 302);
  const oldToken = new Client();
  oldToken.cookies.set('simplegym_lembrar', remember);
  check((await oldToken.api('sessao')).body.user, null);
  await clientA.api('sessao');
  check((await clientA.api('entrar', { email: emails[0], password })).status, 200);
  check((await clientA.api('dados')).body.state, state);
  console.log(`${assertions} verificações de integração aprovadas (MySQL real).`);
} finally {
  execFileSync(php, ['-d', `extension_dir=${ext}`, '-d', 'extension=pdo_mysql', fileURLToPath(new URL('./limpar-contas.php', import.meta.url)), ...emails], { stdio: 'inherit' });
}
