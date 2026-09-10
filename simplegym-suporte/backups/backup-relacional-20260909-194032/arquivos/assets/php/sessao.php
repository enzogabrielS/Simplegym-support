<?php
require __DIR__ . '/funcoes.php';
responder(['user' => usuarioAtual(), 'csrf' => $_SESSION['csrf']]);
