<?php
// Remove somente os emails temporários exatos criados pelo teste de integração.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../assets/php/conexao.php';
$conecta = conectarBanco();
foreach (array_slice($argv, 1) as $email) {
    if (!preg_match('/^teste-[0-9]+-[a-f0-9]{8}-[ab]@simplegym\.test$/D', $email)) throw new RuntimeException('Email de teste inválido.');
    $consulta = $conecta->prepare('DELETE FROM usuarios WHERE email = ?');
    $consulta->execute([$email]);
    $consulta = $conecta->prepare('DELETE FROM tentativas_login WHERE chave = ?');
    $consulta->execute([hash('sha256', '127.0.0.1:' . $email)]);
}
echo "Contas temporárias do teste removidas.\n";
