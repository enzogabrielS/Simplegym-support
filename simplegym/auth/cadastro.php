<?php
require __DIR__ . '/../assets/php/funcoes.php';
if (usuarioAtual()) { header('Location: ../index.php'); exit; }
require __DIR__ . '/../views/cadastro.php';
