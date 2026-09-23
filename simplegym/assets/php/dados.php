<?php
require __DIR__ . '/funcoes.php';
require __DIR__ . '/validar-dados.php';
require __DIR__ . '/repositorio.php';
$usuario = exigirUsuario();
$conecta = conectarBanco();
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Uma leitura consistente mesmo que outra aba grave entre as consultas.
    $conecta->beginTransaction();
    try {
        $resposta = carregarDadosUsuario((int) $usuario['id']);
        $resposta['catalog'] = carregarCatalogo();
        $conecta->commit();
    } catch (Throwable $erro) {
        $conecta->rollBack();
        throw $erro;
    }
    responder($resposta);
}
$recebido = receberDados();
validarCondicao(is_array($recebido['state'] ?? null) && is_int($recebido['version'] ?? null));
$dados = validarDados($recebido['state']);
$conecta->beginTransaction();
try {
    $consulta = consultar('SELECT versao FROM perfis_usuario WHERE usuario_id = ? FOR UPDATE', [$usuario['id']]);
    $versao = $consulta->fetchColumn();
    if ($versao === false || (int) $versao !== $recebido['version']) {
        $conecta->rollBack();
        responder(['message' => 'Seus dados mudaram em outra aba. Atualize a página antes de continuar.'], 409);
    }
    gravarDadosUsuario((int) $usuario['id'], $dados);
    consultar('UPDATE perfis_usuario SET versao = versao + 1 WHERE usuario_id = ?', [$usuario['id']]);
    $conecta->commit();
} catch (Throwable $erro) {
    if ($conecta->inTransaction()) $conecta->rollBack();
    throw $erro;
}
responder(['message' => 'Alterações salvas.', 'version' => $recebido['version'] + 1]);
