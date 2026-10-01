<?php
// Camada de banco do SimpleGym — compatível com PHP 7.4.
// Alterações de estrutura são executadas pelo script de manutenção, nunca ao abrir o site.

// === CONEXÃO E CONFIGURAÇÃO ===
// Mesmo padrão dos exemplos da escola: include, PDO, prepare e execute.
function conectarBanco(): PDO
{
    static $conecta;
    if (!$conecta) {
        // Configuração do banco. Não publique este arquivo com senhas em repositórios públicos.
        
        $servidor = '127.0.0.1';
        $porta = '3306';
        $banco = 'simplegym';
        $usuario = 'root';
        $senha = 'edeaf3a745d1ae8ce27f69492110f189aaa6d1ab6c11701c';
        
        
        // Variáveis do servidor podem substituir a configuração local no deploy/testes.
        foreach (['servidor' => 'SIMPLEGYM_DB_HOST', 'porta' => 'SIMPLEGYM_DB_PORT', 'banco' => 'SIMPLEGYM_DB_NAME', 'usuario' => 'SIMPLEGYM_DB_USER', 'senha' => 'SIMPLEGYM_DB_PASSWORD'] as $campo => $variavel) {
            $valor = getenv($variavel);
            if ($valor !== false) $$campo = $valor;
        }
        
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


// === ESTADO INICIAL ===
function dadosIniciais(): array
{
    return [
        'plans' => [],
        'schedule' => array_fill_keys(['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'], []),
        'customExercises' => [], 'exerciseDefaults' => (object) [],
        'xp' => 0, 'streak' => 0, 'totalWorkouts' => 0, 'activityMinutes' => 0,
        'completedDates' => (object) [], 'freeDayCheckins' => (object) [],
        'theme' => 'dark', 'weightUnit' => 'kg', 'trainingPreference' => 'ambas', 'session' => null
    ];
}


// === CATÁLOGO DE EXERCÍCIOS ===

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


// === LEITURA E GRAVAÇÃO DOS DADOS DO USUÁRIO ===

function consultar(string $sql, array $parametros = []): PDOStatement
{
    $consulta = conectarBanco()->prepare($sql);
    $consulta->execute($parametros);
    return $consulta;
}

function lerConfiguracao(array $linha): array
{
    return ['exerciseId' => $linha['codigo'], 'sets' => (int) $linha['series'],
        'reps' => (int) $linha['repeticoes'], 'weight' => (float) $linha['carga']];
}

function carregarDadosUsuario(int $usuarioId): array
{
    $perfil = consultar('SELECT * FROM perfis_usuario WHERE usuario_id = ?', [$usuarioId])->fetch();
    if (!$perfil) throw new RuntimeException('Perfil não encontrado. Confira a migração do banco.');
    $dados = dadosIniciais();
    $dados['xp'] = (float) $perfil['xp'];
    $dados['streak'] = (float) $perfil['dias_seguidos'];
    $dados['totalWorkouts'] = (float) $perfil['treinos_concluidos'];
    $dados['activityMinutes'] = (float) $perfil['minutos_atividade'];
    $dados['theme'] = $perfil['tema'];
    $dados['weightUnit'] = $perfil['unidade_carga'] ?? 'kg';
    $dados['trainingPreference'] = $perfil['preferencia_treino'];
    foreach (listarExercicios($usuarioId) as $exercicio) {
        if ($exercicio['personalizado']) $dados['customExercises'][] = $exercicio['dados'];
    }
    $treinos = [];
    foreach (consultar('SELECT id, codigo, nome FROM treinos WHERE usuario_id = ? ORDER BY ordem, id', [$usuarioId]) as $treino) {
        $treinos[$treino['id']] = ['id' => $treino['codigo'], 'name' => $treino['nome'], 'groups' => [], 'exercises' => []];
    }
    foreach (consultar('SELECT g.treino_id, g.nome FROM treino_grupos g JOIN treinos t ON t.id = g.treino_id WHERE t.usuario_id = ? ORDER BY g.ordem', [$usuarioId]) as $linha) {
        $treinos[$linha['treino_id']]['groups'][] = $linha['nome'];
    }
    foreach (consultar('SELECT te.*, e.codigo FROM treino_exercicios te JOIN treinos t ON t.id = te.treino_id JOIN exercicios e ON e.id = te.exercicio_id WHERE t.usuario_id = ? AND (e.usuario_id IS NULL OR e.usuario_id = ?) ORDER BY te.ordem', [$usuarioId, $usuarioId]) as $linha) {
        $treinos[$linha['treino_id']]['exercises'][] = lerConfiguracao($linha);
    }
    $dados['plans'] = array_values($treinos);
    foreach (consultar('SELECT a.dia, t.codigo FROM agenda_semanal a JOIN treinos t ON t.id = a.treino_id WHERE a.usuario_id = ? AND t.usuario_id = ? ORDER BY a.ordem', [$usuarioId, $usuarioId]) as $linha) {
        $dados['schedule'][$linha['dia']][] = $linha['codigo'];
    }
    $padroes = [];
    foreach (consultar('SELECT c.*, e.codigo FROM configuracoes_exercicio c JOIN exercicios e ON e.id = c.exercicio_id WHERE c.usuario_id = ? AND (e.usuario_id IS NULL OR e.usuario_id = ?)', [$usuarioId, $usuarioId]) as $linha) {
        $padroes[$linha['codigo']] = lerConfiguracao($linha);
    }
    $dados['exerciseDefaults'] = (object) $padroes;
    $concluidos = []; $checkins = [];
    foreach (consultar('SELECT dia, tipo FROM atividades_diarias WHERE usuario_id = ?', [$usuarioId]) as $linha) {
        if ($linha['tipo'] === 'treino') $concluidos[$linha['dia']] = true;
        else $checkins[$linha['dia']] = true;
    }
    $dados['completedDates'] = (object) $concluidos;
    $dados['freeDayCheckins'] = (object) $checkins;
    $sessao = consultar('SELECT * FROM treino_sessoes WHERE usuario_id = ?', [$usuarioId])->fetch();
    if ($sessao) {
        $dados['session'] = ['planIds' => [], 'exercises' => [], 'exerciseIndex' => (int) $sessao['indice_exercicio'],
            'completedSets' => (int) $sessao['series_concluidas'], 'paused' => (bool) $sessao['pausado'],
            'startedAt' => (int) $sessao['iniciado_em_ms'], 'activeMilliseconds' => (float) $sessao['atividade_ms'], 'rewardXp' => (bool) $sessao['concede_xp']];
        foreach (consultar('SELECT codigo_treino FROM sessao_treinos WHERE usuario_id = ? ORDER BY ordem', [$usuarioId]) as $linha) $dados['session']['planIds'][] = $linha['codigo_treino'];
        foreach (consultar('SELECT se.*, e.codigo FROM sessao_exercicios se JOIN exercicios e ON e.id = se.exercicio_id WHERE se.usuario_id = ? AND (e.usuario_id IS NULL OR e.usuario_id = ?) ORDER BY se.ordem', [$usuarioId, $usuarioId]) as $linha) {
            $config = lerConfiguracao($linha);
            if ($linha['codigo_treino'] !== null) $config['planId'] = $linha['codigo_treino'];
            if ($linha['nome_treino'] !== null) $config['planName'] = $linha['nome_treino'];
            $dados['session']['exercises'][] = $config;
        }
    }
    return ['state' => $dados, 'version' => (int) $perfil['versao']];
}

// Chamado dentro de uma transação, após validar os dados e bloquear o perfil.
function gravarDadosUsuario(int $usuarioId, array $dados): void
{
    $conecta = conectarBanco();
    $mapa = [];
    foreach (consultar('SELECT id, codigo FROM exercicios WHERE usuario_id IS NULL') as $linha) $mapa[$linha['codigo']] = (int) $linha['id'];
    $pessoais = [];
    foreach (consultar('SELECT id, codigo FROM exercicios WHERE usuario_id = ?', [$usuarioId]) as $linha) $pessoais[$linha['codigo']] = (int) $linha['id'];
    foreach ($dados['customExercises'] as $ordem => $exercicio) {
        $id = $pessoais[$exercicio['id']] ?? null;
        $tipo = in_array('cardio', $exercicio['muscleGroups'], true) ? 'cardio' : 'forca';
        $valores = [$exercicio['name'], $exercicio['photo'], $exercicio['description'], $exercicio['howTo'], $tipo, $ordem];
        if ($id) {
            consultar('UPDATE exercicios SET nome = ?, foto = ?, descricao = ?, execucao = ?, tipo = ?, ordem = ? WHERE id = ? AND usuario_id = ?', [...$valores, $id, $usuarioId]);
        } else {
            consultar('INSERT INTO exercicios (nome, foto, descricao, execucao, tipo, ordem, codigo, usuario_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [...$valores, $exercicio['id'], $usuarioId]);
            $id = (int) $conecta->lastInsertId();
        }
        $mapa[$exercicio['id']] = $id;
        unset($pessoais[$exercicio['id']]);
        consultar('DELETE FROM exercicio_grupos WHERE exercicio_id = ?', [$id]);
        consultar('DELETE FROM exercicio_musculos WHERE exercicio_id = ?', [$id]);
        foreach (array_values(array_unique($exercicio['muscleGroups'])) as $posicao => $grupo) consultar('INSERT INTO exercicio_grupos (exercicio_id, grupo_id, ordem) VALUES (?, ?, ?)', [$id, $grupo, $posicao]);
        foreach ($exercicio['muscles'] as $posicao => $musculo) consultar('INSERT INTO exercicio_musculos (exercicio_id, ordem, nome) VALUES (?, ?, ?)', [$id, $posicao, $musculo]);
    }
    // Substitui somente as relações desta conta. Catálogo padrão nunca é alterado aqui.
    consultar('DELETE FROM treino_sessoes WHERE usuario_id = ?', [$usuarioId]);
    consultar('DELETE FROM configuracoes_exercicio WHERE usuario_id = ?', [$usuarioId]);
    consultar('DELETE FROM agenda_semanal WHERE usuario_id = ?', [$usuarioId]);
    $treinosAntigos = [];
    foreach (consultar('SELECT id, codigo FROM treinos WHERE usuario_id = ?', [$usuarioId]) as $linha) $treinosAntigos[$linha['codigo']] = (int) $linha['id'];
    $treinoMapa = [];
    foreach ($dados['plans'] as $ordem => $treino) {
        $id = $treinosAntigos[$treino['id']] ?? null;
        if ($id) {
            consultar('UPDATE treinos SET nome = ?, ordem = ? WHERE id = ? AND usuario_id = ?', [$treino['name'], $ordem, $id, $usuarioId]);
            consultar('DELETE FROM treino_grupos WHERE treino_id = ?', [$id]);
            consultar('DELETE FROM treino_exercicios WHERE treino_id = ?', [$id]);
        } else {
            consultar('INSERT INTO treinos (usuario_id, codigo, nome, ordem) VALUES (?, ?, ?, ?)', [$usuarioId, $treino['id'], $treino['name'], $ordem]);
            $id = (int) $conecta->lastInsertId();
        }
        unset($treinosAntigos[$treino['id']]);
        $treinoMapa[$treino['id']] = $id;
        foreach ($treino['groups'] as $posicao => $grupo) consultar('INSERT INTO treino_grupos (treino_id, ordem, nome) VALUES (?, ?, ?)', [$id, $posicao, $grupo]);
        foreach ($treino['exercises'] as $posicao => $config) consultar('INSERT INTO treino_exercicios (treino_id, ordem, exercicio_id, series, repeticoes, carga) VALUES (?, ?, ?, ?, ?, ?)', [$id, $posicao, $mapa[$config['exerciseId']], $config['sets'], $config['reps'], $config['weight']]);
    }
    foreach ($treinosAntigos as $id) consultar('DELETE FROM treinos WHERE id = ? AND usuario_id = ?', [$id, $usuarioId]);
    foreach ($pessoais as $id) consultar('DELETE FROM exercicios WHERE id = ? AND usuario_id = ?', [$id, $usuarioId]);
    foreach ($dados['schedule'] as $dia => $treinos) {
        foreach ($treinos as $ordem => $codigo) consultar('INSERT INTO agenda_semanal (usuario_id, dia, treino_id, ordem) VALUES (?, ?, ?, ?)', [$usuarioId, $dia, $treinoMapa[$codigo], $ordem]);
    }
    foreach ((array) $dados['exerciseDefaults'] as $config) consultar('INSERT INTO configuracoes_exercicio (usuario_id, exercicio_id, series, repeticoes, carga) VALUES (?, ?, ?, ?, ?)', [$usuarioId, $mapa[$config['exerciseId']], $config['sets'], $config['reps'], $config['weight']]);
    consultar('DELETE FROM atividades_diarias WHERE usuario_id = ?', [$usuarioId]);
    foreach (['completedDates' => 'treino', 'freeDayCheckins' => 'checkin'] as $campo => $tipo) {
        foreach ((array) $dados[$campo] as $dia => $feito) consultar('INSERT INTO atividades_diarias (usuario_id, dia, tipo) VALUES (?, ?, ?)', [$usuarioId, $dia, $tipo]);
    }
    $sessao = $dados['session'];
    if ($sessao) {
        consultar('INSERT INTO treino_sessoes (usuario_id, indice_exercicio, series_concluidas, pausado, iniciado_em_ms, atividade_ms, concede_xp) VALUES (?, ?, ?, ?, ?, ?, ?)', [$usuarioId, $sessao['exerciseIndex'], $sessao['completedSets'], (int) $sessao['paused'], $sessao['startedAt'], $sessao['activeMilliseconds'], (int) ($sessao['rewardXp'] ?? true)]);
        foreach ($sessao['planIds'] as $ordem => $codigo) consultar('INSERT INTO sessao_treinos (usuario_id, ordem, codigo_treino) VALUES (?, ?, ?)', [$usuarioId, $ordem, $codigo]);
        foreach ($sessao['exercises'] as $ordem => $config) consultar('INSERT INTO sessao_exercicios (usuario_id, ordem, exercicio_id, codigo_treino, nome_treino, series, repeticoes, carga) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$usuarioId, $ordem, $mapa[$config['exerciseId']], $config['planId'] ?? null, $config['planName'] ?? null, $config['sets'], $config['reps'], $config['weight']]);
    }
    consultar('UPDATE perfis_usuario SET xp = ?, dias_seguidos = ?, treinos_concluidos = ?, minutos_atividade = ?, tema = ? WHERE usuario_id = ?', [$dados['xp'], $dados['streak'], $dados['totalWorkouts'], $dados['activityMinutes'], $dados['theme'], $usuarioId]);
    if (isset($dados['weightUnit'])) {
        consultar('UPDATE perfis_usuario SET unidade_carga = ? WHERE usuario_id = ?', [$dados['weightUnit'], $usuarioId]);
    }
    if (isset($dados['trainingPreference'])) {
        consultar('UPDATE perfis_usuario SET preferencia_treino = ? WHERE usuario_id = ?', [$dados['trainingPreference'], $usuarioId]);
    }
}
