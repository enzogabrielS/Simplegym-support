<?php
require_once __DIR__ . '/conexao.php';

// Catálogo público e exercícios do próprio usuário, nunca os de outra conta.
function listarExercicios(?int $usuarioId = null): array
{
    $conecta = conectarBanco();
    $consulta = $conecta->prepare('SELECT id, codigo, usuario_id, nome, foto, descricao, execucao, tipo FROM exercicios WHERE usuario_id IS NULL OR usuario_id = ? ORDER BY dono, ordem, id');
    $consulta->execute([$usuarioId]);
    $exercicios = [];
    foreach ($consulta as $linha) {
        $item = ['id' => $linha['codigo'], 'name' => $linha['nome'], 'photo' => $linha['foto'],
            'description' => $linha['descricao'], 'howTo' => $linha['execucao'], 'muscleGroups' => [], 'muscles' => []];
        if ($linha['tipo'] === 'cardio') $item['type'] = 'cardio';
        $exercicios[$linha['id']] = ['personalizado' => $linha['usuario_id'] !== null, 'dados' => $item];
    }
    $consulta = $conecta->prepare('SELECT g.exercicio_id, g.grupo_id FROM exercicio_grupos g JOIN exercicios e ON e.id = g.exercicio_id WHERE e.usuario_id IS NULL OR e.usuario_id = ? ORDER BY g.ordem');
    $consulta->execute([$usuarioId]);
    foreach ($consulta as $linha) $exercicios[$linha['exercicio_id']]['dados']['muscleGroups'][] = $linha['grupo_id'];
    $consulta = $conecta->prepare('SELECT m.exercicio_id, m.nome FROM exercicio_musculos m JOIN exercicios e ON e.id = m.exercicio_id WHERE e.usuario_id IS NULL OR e.usuario_id = ? ORDER BY m.ordem');
    $consulta->execute([$usuarioId]);
    foreach ($consulta as $linha) $exercicios[$linha['exercicio_id']]['dados']['muscles'][] = $linha['nome'];
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
