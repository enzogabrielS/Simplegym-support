<?php
require_once __DIR__ . '/catalogo.php';
// Validação dos campos recebidos pelo JavaScript antes de gravar no MySQL.
// Equivalente a array_is_list(), sem exigir PHP 8.1.
function listaSequencial(array $itens): bool
{
    $indice = 0;
    foreach ($itens as $chave => $valor) {
        if ($chave !== $indice) return false;
        $indice++;
    }
    return true;
}

function validarCondicao(bool $valida): void
{
    if (!$valida) responder(['message' => 'Os dados do treino são inválidos. Confira os campos.'], 422);
}
function numeroValido($valor, float $min, float $max): bool
{
    return (is_int($valor) || is_float($valor)) && is_finite((float) $valor) && $valor >= $min && $valor <= $max;
}
function textoValido($valor, int $max): bool
{
    return is_string($valor) && strlen(trim($valor)) > 0 && strlen($valor) <= $max;
}
function idValido($valor): bool
{
    return is_string($valor) && (bool) preg_match('/^[a-zA-Z0-9_-]{1,100}$/D', $valor);
}
function validarConfiguracao(array $config, array $ids): void
{
    validarCondicao(in_array($config['exerciseId'] ?? null, $ids, true));
    validarCondicao(numeroValido($config['sets'] ?? null, 1, 100) && is_int($config['sets']));
    validarCondicao(numeroValido($config['reps'] ?? null, 1, 10000) && is_int($config['reps']));
    validarCondicao(numeroValido($config['weight'] ?? null, 0, 10000));
}
function validarDados(array $dados): array
{
    $resultado = dadosIniciais();
    $catalogoBanco = carregarCatalogo();
    $catalogo = $catalogoBanco['exercises'];
    $grupos = $catalogoBanco['muscleGroups'];
    $ids = array_column($catalogo, 'id');
    $grupoIds = array_column($grupos, 'id');
    $customizados = $dados['customExercises'] ?? [];
    validarCondicao(is_array($customizados) && listaSequencial($customizados) && count($customizados) <= 200);
    foreach ($customizados as $exercicio) {
        validarCondicao(is_array($exercicio) && idValido($exercicio['id'] ?? null));
        validarCondicao(!in_array($exercicio['id'], $ids, true));
        foreach (['name' => 180, 'description' => 1200, 'howTo' => 1600] as $campo => $max) {
            validarCondicao(textoValido($exercicio[$campo] ?? null, $max));
        }
        $foto = $exercicio['photo'] ?? '';
        validarCondicao(is_string($foto) && strlen($foto) <= 2000000 && (
            (filter_var($foto, FILTER_VALIDATE_URL) && in_array(strtolower(parse_url($foto, PHP_URL_SCHEME) ?? ''), ['http', 'https'])) ||
            preg_match('~^data:image/(jpeg|png|webp);base64,[A-Za-z0-9+/=]+$~D', $foto)
        ));
        validarCondicao(is_array($exercicio['muscleGroups'] ?? null) && listaSequencial($exercicio['muscleGroups']) && count($exercicio['muscleGroups']) > 0);
        foreach ($exercicio['muscleGroups'] as $grupo) validarCondicao(is_string($grupo) && in_array($grupo, $grupoIds, true));
        validarCondicao(is_array($exercicio['muscles'] ?? null) && count($exercicio['muscles']) > 0 && count($exercicio['muscles']) <= 30);
        foreach ($exercicio['muscles'] as $musculo) validarCondicao(textoValido($musculo, 200));
        $exercicio['muscleGroups'] = array_values(array_unique($exercicio['muscleGroups']));
        $ids[] = $exercicio['id'];
    }
    $resultado['customExercises'] = $customizados;
    $treinos = $dados['plans'] ?? [];
    validarCondicao(is_array($treinos) && listaSequencial($treinos) && count($treinos) <= 100);
    $treinoIds = [];
    foreach ($treinos as $treino) {
        validarCondicao(is_array($treino) && idValido($treino['id'] ?? null) && textoValido($treino['name'] ?? null, 180));
        validarCondicao(!in_array($treino['id'], $treinoIds, true));
        $treinoIds[] = $treino['id'];
        validarCondicao(is_array($treino['groups'] ?? null) && count($treino['groups']) > 0 && count($treino['groups']) <= 30);
        foreach ($treino['groups'] as $grupo) validarCondicao(textoValido($grupo, 260));
        validarCondicao(is_array($treino['exercises'] ?? null) && count($treino['exercises']) > 0 && count($treino['exercises']) <= 200);
        foreach ($treino['exercises'] as $config) { validarCondicao(is_array($config)); validarConfiguracao($config, $ids); }
    }
    $resultado['plans'] = $treinos;
    validarCondicao(is_array($dados['schedule'] ?? null));
    foreach ($resultado['schedule'] as $dia => $vazio) {
        $programados = $dados['schedule'][$dia] ?? [];
        validarCondicao(is_array($programados) && listaSequencial($programados) && count($programados) <= 100);
        foreach ($programados as $codigo) validarCondicao(is_string($codigo) && in_array($codigo, $treinoIds, true));
        $resultado['schedule'][$dia] = array_values(array_unique($programados));
    }
    foreach (['xp', 'streak', 'totalWorkouts', 'activityMinutes'] as $campo) {
        validarCondicao(numeroValido($dados[$campo] ?? null, 0, 100000000));
        if ($campo !== 'activityMinutes') validarCondicao(floor($dados[$campo]) == $dados[$campo]);
        $resultado[$campo] = $dados[$campo];
    }
    foreach (['completedDates', 'freeDayCheckins'] as $campo) {
        validarCondicao(is_array($dados[$campo] ?? null));
        foreach ($dados[$campo] as $dia => $valor) {
            validarCondicao((bool) preg_match('/^\d{4}-\d{2}-\d{2}$/D', (string) $dia) && $valor === true);
            $partes = explode('-', (string) $dia);
            validarCondicao(checkdate((int) $partes[1], (int) $partes[2], (int) $partes[0]) && (int) $partes[0] >= 1000);
        }
        $resultado[$campo] = (object) $dados[$campo];
    }
    // Repetições não criam um novo dia de conclusão nem um treino contabilizado.
    $resultado['totalWorkouts'] = count((array) $resultado['completedDates']);
    $padroes = $dados['exerciseDefaults'] ?? [];
    validarCondicao(is_array($padroes));
    foreach ($padroes as $id => $config) {
        validarCondicao(is_array($config) && ($config['exerciseId'] ?? null) === $id);
        validarConfiguracao($config, $ids);
    }
    $resultado['exerciseDefaults'] = (object) $padroes;
    validarCondicao(in_array($dados['theme'] ?? null, ['dark', 'light', 'violet'], true));
    $resultado['theme'] = $dados['theme'];
    if (array_key_exists('trainingPreference', $dados)) {
        validarCondicao(in_array($dados['trainingPreference'], ['musculacao', 'calistenia', 'ambas'], true));
        $resultado['trainingPreference'] = $dados['trainingPreference'];
    } else {
        unset($resultado['trainingPreference']);
    }
    // Clientes antigos não devem sobrescrever a preferência já salva.
    if (array_key_exists('weightUnit', $dados)) {
        validarCondicao(in_array($dados['weightUnit'], ['kg', 'lb'], true));
        $resultado['weightUnit'] = $dados['weightUnit'];
    } else {
        unset($resultado['weightUnit']);
    }
    $sessao = $dados['session'] ?? null;
    if ($sessao !== null) {
        validarCondicao(is_array($sessao) && is_array($sessao['exercises'] ?? null) && count($sessao['exercises']) > 0 && count($sessao['exercises']) <= 400);
        foreach ($sessao['exercises'] as $config) { validarCondicao(is_array($config)); validarConfiguracao($config, $ids); }
        validarCondicao(numeroValido($sessao['exerciseIndex'] ?? null, 0, count($sessao['exercises']) - 1) && is_int($sessao['exerciseIndex']));
        validarCondicao(numeroValido($sessao['completedSets'] ?? null, 0, 100) && is_int($sessao['completedSets']));
        validarCondicao(is_bool($sessao['paused'] ?? null) && is_array($sessao['planIds'] ?? null));
        foreach ($sessao['planIds'] as $id) validarCondicao(idValido($id));
        validarCondicao(is_bool($sessao['rewardXp'] ?? true));
        foreach ($sessao['exercises'] as $config) {
            if (isset($config['planId'])) validarCondicao(idValido($config['planId']));
            if (isset($config['planName'])) validarCondicao(textoValido($config['planName'], 180));
        }
        validarCondicao(numeroValido($sessao['startedAt'] ?? null, 0, 9999999999999) && numeroValido($sessao['activeMilliseconds'] ?? null, 0, 9999999999999));
        $resultado['session'] = $sessao;
    }
    return $resultado;
}
