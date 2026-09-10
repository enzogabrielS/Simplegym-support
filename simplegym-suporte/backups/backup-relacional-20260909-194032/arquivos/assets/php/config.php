<?php
// Conexão local. config.local.php permite mudar os valores sem versionar senhas.
$servidor = getenv('SIMPLEGYM_DB_HOST') ?: '127.0.0.1';
$porta = getenv('SIMPLEGYM_DB_PORT') ?: '3306';
$banco = getenv('SIMPLEGYM_DB_NAME') ?: 'simplegym';
$usuario = getenv('SIMPLEGYM_DB_USER') ?: 'root';
$senha = getenv('SIMPLEGYM_DB_PASSWORD') ?: '';

if (is_file(__DIR__ . '/config.local.php')) {
    require __DIR__ . '/config.local.php';
}
