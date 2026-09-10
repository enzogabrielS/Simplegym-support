(() => {
  const source = document.currentScript.src;
  const base = new URL('../php/', source);
  let csrf = document.querySelector('meta[name="csrf-token"]')?.content || '';
  async function request(file, data) {
    const response = await fetch(new URL(file, base), {
      method: data === undefined ? 'GET' : 'POST',
      credentials: 'same-origin', cache: 'no-store',
      headers: { Accept: 'application/json', ...(data === undefined ? {} : { 'Content-Type': 'application/json', 'X-CSRF-Token': csrf }) },
      ...(data === undefined ? {} : { body: JSON.stringify(data) })
    });
    let result;
    try { result = await response.json(); } catch { throw new Error('Não foi possível acessar o servidor do SimpleGym.'); }
    if (!response.ok) {
      const error = new Error(result.message || 'Não foi possível concluir a operação.');
      error.status = response.status;
      throw error;
    }
    if (result.csrf) csrf = result.csrf;
    return result;
  }
  window.SimpleGymAPI = { request };
})();
