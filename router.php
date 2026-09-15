<?php
$caminho = rawurldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/');
if (preg_match('~(^|/)\.|^/(views|database|scripts|tests)(/|$)|\.(sql|ps1|log|md|cnf)$|/assets/php/(config(?:\.local)?|conexao|funcoes|dados-iniciais|validar-dados)\.php$~i', $caminho)) {
    http_response_code(404);
    exit;
}
if ($caminho === '/') { require __DIR__ . '/simplegym/index.php'; return true; }
return false;
