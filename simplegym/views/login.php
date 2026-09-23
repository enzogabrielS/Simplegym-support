<?php if (session_status() !== PHP_SESSION_ACTIVE) { http_response_code(404); exit; } ?>
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="csrf-token" content="<?= htmlspecialchars($_SESSION['csrf'], ENT_QUOTES, 'UTF-8') ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#1b1b1b" />
    <title>Entrar | SimpleGym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="assets/css/auth.css" />
  </head>
  <body>
    <main class="auth-page">
      <section class="auth-card" aria-labelledby="auth-title">
        <div class="background-line line-one"></div>
        <div class="background-line line-two"></div>
        <a class="auth-logo" href="../index.php" aria-label="SimpleGym">Simple<span>Gym</span></a>
        <p class="auth-tagline">Seu treino, sua evolução.</p>

        <form class="auth-form" data-auth-form="entrar.php" method="post" action="../assets/php/entrar.php">
          <h1 id="auth-title">Entre na sua conta</h1>
          <p class="form-description">Continue de onde parou.</p>

          <label class="field-label" for="login-email">Email</label>
          <div class="input-field">
            <i data-lucide="mail"></i>
            <input id="login-email" name="email" type="email" placeholder="Digite seu email" autocomplete="email" maxlength="190" required />
          </div>

          <div class="field-row">
            <label class="field-label" for="login-password">Senha</label>
          </div>
          <div class="input-field">
            <i data-lucide="lock-keyhole"></i>
            <input id="login-password" name="password" type="password" placeholder="Digite sua senha" autocomplete="current-password" maxlength="72" required />
            <button class="password-toggle" type="button" data-password-toggle aria-label="Mostrar senha"><i data-lucide="eye"></i></button>
          </div>

          <p class="password-hint">Sua conta continuará conectada neste dispositivo por até 30 dias, até você sair.</p>
          <p class="auth-error" role="alert" hidden></p>
          <button class="auth-submit" type="submit">Entrar <i data-lucide="arrow-right"></i></button>
        </form>

        <div class="divider"><span></span><small>ou</small><span></span></div>
        <a class="secondary-action" href="cadastro.php"><i data-lucide="user-round-plus"></i> Criar conta</a>
        <span class="footer-dumbbell"><i data-lucide="dumbbell"></i></span>
      </section>
    </main>
    <div class="auth-toast" role="status" aria-live="polite"><i data-lucide="info"></i><span></span></div>
    <script src="https://unpkg.com/lucide@0.468.0/dist/umd/lucide.min.js"></script>
    <script src="../assets/js/api.js"></script>
    <script src="assets/js/auth.js"></script>
  </body>
</html>
