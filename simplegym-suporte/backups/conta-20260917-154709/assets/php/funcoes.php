<?php
if (is_file(__DIR__ . '/.maintenance')) {
    http_response_code(503);
    header('Content-Type: application/json; charset=UTF-8');
    header('Retry-After: 30');
    echo '{"message":"Atualização do banco em andamento. Tente novamente em instantes."}';
    exit;
}
require_once __DIR__ . '/conexao.php';
require_once __DIR__ . '/dados-iniciais.php';

ini_set('display_errors', '0');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');

function opcoesCookie(int $expira = 0): array
{
    return ['expires' => $expira, 'path' => '/',
        'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
        'httponly' => true, 'samesite' => 'Lax'];
}
session_name('simplegym_session');
$opcoes = opcoesCookie();
unset($opcoes['expires']);
session_set_cookie_params($opcoes);
session_start();
if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));

function responder(array $dados, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode($dados, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}
set_exception_handler(function (Throwable $erro) {
    error_log('SimpleGym: ' . $erro->getMessage());
    responder(['message' => 'Não foi possível acessar o serviço. Verifique se o banco de dados está ligado.'], 503);
});
function receberDados(): array
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') responder(['message' => 'Método não permitido.'], 405);
    if (!hash_equals($_SESSION['csrf'], $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '')) {
        responder(['message' => 'Sua sessão mudou. Atualize a página e tente novamente.'], 419);
    }
    $texto = file_get_contents('php://input', false, null, 0, 12000001);
    if (strlen($texto) > 12000000) responder(['message' => 'As imagens ultrapassaram o limite de armazenamento desta requisição.'], 413);
    $dados = json_decode($texto, true);
    if (!is_array($dados)) responder(['message' => 'Dados inválidos.'], 422);
    return $dados;
}
function usuarioAtual(): ?array
{
    $conecta = conectarBanco();
    if (!empty($_SESSION['usuario_id'])) {
        $consulta = $conecta->prepare('SELECT id, nome, email FROM usuarios WHERE id = ?');
        $consulta->execute([$_SESSION['usuario_id']]);
        $usuario = $consulta->fetch();
        if ($usuario) return $usuario;
        unset($_SESSION['usuario_id']);
    }
    $cookie = $_COOKIE['simplegym_lembrar'] ?? '';
    if (!preg_match('/^([a-f0-9]{24}):([a-f0-9]{64})$/D', $cookie, $partes)) return null;
    $consulta = $conecta->prepare('SELECT s.token_hash, u.id, u.nome, u.email FROM sessoes_persistentes s JOIN usuarios u ON u.id = s.usuario_id WHERE s.seletor = ? AND s.expira_em > UTC_TIMESTAMP()');
    $consulta->execute([$partes[1]]);
    $usuario = $consulta->fetch();
    if (!$usuario || !hash_equals($usuario['token_hash'], hash('sha256', $partes[2]))) {
        setcookie('simplegym_lembrar', '', opcoesCookie(time() - 3600));
        return null;
    }
    unset($usuario['token_hash']);
    session_regenerate_id(true);
    $_SESSION['usuario_id'] = (int) $usuario['id'];
    return $usuario;
}
function exigirUsuario(bool $api = true): array
{
    $usuario = usuarioAtual();
    if (!$usuario) {
        if ($api) responder(['message' => 'Entre na sua conta para continuar.'], 401);
        header('Location: auth/login.php');
        exit;
    }
    return $usuario;
} 
function iniciarLogin(int $id): void
{
    session_regenerate_id(true);
    $_SESSION['usuario_id'] = $id;
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
    $seletor = bin2hex(random_bytes(12));
    $token = bin2hex(random_bytes(32));
    $conecta = conectarBanco();
    $consulta = $conecta->prepare('INSERT INTO sessoes_persistentes (seletor, usuario_id, token_hash, expira_em) VALUES (?, ?, ?, ?)');
    $consulta->execute([$seletor, $id, hash('sha256', $token), gmdate('Y-m-d H:i:s', time() + 30 * 86400)]);
    setcookie('simplegym_lembrar', "$seletor:$token", opcoesCookie(time() + 30 * 86400));
}
function protegerTentativas(string $email): string
{
    $chave = hash('sha256', ($_SERVER['REMOTE_ADDR'] ?? '') . ':' . $email);
    $conecta = conectarBanco();
    $consulta = $conecta->prepare('DELETE FROM tentativas_login WHERE chave = ? AND inicio < UTC_TIMESTAMP() - INTERVAL 15 MINUTE');
    $consulta->execute([$chave]);
    $consulta = $conecta->prepare('INSERT INTO tentativas_login (chave, tentativas, inicio) VALUES (?, 1, UTC_TIMESTAMP()) ON DUPLICATE KEY UPDATE tentativas = tentativas + 1');
    $consulta->execute([$chave]);
    $consulta = $conecta->prepare('SELECT tentativas FROM tentativas_login WHERE chave = ?');
    $consulta->execute([$chave]);
    if ($consulta->fetchColumn() > 10) responder(['message' => 'Muitas tentativas. Aguarde 15 minutos e tente novamente.'], 429);
    return $chave;
}
