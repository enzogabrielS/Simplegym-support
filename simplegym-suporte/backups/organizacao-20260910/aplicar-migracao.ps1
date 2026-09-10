param(
    [string]$Stage = 'C:\Users\enzog\Documents\New project\.simplegym-relational-work',
    [string]$Project = 'D:\HTML\Tcc\simplegym',
    [string]$Support = 'D:\HTML\Tcc\simplegym-suporte',
    [string]$Runtime = 'C:\Users\enzog\Documents\New project\.simplegym-runtime'
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath $Project).Path
if ($projectRoot -ne 'D:\HTML\Tcc\simplegym') { throw 'Confirme manualmente o destino antes de adaptar esta ferramenta.' }
$listener = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
$existingPhp = $null
if ($listener) {
    $existingPhp = Get-CimInstance Win32_Process -Filter "ProcessId = $($listener.OwningProcess)"
    if ($existingPhp.Name -ne 'php.exe' -or $existingPhp.CommandLine.IndexOf($projectRoot, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw 'A porta 8080 pertence a outro processo. Nenhum arquivo ou banco foi alterado.'
    }
}
$backupRoot = Join-Path $Support ('backup-relacional-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backupRoot | Out-Null
$filesBackup = Join-Path $backupRoot 'arquivos'
New-Item -ItemType Directory -Path $filesBackup | Out-Null
Get-ChildItem -LiteralPath $projectRoot -Force | Where-Object { $_.Name -ne '.git' } | Copy-Item -Destination $filesBackup -Recurse -Force

$phpExe = Join-Path $Runtime 'php\php.exe'
$phpExt = Join-Path $Runtime 'php\ext'
$dumpExe = Join-Path $Runtime 'mysql\mysql-8.4.11-winx64\bin\mysqldump.exe'
$adminFile = Join-Path $Runtime 'admin.cnf'
$databaseBackup = Join-Path $backupRoot 'banco-anterior.sql'

# Bloqueia chamadas da aplicação durante a troca. O backup do PHP anterior já existe.
Copy-Item -LiteralPath (Join-Path $Support '.maintenance') -Destination (Join-Path $projectRoot 'assets\php\.maintenance')
Copy-Item -LiteralPath (Join-Path $Stage 'assets\php\funcoes.php') -Destination (Join-Path $projectRoot 'assets\php\funcoes.php') -Force
& $dumpExe "--defaults-extra-file=$adminFile" --single-transaction --no-tablespaces --set-gtid-purged=OFF --databases simplegym "--result-file=$databaseBackup"
if ($LASTEXITCODE -ne 0 -or (Get-Item -LiteralPath $databaseBackup).Length -lt 100) { throw 'Backup falhou. Migração não executada.' }

# Só os arquivos de execução entram no projeto. Não altera a configuração local existente.
$deployItems = @('assets', 'auth', 'views', 'index.php', '.htaccess', '.gitignore')
foreach ($item in $deployItems) {
    $sourceItem = Join-Path $Stage $item
    if (Test-Path -LiteralPath $sourceItem -PathType Container) {
        foreach ($file in Get-ChildItem -LiteralPath $sourceItem -Recurse -File -Force) {
            $relative = $file.FullName.Substring($Stage.Length + 1)
            if ($relative -in @('assets\php\config.local.php', 'auth\login.html', 'auth\cadastro.html')) { continue }
            $destination = [IO.Path]::GetFullPath((Join-Path $projectRoot $relative))
            if (!$destination.StartsWith($projectRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Destino inválido.' }
            New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        }
    } else { Copy-Item -LiteralPath $sourceItem -Destination (Join-Path $projectRoot $item) -Force }
}
& $phpExe -d "extension_dir=$phpExt" -d extension=pdo_mysql (Join-Path $Support 'migrar.php') $projectRoot $databaseBackup $adminFile
if ($LASTEXITCODE -ne 0) { throw 'Migração interrompida. App em manutenção; consulte o backup e o erro antes de continuar.' }

# Move apenas os alvos nomeados, mantendo-os recuperáveis fora da pasta pública.
if ($existingPhp) { Stop-Process -Id $existingPhp.ProcessId }
$retiredRoot = Join-Path $backupRoot 'retirados'
New-Item -ItemType Directory -Path $retiredRoot | Out-Null
foreach ($relative in @('data', 'database', 'scripts', 'tests', 'README.md', 'Iniciar-SimpleGym.ps1', 'router.php', 'index.html', 'auth\login.html', 'auth\cadastro.html')) {
    $source = [IO.Path]::GetFullPath((Join-Path $projectRoot $relative))
    if (!$source.StartsWith($projectRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Origem fora do projeto.' }
    if (Test-Path -LiteralPath $source) {
        $destination = [IO.Path]::GetFullPath((Join-Path $retiredRoot $relative))
        if (!$destination.StartsWith($retiredRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Destino fora do backup.' }
        New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
        Move-Item -LiteralPath $source -Destination $destination
    }
}
Move-Item -LiteralPath (Join-Path $projectRoot 'assets\php\.maintenance') -Destination (Join-Path $backupRoot 'maintenance-concluida')
& (Join-Path $Support 'Iniciar-SimpleGym.ps1') -Runtime $Runtime -Project $projectRoot
Write-Output "Migração aplicada. Backup: $backupRoot"
