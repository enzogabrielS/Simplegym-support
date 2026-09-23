<?php
require __DIR__ . '/funcoes.php';
$usuario = exigirUsuario();
$dados = receberDados();
$acao = $dados['action'] ?? '';
if (!in_array($acao, ['name', 'password', 'delete'], true)) responder(['message' => 'Operação inválida.'], 422);
$conecta = conectarBanco();
if ($acao === 'name') {
    $nome = is_string($dados['name'] ?? null) ? trim($dados['name']) : '';
    if (strlen($nome) < 2 || strlen($nome) > 80 || preg_match('/[\x00-\x1F\x7F]/', $nome)) responder(['message' => 'Informe um nome entre 2 e 80 bytes, sem caracteres de controle.'], 422);
    $consulta = $conecta->prepare('UPDATE usuarios SET nome = ? WHERE id = ?');
    $consulta->execute([$nome, $usuario['id']]);
    $usuario['nome'] = $nome;
    responder(['message' => 'Nome atualizado.', 'user' => $usuario]);
}
$senha = $dados['currentPassword'] ?? null;
if (!is_string($senha) || strlen($senha) > 72 || $senha === '') responder(['message' => 'Informe sua senha atual.'], 422);
$chave = protegerTentativas('conta:' . $usuario['id']);
if ($acao === 'delete' && ($dados['confirmation'] ?? '') !== 'EXCLUIR') responder(['message' => 'Digite EXCLUIR para confirmar.'], 422);
if ($acao === 'password') {
    $nova = $dados['newPassword'] ?? null;
    if (!is_string($nova) || strlen($nova) < 8 || strlen($nova) > 72 || strpos($nova, "\0") !== false) responder(['message' => 'A nova senha deve ter entre 8 e 72 bytes.'], 422);
    if ($nova !== ($dados['confirmPassword'] ?? null)) responder(['message' => 'As novas senhas não coincidem.'], 422);
    if ($nova === $senha) responder(['message' => 'Escolha uma senha diferente da atual.'], 422);
}
$conecta->beginTransaction();
try {
    $consulta = $conecta->prepare('SELECT senha_hash FROM usuarios WHERE id = ? FOR UPDATE');
    $consulta->execute([$usuario['id']]);
    $hash = $consulta->fetchColumn();
    if (!$hash || !password_verify($senha, $hash)) {
        $conecta->rollBack();
        responder(['message' => 'Senha atual incorreta.'], 403);
    }
    if ($acao === 'password') {
        $consulta = $conecta->prepare('UPDATE usuarios SET senha_hash = ? WHERE id = ?');
        $consulta->execute([password_hash($nova, PASSWORD_DEFAULT), $usuario['id']]);
        $consulta = $conecta->prepare('DELETE FROM sessoes_persistentes WHERE usuario_id = ?');
        $consulta->execute([$usuario['id']]);
    } else {
        // Esta FK não tem CASCADE; remova primeiro os exercícios pessoais.
        // As relações de exercícios e as demais tabelas da conta usam CASCADE.
        $consulta = $conecta->prepare('DELETE FROM exercicios WHERE usuario_id = ?');
        $consulta->execute([$usuario['id']]);
        $consulta = $conecta->prepare('DELETE FROM usuarios WHERE id = ?');
        $consulta->execute([$usuario['id']]);
    }
    $consulta = $conecta->prepare('DELETE FROM tentativas_login WHERE chave = ?');
    $consulta->execute([$chave]);
    $conecta->commit();
} catch (Throwable $erro) {
    if ($conecta->inTransaction()) $conecta->rollBack();
    throw $erro;
}
// Trocar senha também encerra esta sessão. As demais são revogadas pelo hash.
$_SESSION = [];
session_destroy();
setcookie('simplegym_lembrar', '', opcoesCookie(time() - 3600));
setcookie(session_name(), '', opcoesCookie(time() - 3600));
responder(['message' => $acao === 'delete' ? 'Conta excluída.' : 'Senha alterada. Entre novamente.', 'logout' => true]);
