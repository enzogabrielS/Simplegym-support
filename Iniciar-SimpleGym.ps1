param([int]$Port = 8080)

$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'simplegym-suporte\Iniciar-SimpleGym.ps1'
$project = Join-Path $PSScriptRoot 'simplegym'
if (!(Test-Path -LiteralPath $launcher) -or !(Test-Path -LiteralPath (Join-Path $project 'index.php'))) {
    throw 'Mantenha este iniciador ao lado das pastas simplegym e simplegym-suporte.'
}
& $launcher -Project $project -Port $Port
