<?php
require __DIR__ . '/funcoes.php';
$dados = receberDados();
$nome = trim((string) ($dados['name'] ?? ''));
$email = strtolower(trim((string) ($dados['email'] ?? '')));
$senha = (string) ($dados['password'] ?? '');
if (strlen($nome) < 2 || strlen($nome) > 80 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190) {
    responder(['message' => 'Informe seu nome e um email válido.'], 422);
}
if (strlen($senha) < 8 || strlen($senha) > 72) responder(['message' => 'A senha deve ter entre 8 e 72 caracteres.'], 422);
protegerTentativas($email);
$conecta = conectarBanco();
try {
    $conecta->beginTransaction();
    $inserir = $conecta->prepare('INSERT INTO usuarios (nome, email, senha_hash) VALUES (?, ?, ?)');
    $inserir->execute([$nome, $email, password_hash($senha, PASSWORD_DEFAULT)]);
    $id = (int) $conecta->lastInsertId();
    $inserir = $conecta->prepare('INSERT INTO perfis_usuario (usuario_id) VALUES (?)');
    $inserir->execute([$id]);
    $conecta->commit();
} catch (PDOException $erro) {
    if ($conecta->inTransaction()) $conecta->rollBack();
    if (($erro->errorInfo[1] ?? 0) === 1062) responder(['message' => 'Este email já possui uma conta. Faça login.'], 409);
    throw $erro;
}
iniciarLogin($id);
responder(['message' => 'Conta criada.'], 201);
