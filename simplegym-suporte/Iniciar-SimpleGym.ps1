param(
    [string]$Runtime = 'C:\Users\enzog\Documents\New project\.simplegym-runtime',
    [int]$Port = 8080,
    [string]$Project = (Join-Path (Split-Path $PSScriptRoot -Parent) 'simplegym')
)

$ErrorActionPreference = 'Stop'
$phpExe = Join-Path $Runtime 'php\php.exe'
$mysqlBase = Join-Path $Runtime 'mysql\mysql-8.4.11-winx64'
$mysqlExe = Join-Path $mysqlBase 'bin\mysqld.exe'
$mysqlData = Join-Path $Runtime 'mysql-data'
if (!(Test-Path -LiteralPath $phpExe) -or !(Test-Path -LiteralPath $mysqlExe) -or !(Test-Path -LiteralPath $mysqlData)) {
    throw 'Ambiente local não encontrado. Confira o caminho Runtime ou consulte DEPLOY.md.'
}
if (!(Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)) {
    $mysqlArgs = @('--no-defaults', ('--basedir="{0}"' -f $mysqlBase), ('--datadir="{0}"' -f $mysqlData), '--bind-address=127.0.0.1', '--mysqlx=0', ('--log-error="{0}"' -f (Join-Path $Runtime 'mysql-error.log')))
    Start-Process -FilePath $mysqlExe -ArgumentList $mysqlArgs -WindowStyle Hidden | Out-Null
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        if (Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue) { break }
        Start-Sleep -Milliseconds 500
    }
    if (!(Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)) { throw 'MySQL não iniciou. Consulte mysql-error.log no Runtime.' }
}
if (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
    throw "A porta $Port já está em uso. Se o SimpleGym estiver aberto, use http://localhost:$Port; caso contrário, escolha outra porta com -Port."
}
$sessionPath = Join-Path $Runtime 'sessions'
New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null
$phpArgs = @('-d', ('extension_dir="{0}"' -f (Join-Path $Runtime 'php\ext')), '-d', 'extension=pdo_mysql', '-d', ('session.save_path="{0}"' -f $sessionPath), '-d', 'post_max_size=16M', '-S', "127.0.0.1:$Port", '-t', ('"{0}"' -f $Project), ('"{0}"' -f (Join-Path $PSScriptRoot 'servidor-local.php')))
$phpProcess = Start-Process -FilePath $phpExe -ArgumentList $phpArgs -WindowStyle Hidden -RedirectStandardError (Join-Path $Runtime 'php-server.log') -RedirectStandardOutput (Join-Path $Runtime 'php-output.log') -PassThru
Write-Output "SimpleGym: http://localhost:$Port | PHP PID: $($phpProcess.Id)"
