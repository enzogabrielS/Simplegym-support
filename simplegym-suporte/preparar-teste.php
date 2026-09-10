<?php
if (PHP_SAPI !== 'cli') exit;
$config = parse_ini_file($argv[1] ?? 'C:/Users/enzog/Documents/New project/.simplegym-runtime/admin.cnf', true)['client'];
$admin = new PDO('mysql:host=127.0.0.1;port=3306;charset=utf8mb4', $config['user'], $config['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$admin->exec('CREATE DATABASE IF NOT EXISTS simplegym_relational_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
$admin->exec('USE simplegym_relational_test');
$admin->exec(file_get_contents(__DIR__ . '/autenticacao.sql'));
$admin->exec(file_get_contents(__DIR__ . '/estrutura.sql'));
$admin->exec(file_get_contents(__DIR__ . '/catalogo-inicial.sql'));
$admin->exec("GRANT SELECT, INSERT, UPDATE, DELETE ON simplegym_relational_test.* TO 'simplegym_app'@'localhost'");
echo "Banco isolado de testes preparado.\n";
