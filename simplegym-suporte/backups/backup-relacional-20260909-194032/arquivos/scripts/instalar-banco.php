<?php
// Execute somente pelo terminal: php scripts/instalar-banco.php
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../assets/php/config.php';
try {
    $conecta = new PDO("mysql:host=$servidor;port=$porta;charset=utf8mb4", $usuario, $senha, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    if (!preg_match('/^[a-zA-Z0-9_]+$/D', $banco)) throw new RuntimeException('Nome de banco inválido.');
    $sql = file_get_contents(__DIR__ . '/../database/simplegym.sql');
    $sql = str_replace(['EXISTS simplegym ', 'USE simplegym;'], ["EXISTS `$banco` ", "USE `$banco`;"], $sql);
    $conecta->exec($sql);
    echo "Banco $banco e tabelas preparados.\n";
} catch (Throwable $erro) {
    fwrite(STDERR, "Não foi possível preparar o banco: " . $erro->getMessage() . "\n");
    exit(1);
}
