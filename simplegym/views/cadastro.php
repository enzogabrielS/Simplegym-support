<?php if (session_status() !== PHP_SESSION_ACTIVE) { http_response_code(404); exit; } ?>
<?php require_once __DIR__ . '/../assets/php/termos.php'; ?>
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="csrf-token" content="<?= htmlspecialchars($_SESSION['csrf'], ENT_QUOTES, 'UTF-8') ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#1b1b1b" />
    <title>Criar conta | SimpleGym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="assets/css/auth.css" />
    <link rel="stylesheet" href="../assets/css/termos.css" />
  </head>
  <body>
    <main class="auth-page">
      <section class="auth-card signup-card" aria-labelledby="auth-title">
        <div class="background-line line-one"></div>
        <div class="background-line line-two"></div>
        <a class="auth-logo" href="../index.php" aria-label="SimpleGym">Simple<span>Gym</span></a>
        <p class="auth-tagline">Seu treino, sua evolução.</p>

        <form class="auth-form" data-auth-form="cadastrar.php" method="post" action="../assets/php/cadastrar.php">
          <div class="form-kicker"><span></span> Criar sua conta</div>
          <h1 id="auth-title">Vamos começar</h1>
          <p class="form-description">Preencha os dados para iniciar sua jornada.</p>

          <label class="field-label" for="signup-name">Nome</label>
          <div class="input-field"><i data-lucide="user-round"></i><input id="signup-name" name="name" autocomplete="name" placeholder="Como podemos chamar você?" minlength="2" maxlength="80" required /></div>

          <label class="field-label" for="signup-email">Email</label>
          <div class="input-field">
            <i data-lucide="mail"></i>
            <input id="signup-email" name="email" type="email" placeholder="Digite seu email" autocomplete="email" maxlength="190" required />
          </div>

          <label class="field-label" for="signup-password">Senha</label>
          <div class="input-field">
            <i data-lucide="lock-keyhole"></i>
            <input id="signup-password" name="password" type="password" placeholder="Crie uma senha" autocomplete="new-password" minlength="8" maxlength="72" required />
            <button class="password-toggle" type="button" data-password-toggle aria-label="Mostrar senha"><i data-lucide="eye"></i></button>
          </div>
          <p class="password-hint">Use de 8 a 72 caracteres. Você continuará conectado neste dispositivo por até 30 dias.</p>
          <p class="auth-error" role="alert" hidden></p>
          <details class="terms-disclosure">
            <summary>Leia o termo de responsabilidade</summary>
            <?php require __DIR__ . '/termos-conteudo.php'; ?>
          </details>
          <label class="terms-acceptance" for="signup-terms">
            <input id="signup-terms" name="termsAccepted" type="checkbox" value="<?= htmlspecialchars(VERSAO_TERMOS, ENT_QUOTES, 'UTF-8') ?>" required />
            <span>Li e aceito o termo de responsabilidade e compreendo os riscos e minha responsabilidade pelas escolhas de treino.</span>
          </label>

          <button class="auth-submit" type="submit">Criar conta <i data-lucide="arrow-right"></i></button>
        </form>

        <div class="divider"><span></span><small>ou</small><span></span></div>
        <a class="secondary-action" href="login.php"><i data-lucide="user-round"></i> Entrar em uma conta</a>
        <span class="footer-dumbbell"><i data-lucide="dumbbell"></i></span>
      </section>
    </main>
    <div class="auth-toast" role="status" aria-live="polite"><i data-lucide="info"></i><span></span></div>
    <script src="https://unpkg.com/lucide@0.468.0/dist/umd/lucide.min.js"></script>
    <script src="../assets/js/api.js"></script>
    <script src="assets/js/auth.js"></script>
  </body>
</html>
