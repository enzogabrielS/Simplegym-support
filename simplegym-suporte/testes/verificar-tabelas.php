<?php
if (PHP_SAPI !== 'cli') exit;
require (getenv('SIMPLEGYM_PROJECT_PATH') ?: dirname(__DIR__, 2) . '/simplegym') . '/assets/php/conexao.php';
$conecta = conectarBanco();
// Este teste de escrita direta só pode executar no banco descartável.
if ($conecta->query('SELECT DATABASE()')->fetchColumn() !== 'simplegym_relational_test') throw new RuntimeException('Execute somente no banco de testes.');
if (($argv[1] ?? '') === '--nome-catalogo') {
    $consulta = $conecta->prepare('UPDATE exercicios SET nome = ? WHERE usuario_id IS NULL AND codigo = ?');
    $consulta->execute([$argv[2], 'supino-reto']);
    exit;
}
function conferir(bool $valor): void { if (!$valor) throw new RuntimeException('Verificação relacional falhou.'); }
conferir((int) $conecta->query("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND data_type = 'json'")->fetchColumn() === 0);
conferir((int) $conecta->query('SELECT COUNT(*) FROM exercicios WHERE usuario_id IS NULL')->fetchColumn() === 11);
foreach (array_slice($argv, 1) as $email) {
    $consulta = $conecta->prepare('SELECT a.versao, a.texto, a.texto_sha256, a.aceito_em FROM aceites_termos a JOIN usuarios u ON u.id = a.usuario_id WHERE u.email = ?');
    $consulta->execute([$email]);
    $aceite = $consulta->fetch();
    conferir($aceite && $aceite['versao'] === '1.0' && hash('sha256', $aceite['texto']) === $aceite['texto_sha256'] && $aceite['aceito_em'] !== null);
    $consulta = $conecta->prepare('SELECT e.id, e.nome, e.foto, e.descricao FROM exercicios e JOIN usuarios u ON e.usuario_id = u.id WHERE u.email = ? AND e.codigo = ?');
    $consulta->execute([$email, 'personalizado-teste']);
    $exercicio = $consulta->fetch();
    conferir((bool) $exercicio && str_starts_with($exercicio['foto'], 'data:image/png;base64,') && strlen($exercicio['descricao']) > 0);
    $consulta = $conecta->prepare('SELECT grupo_id FROM exercicio_grupos WHERE exercicio_id = ?');
    $consulta->execute([$exercicio['id']]);
    conferir($consulta->fetchColumn() === 'peito');
}
conferir((int) $conecta->query('SELECT COUNT(*) FROM treino_exercicios')->fetchColumn() === 2);
conferir((int) $conecta->query('SELECT COUNT(*) FROM treino_sessoes')->fetchColumn() === 1);
echo "Tabelas, colunas, fotos, relações e isolamento conferidos; nenhuma coluna JSON.\n";
