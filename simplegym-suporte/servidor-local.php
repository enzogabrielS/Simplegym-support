<?php
$projeto = realpath($_SERVER['DOCUMENT_ROOT']);
$caminho = rawurldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/');
if (preg_match('~(^|/)\.|^/(views|database|scripts|tests)(/|$)|\.(sql|ps1|log|md|cnf)$|/assets/php/(config(?:\.local)?|conexao|funcoes|dados-iniciais|validar-dados|catalogo|repositorio)\.php$~i', $caminho)) {
    http_response_code(404);
    exit;
}
if (preg_match('~^/(index|auth/login|auth/cadastro)\\.html$~', $caminho, $partes)) {
    header('Location: /' . $partes[1] . '.php', true, 302);
    return true;
}
if ($caminho === '/') { require $projeto . '/index.php'; return true; }
$arquivo = realpath($projeto . $caminho);
if (!$arquivo || !is_file($arquivo) || strncmp($arquivo, $projeto . DIRECTORY_SEPARATOR, strlen($projeto) + 1) !== 0) {
    http_response_code(404);
    exit;
}
return false;
