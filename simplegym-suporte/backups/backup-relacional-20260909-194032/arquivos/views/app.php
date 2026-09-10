<?php if (!isset($usuario['id'])) { http_response_code(404); exit; } ?>
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="csrf-token" content="<?= htmlspecialchars($_SESSION['csrf'], ENT_QUOTES, 'UTF-8') ?>" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="theme-color" content="#1a1a1a" />
    <meta name="description" content="SimpleGym — treinos simples, organizados e feitos para você." />
    <title>SimpleGym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="assets/css/app.css" />
  </head>
  <body class="app-loading">
    <div class="app-load-status" id="app-load-status" role="status"><p>Carregando sua conta…</p><button data-action="reload-app" hidden>Tentar novamente</button></div>
    <div class="save-status" id="save-status" role="status" hidden><span></span><button data-action="retry-save" hidden>Tentar novamente</button></div>
    <main class="app-shell" aria-label="SimpleGym">
      <div class="mobile-app">
        <div class="ambient-line line-top"></div>
        <div class="ambient-line line-bottom"></div>

        <header class="topbar">
          <button class="avatar-button" data-action="open-profile" aria-label="Abrir perfil">SG</button>
          <a class="brand" href="#inicio" aria-label="SimpleGym, início">Simple<span>Gym</span></a>
          <span class="network-status"><i data-lucide="dumbbell"></i></span>
        </header>

        <section class="page active" id="inicio" data-page="home">
          <div class="home-intro">
            <p class="micro-title" id="date-label">HOJE</p>
            <h1>Seu treino,<br /><span>sua evolução.</span></h1>
          </div>

          <article class="streak-strip">
            <div class="streak-fire"><i data-lucide="flame"></i></div>
            <div><strong><span id="streak-number">0</span> dias de sequência</strong><p>Continue treinando para manter acesa.</p></div>
            <span class="xp-badge"><i data-lucide="zap"></i> <span id="xp-number">0</span></span>
          </article>

          <div class="week-days" id="week-days" aria-label="Dias da semana"></div>

          <section class="workout-section">
            <div class="section-title">
              <div><span class="section-marker"></span><h2>Exercícios</h2></div>
              <button class="link-button" data-action="open-workouts">Meus treinos <i data-lucide="arrow-up-right"></i></button>
            </div>
            <p class="day-context" id="day-context"></p>
            <div class="today-list" id="today-list"></div>
            <div class="empty-workout" id="empty-workout" hidden>
              <i data-lucide="calendar-plus"></i>
              <strong>Nenhum treino para este dia</strong>
              <p>Organize os grupos musculares na sua agenda semanal.</p>
              <button class="outline-button" data-action="open-schedule">Organizar agenda</button>
            </div>
          </section>

          <button class="primary-button home-start" id="home-start" data-action="start-day-workout"><i data-lucide="play"></i> Iniciar treino</button>
        </section>

        <section class="page" id="treinos" data-page="workouts">
          <div class="page-heading"><p class="micro-title">PLANEJAMENTO</p><h1>Meus treinos</h1><p>Crie, edite e organize seus treinos como preferir.</p></div>
          <div class="page-tabs" role="tablist">
            <button class="selected" data-tab="exercises">Exercícios</button>
            <button data-tab="saved">Treinos salvos</button>
            <button data-tab="schedule">Agenda semanal</button>
          </div>

          <div class="tab-panel active" data-panel="exercises">
            <article class="exercise-library-intro"><span><i data-lucide="sliders-horizontal"></i></span><div><strong>Exercícios salvos</strong><p>Ajuste séries, repetições e cargas. Personalize também os dados dos exercícios criados por você.</p></div><button class="add-exercise-button" data-action="open-custom-exercise" data-return="library"><i data-lucide="plus"></i> Novo</button></article>
            <div class="saved-exercises" id="saved-exercises"></div>
          </div>

          <div class="tab-panel" data-panel="saved">
            <button class="create-workout" data-action="create-plan"><span><i data-lucide="plus"></i></span><div><strong>Criar treino do zero</strong><small>Monte exercícios, séries e cargas</small></div><i data-lucide="chevron-right"></i></button>
            <p class="list-note" id="plans-count"></p>
            <div class="saved-plans" id="saved-plans"></div>
          </div>

          <div class="tab-panel" data-panel="schedule">
            <article class="schedule-intro"><span><i data-lucide="calendar-days"></i></span><div><strong>Seu ritmo, suas regras.</strong><p>Toque em um dia para definir um ou mais grupos musculares.</p></div></article>
            <div class="schedule-list" id="schedule-list"></div>
          </div>
        </section>

        <section class="page" id="perfil" data-page="profile">
          <div class="page-heading"><p class="micro-title">MINHA CONTA</p><h1>Perfil</h1></div>
          <article class="profile-hero"><span class="profile-avatar">SG</span><div><h2>Meu perfil</h2><p id="profile-level">Nível 1 · Primeiro passo</p><div class="level-bar"><i id="profile-level-progress"></i></div><small><span id="profile-xp">0</span> / <span id="profile-next-xp">120</span> <span id="profile-xp-copy">XP para o nível 2</span></small><em id="profile-level-description">Comece no seu ritmo.</em></div><button class="square-icon" data-action="edit-profile" aria-label="Ver perfil"><i data-lucide="user-round"></i></button></article>
          <div class="profile-stats"><article><strong id="profile-workouts">0</strong><span>treinos</span></article><article><strong id="profile-streak">0</strong><span>dias seguidos</span></article><article><strong id="profile-activity">0min</strong><span>em atividade</span></article></div>
          <section class="settings-block"><p class="micro-title">PREFERÊNCIAS</p><div class="setting-list"><button data-action="goals"><span class="setting-icon yellow"><i data-lucide="target"></i></span><span><strong>Meta semanal</strong><small>4 treinos por semana</small></span><i data-lucide="chevron-right"></i></button><button data-action="reminders"><span class="setting-icon violet"><i data-lucide="bell-ring"></i></span><span><strong>Lembretes</strong><small>Terças e quintas, às 18h</small></span><i data-lucide="chevron-right"></i></button></div></section>
          <section class="settings-block"><p class="micro-title">CONFIGURAÇÕES</p><div class="setting-list"><button data-action="appearance"><span class="setting-icon blue"><i data-lucide="palette"></i></span><span><strong>Aparência</strong><small id="appearance-current">Tema escuro</small></span><i data-lucide="chevron-right"></i></button><button data-action="privacy"><span class="setting-icon gray"><i data-lucide="shield-check"></i></span><span><strong>Privacidade e dados</strong><small>Gerencie suas informações</small></span><i data-lucide="chevron-right"></i></button><button data-action="help"><span class="setting-icon gray"><i data-lucide="circle-help"></i></span><span><strong>Ajuda e suporte</strong><small>Precisa de ajuda?</small></span><i data-lucide="chevron-right"></i></button></div></section>
          <button class="logout" data-action="logout"><i data-lucide="log-out"></i> Sair da conta</button>
        </section>

        <nav class="bottom-nav" aria-label="Navegação principal">
          <button class="nav-item active" data-nav="home"><i data-lucide="house"></i><span>Início</span></button>
          <button class="nav-item" data-nav="workouts"><i data-lucide="dumbbell"></i><span>Meus treinos</span></button>
          <button class="nav-item" data-nav="profile"><i data-lucide="user-round"></i><span>Perfil</span></button>
        </nav>

        <div class="modal-backdrop" id="modal-backdrop" aria-hidden="true">
          <section class="modal" id="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title">
            <button class="modal-close" data-action="close-modal" aria-label="Fechar"><i data-lucide="x"></i></button>
            <div id="modal-content"></div>
          </section>
        </div>
        <div class="toast" id="toast" role="status" aria-live="polite"><i data-lucide="check-circle-2"></i><span></span></div>
      </div>
    </main>

    <script src="https://unpkg.com/lucide@0.468.0/dist/umd/lucide.min.js"></script>
    <script src="assets/js/api.js"></script>
    <script src="assets/js/app.js"></script>
  </body>
</html>
