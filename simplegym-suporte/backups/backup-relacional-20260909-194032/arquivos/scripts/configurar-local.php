<?php
// Preparação única do MySQL portátil, somente pelo terminal.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$runtime = $argv[1] ?? '';
if (!is_dir($runtime)) { fwrite(STDERR, "Informe a pasta do ambiente local.\n"); exit(1); }
$arquivo = __DIR__ . '/../assets/php/config.local.php';
if (is_file($arquivo)) { echo "Configuração local já existe.\n"; exit; }
$conecta = new PDO('mysql:host=127.0.0.1;port=3306;charset=utf8mb4', 'root', '', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$conecta->exec(file_get_contents(__DIR__ . '/../database/simplegym.sql'));
$senhaApp = bin2hex(random_bytes(24));
$senhaAdmin = bin2hex(random_bytes(24));
$conecta->exec("CREATE USER 'simplegym_app'@'localhost' IDENTIFIED BY " . $conecta->quote($senhaApp));
$conecta->exec("GRANT SELECT, INSERT, UPDATE, DELETE ON simplegym.* TO 'simplegym_app'@'localhost'");
$conecta->exec("ALTER USER 'root'@'localhost' IDENTIFIED BY " . $conecta->quote($senhaAdmin));
file_put_contents($arquivo, "<?php\n\$servidor = '127.0.0.1';\n\$porta = '3306';\n\$banco = 'simplegym';\n\$usuario = 'simplegym_app';\n\$senha = " . var_export($senhaApp, true) . ";\n");
file_put_contents($runtime . '/admin.cnf', "[client]\nuser=root\npassword=$senhaAdmin\nhost=127.0.0.1\nport=3306\n");
echo "Banco simplegym e usuário da aplicação criados. Senhas salvas somente nos arquivos locais.\n";
