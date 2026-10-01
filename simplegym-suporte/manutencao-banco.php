<?php
// Somente terminal: php manutencao-banco.php --check (ou --apply).
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$app = getenv('SIMPLEGYM_APP') ?: dirname(__DIR__) . '/simplegym';
$support = getenv('SIMPLEGYM_SUPPORT') ?: __DIR__;
require $app . '/assets/php/banco.php';
$db = conectarBanco();
$alteracoes = [
    'perfis_usuario' => [
        'unidade_carga' => "ENUM('kg','lb') NOT NULL DEFAULT 'kg'",
        'preferencia_treino' => "ENUM('musculacao','calistenia','ambas') NOT NULL DEFAULT 'ambas'"
    ],
    'exercicios' => [
        'modalidade' => "ENUM('musculacao','calistenia','ambas') NOT NULL DEFAULT 'ambas'",
        'anatome_id' => 'VARCHAR(180) NULL', 'categoria_api' => 'VARCHAR(100) NULL',
        'equipamento' => 'VARCHAR(100) NULL', 'nivel_api' => 'VARCHAR(80) NULL',
        'diagrama_url' => 'TEXT NULL', 'video_url' => 'TEXT NULL',
        'idioma_instrucoes' => 'VARCHAR(12) NULL', 'atualizado_anatome_em' => 'TIMESTAMP NULL'
    ]
];
$pendentes = [];
foreach ($alteracoes as $tabela => $colunas) {
    $existentes = $db->query("SHOW COLUMNS FROM `$tabela`")->fetchAll(PDO::FETCH_COLUMN);
    foreach ($colunas as $coluna => $tipo) {
        if (!in_array($coluna, $existentes, true)) $pendentes[] = "ALTER TABLE `$tabela` ADD COLUMN `$coluna` $tipo";
    }
}
$tabelas = $db->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
foreach (['exercicio_anatomia', 'exercicio_instrucoes'] as $tabela) {
    if (!in_array($tabela, $tabelas, true)) echo "Tabela ausente: $tabela\n";
}
echo 'Colunas pendentes: ' . count($pendentes) . PHP_EOL;
if (($argv[1] ?? '--check') !== '--apply') exit;

// Não cria/reinicia um banco. Adiciona somente campos e tabelas conhecidos.
$lock = $app . '/assets/php/.maintenance';
$lockHandle = @fopen($lock, 'x');
if (!$lockHandle) throw new RuntimeException('Já existe uma manutenção em andamento.');
fclose($lockHandle);
$backupDir = $support . '/backups/banco-' . date('Ymd-His');
try {
    if (!mkdir($backupDir, 0700, true)) throw new RuntimeException('Falha ao criar pasta de backup.');
    // Snapshot consistente das tabelas InnoDB. Não inclui senhas na saída do terminal.
    $dump = fopen($backupDir . '/antes.sql', 'x');
    if (!$dump) throw new RuntimeException('Não foi possível abrir o backup.');
    $write = function ($text) use ($dump) {
        if (fwrite($dump, $text) !== strlen($text)) throw new RuntimeException('Backup incompleto. Verifique o espaço em disco.');
    };
    $db->beginTransaction();
    $write("-- Restaurar em banco vazio selecionado. Contém dados privados: guarde com segurança.\nSET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\n");
    foreach ($tabelas as $tabela) {
        $safe = '`' . str_replace('`', '``', $tabela) . '`';
        $schema = $db->query("SHOW CREATE TABLE $safe")->fetch(PDO::FETCH_NUM);
        $write($schema[1] . ";\n");
        $cols = [];
        foreach ($db->query("SHOW COLUMNS FROM $safe") as $col) {
            if (!preg_match('/(?:STORED|VIRTUAL) GENERATED/', $col['Extra'])) $cols[] = '`' . str_replace('`', '``', $col['Field']) . '`';
        }
        $list = implode(',', $cols);
        foreach ($db->query("SELECT $list FROM $safe") as $row) {
            $values = array_map(function ($v) use ($db) { return $v === null ? 'NULL' : $db->quote((string) $v); }, array_values($row));
            $write("INSERT INTO $safe ($list) VALUES (" . implode(',', $values) . ");\n");
        }
    }
    $write("SET FOREIGN_KEY_CHECKS=1;\n");
    fflush($dump);
    fclose($dump);
    $db->commit();
    foreach ($pendentes as $sql) $db->exec($sql);
    $schema = file_get_contents($support . '/atualizacao-anatome/estrutura-anatome.sql');
    if (!preg_match_all('/CREATE TABLE IF NOT EXISTS .*?ENGINE=InnoDB[^;]*;/s', $schema, $matches) || count($matches[0]) !== 2) throw new RuntimeException('Estrutura complementar inválida.');
    foreach ($matches[0] as $sql) $db->exec($sql);
    $catalog = file_get_contents($support . '/atualizacao-anatome/catalogo-anatome.sql');
    if (!$catalog) throw new RuntimeException('Catálogo não encontrado.');
    $db->exec($catalog);
    echo "Atualização concluída. Backup: $backupDir/antes.sql\n";
} finally {
    if ($db->inTransaction()) $db->rollBack();
    unlink($lock);
}
