<?php
require __DIR__ . '/funcoes.php';
receberDados();
$cookie = explode(':', $_COOKIE['simplegym_lembrar'] ?? '');
if (count($cookie) === 2) {
    $consulta = conectarBanco()->prepare('DELETE FROM sessoes_persistentes WHERE seletor = ? AND token_hash = ?');
    $consulta->execute([$cookie[0], hash('sha256', $cookie[1])]);
}
$_SESSION = [];
session_destroy();
setcookie('simplegym_lembrar', '', opcoesCookie(time() - 3600));
setcookie(session_name(), '', opcoesCookie(time() - 3600));
responder(['message' => 'Sessão encerrada.']);
