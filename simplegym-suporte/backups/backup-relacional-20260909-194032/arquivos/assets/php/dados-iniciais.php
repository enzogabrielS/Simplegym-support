<?php
function dadosIniciais(): array
{
    return [
        'plans' => [],
        'schedule' => array_fill_keys(['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'], []),
        'customExercises' => [], 'exerciseDefaults' => (object) [],
        'xp' => 0, 'streak' => 0, 'totalWorkouts' => 0, 'activityMinutes' => 0,
        'completedDates' => (object) [], 'freeDayCheckins' => (object) [],
        'theme' => 'dark', 'session' => null
    ];
}
