<?php
require __DIR__ . '/funcoes.php';
require __DIR__ . '/validar-dados.php';
$usuario = exigirUsuario();
$conecta = conectarBanco();
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $consulta = $conecta->prepare('SELECT dados, versao FROM dados_usuario WHERE usuario_id = ?');
    $consulta->execute([$usuario['id']]);
    $registro = $consulta->fetch();
    responder(['state' => $registro ? json_decode($registro['dados']) : dadosIniciais(), 'version' => (int) ($registro['versao'] ?? 0)]);
}
$recebido = receberDados();
validarCondicao(is_array($recebido['state'] ?? null) && is_int($recebido['version'] ?? null));
$dados = validarDados($recebido['state']);
// A identificação vem da sessão, nunca de um ID enviado pelo navegador.
$atualizar = $conecta->prepare('UPDATE dados_usuario SET dados = ?, versao = versao + 1 WHERE usuario_id = ? AND versao = ?');
$atualizar->execute([json_encode($dados, JSON_UNESCAPED_UNICODE), $usuario['id'], $recebido['version']]);
if (!$atualizar->rowCount()) responder(['message' => 'Seus dados mudaram em outra aba. Atualize a página antes de continuar.'], 409);
responder(['message' => 'Alterações salvas.', 'version' => $recebido['version'] + 1]);
