<?php
// Mesmo padrão dos exemplos da escola: include, PDO, prepare e execute.
function conectarBanco(): PDO
{
    static $conecta;
    if (!$conecta) {
        require __DIR__ . '/config.php';
        $conecta = new PDO(
            "mysql:host=$servidor;port=$porta;dbname=$banco;charset=utf8mb4",
            $usuario,
            $senha,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
             PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
             PDO::ATTR_EMULATE_PREPARES => false]
        );
    }
    return $conecta;
}
