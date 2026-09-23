const toast = document.querySelector('.auth-toast');
let toastTimeout;

function showToast(message) {
  toast.querySelector('span').textContent = message;
  toast.classList.add('show');
  clearTimeout(toastTimeout);
  toastTimeout = setTimeout(() => toast.classList.remove('show'), 2800);
}

document.querySelectorAll('[data-password-toggle]').forEach(button => {
  button.addEventListener('click', () => {
    const input = button.parentElement.querySelector('input');
    const isHidden = input.type === 'password';
    input.type = isHidden ? 'text' : 'password';
    button.setAttribute('aria-label', isHidden ? 'Ocultar senha' : 'Mostrar senha');
    button.innerHTML = `<i data-lucide="${isHidden ? 'eye-off' : 'eye'}"></i>`;
    window.lucide?.createIcons();
  });
});

document.querySelectorAll('[data-auth-form]').forEach(form => {
  form.addEventListener('submit', async event => {
    event.preventDefault();
    const button = form.querySelector('[type="submit"]');
    if (button.disabled || !form.reportValidity()) return;
    const errorBox = form.querySelector('.auth-error');
    errorBox.hidden = true;
    button.disabled = true;
    button.setAttribute('aria-busy', 'true');
    try {
      await SimpleGymAPI.request(form.dataset.authForm, Object.fromEntries(new FormData(form)));
      window.location.replace('../index.php');
    } catch (error) {
      errorBox.textContent = error.message || 'Confira a conexão e tente novamente.';
      errorBox.hidden = false;
      button.disabled = false;
      button.removeAttribute('aria-busy');
    }
  });
});


document.addEventListener('dblclick', event => event.preventDefault(), { passive: false });
window.lucide?.createIcons();
