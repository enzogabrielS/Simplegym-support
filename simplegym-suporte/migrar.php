<?php
// Ferramenta de manutenção fora da pasta pública. Requer backup anterior.
if (PHP_SAPI !== 'cli') exit;
$projeto = realpath($argv[1] ?? '');
$backup = $argv[2] ?? '';
$credenciais = $argv[3] ?? '';
if (!$projeto || !is_file($backup) || filesize($backup) < 100 || !is_file($credenciais)) throw new RuntimeException('Informe projeto, backup SQL e arquivo administrativo.');
require $projeto . '/assets/php/config.php';
$config = parse_ini_file($credenciais, true)['client'];
$admin = new PDO("mysql:host=$servidor;port=$porta;dbname=$banco;charset=utf8mb4", $config['user'], $config['password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
$legado = $admin->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'dados_usuario'")->fetchColumn();
if (!$legado) { echo "Banco já está normalizado.\n"; exit; }
$admin->exec(file_get_contents(__DIR__ . '/estrutura.sql'));
$admin->exec(file_get_contents(__DIR__ . '/catalogo-inicial.sql'));
require $projeto . '/assets/php/repositorio.php';
require $projeto . '/assets/php/validar-dados.php';
function responder(array $dados, int $status = 200): void { throw new RuntimeException($dados['message'] ?? 'Dados inválidos'); }
$conecta = conectarBanco();
$conecta->beginTransaction();
$migrados = 0;
try {
    $registros = $conecta->query('SELECT usuario_id, dados, versao FROM dados_usuario FOR UPDATE')->fetchAll();
    foreach ($registros as $registro) {
        $id = (int) $registro['usuario_id'];
        $original = json_decode($registro['dados'], true, 512, JSON_THROW_ON_ERROR);
        $dados = validarDados($original);
        consultar('INSERT INTO perfis_usuario (usuario_id, versao) VALUES (?, ?) ON DUPLICATE KEY UPDATE versao = VALUES(versao)', [$id, $registro['versao']]);
        gravarDadosUsuario($id, $dados);
        $novo = carregarDadosUsuario($id);
        // Compara o estado completo, incluindo ordem e exercícios pessoais.
        if (json_decode(json_encode($novo['state']), true) != $original || $novo['version'] !== (int) $registro['versao']) {
            throw new RuntimeException('Verificação de preservação falhou para a conta ' . $id);
        }
        $migrados++;
    }
    $semPerfil = $conecta->query('SELECT COUNT(*) FROM usuarios u LEFT JOIN perfis_usuario p ON p.usuario_id = u.id WHERE p.usuario_id IS NULL')->fetchColumn();
    if ($semPerfil) throw new RuntimeException('Há contas sem perfil migrado.');
    $conecta->commit();
} catch (Throwable $erro) {
    if ($conecta->inTransaction()) $conecta->rollBack();
    throw $erro;
}
// Só elimina o documento antigo após verificar todos os dados e confirmar o backup.
$admin->exec('DROP TABLE dados_usuario');
echo "$migrados conta(s) migrada(s) e verificadas. Tabela JSON antiga removida; backup preservado.\n";
