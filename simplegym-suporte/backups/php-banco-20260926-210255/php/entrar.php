<?php
require __DIR__ . '/funcoes.php';
$dados = receberDados();
$email = strtolower(trim((string) ($dados['email'] ?? '')));
$senha = (string) ($dados['password'] ?? '');
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190 || strlen($senha) > 72) responder(['message' => 'Email ou senha inválidos.'], 422);
$chave = protegerTentativas($email);
$conecta = conectarBanco();
$consulta = $conecta->prepare('SELECT id, senha_hash FROM usuarios WHERE email = ?');
$consulta->execute([$email]);
$usuario = $consulta->fetch();
$hash = $usuario['senha_hash'] ?? '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.';
if (!password_verify($senha, $hash) || !$usuario) responder(['message' => 'Email ou senha incorretos.'], 401);
$consulta = $conecta->prepare('DELETE FROM tentativas_login WHERE chave = ?');
$consulta->execute([$chave]);
iniciarLogin((int) $usuario['id']);
responder(['message' => 'Login realizado.']);
