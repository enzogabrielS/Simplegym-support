<?php
require_once __DIR__ . '/conexao.php';

// Catálogo público e exercícios do próprio usuário, nunca os de outra conta.
function listarExercicios(?int $usuarioId = null): array
{
    $conecta = conectarBanco();
    $consulta = $conecta->prepare('SELECT * FROM exercicios WHERE usuario_id IS NULL OR usuario_id = ? ORDER BY dono, ordem, id');
    $consulta->execute([$usuarioId]);
    $exercicios = [];
    foreach ($consulta as $linha) {
        $item = ['id' => $linha['codigo'], 'name' => $linha['nome'], 'photo' => $linha['foto'],
            'description' => $linha['descricao'], 'howTo' => $linha['execucao'], 'muscleGroups' => [], 'muscles' => []];
        if ($linha['tipo'] === 'cardio') $item['type'] = 'cardio';
        if ($linha['usuario_id'] === null) {
            $item['modality'] = $linha['modalidade'];
            $item['anatomeId'] = $linha['anatome_id'];
            $item['diagram'] = $linha['diagrama_url'];
            $item['videoUrl'] = $linha['video_url'];
            $item['equipment'] = $linha['equipamento'];
            $item['level'] = $linha['nivel_api'];
            $item['category'] = $linha['categoria_api'];
            $item['instructionsLanguage'] = $linha['idioma_instrucoes'];
            $item['primaryMuscles'] = [];
            $item['secondaryMuscles'] = [];
            $item['instructions'] = [];
        }
        $exercicios[$linha['id']] = ['personalizado' => $linha['usuario_id'] !== null, 'dados' => $item];
    }
    $consulta = $conecta->prepare('SELECT g.exercicio_id, g.grupo_id FROM exercicio_grupos g JOIN exercicios e ON e.id = g.exercicio_id WHERE e.usuario_id IS NULL OR e.usuario_id = ? ORDER BY g.ordem');
    $consulta->execute([$usuarioId]);
    foreach ($consulta as $linha) $exercicios[$linha['exercicio_id']]['dados']['muscleGroups'][] = $linha['grupo_id'];
    $consulta = $conecta->prepare('SELECT m.exercicio_id, m.nome FROM exercicio_musculos m JOIN exercicios e ON e.id = m.exercicio_id WHERE e.usuario_id IS NULL OR e.usuario_id = ? ORDER BY m.ordem');
    $consulta->execute([$usuarioId]);
    foreach ($consulta as $linha) $exercicios[$linha['exercicio_id']]['dados']['muscles'][] = $linha['nome'];
    foreach ($conecta->query('SELECT a.* FROM exercicio_anatomia a JOIN exercicios e ON e.id=a.exercicio_id WHERE e.usuario_id IS NULL ORDER BY a.ordem') as $linha) {
        $campo = $linha['papel'] === 'primario' ? 'primaryMuscles' : 'secondaryMuscles';
        $exercicios[$linha['exercicio_id']]['dados'][$campo][] = $linha['musculo'];
    }
    foreach ($conecta->query('SELECT i.* FROM exercicio_instrucoes i JOIN exercicios e ON e.id=i.exercicio_id WHERE e.usuario_id IS NULL ORDER BY i.ordem') as $linha) {
        $exercicios[$linha['exercicio_id']]['dados']['instructions'][] = $linha['instrucao'];
    }
    return $exercicios;
}

function carregarCatalogo(): array
{
    $conecta = conectarBanco();
    $exercicios = array_map(fn($item) => $item['dados'], array_values(listarExercicios()));
    $grupos = $conecta->query('SELECT id, nome AS name, descricao AS description FROM grupos_musculares ORDER BY ordem, id')->fetchAll();
    $niveis = $conecta->query('SELECT nivel AS level, xp_minimo AS minXp, titulo AS title, descricao AS description FROM niveis ORDER BY xp_minimo')->fetchAll();
    return ['exercises' => $exercicios, 'muscleGroups' => $grupos, 'levels' => $niveis];
}
