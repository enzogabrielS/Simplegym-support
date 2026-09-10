# SimpleGym — comece aqui

## Aplicativo principal

Edite somente **D:\HTML\Tcc\simplegym**. A entrada do site é `simplegym/index.php`.
As pastas `assets`, `auth` e `views` pertencem ao mesmo aplicativo; não são cópias.

```text
D:\HTML\Tcc\
├── LEIA-ME-PRIMEIRO.md          Este guia
├── Iniciar-SimpleGym.ps1        Inicia o aplicativo local
├── simplegym\                  APLICATIVO PRINCIPAL
│   ├── index.php               Entrada
│   ├── assets\                 CSS, JavaScript e backend PHP
│   ├── auth\                   Login e cadastro
│   └── views\                  Layouts PHP
└── simplegym-suporte\          NÃO PUBLICAR
    ├── banco\simplegym.sql     Instalação de um banco novo
    ├── backups\                Cópias de segurança preservadas
    ├── arquivos-antigos\       ZIP antigo, não é a versão atual
    ├── testes\                 Testes de desenvolvimento
    ├── DEPLOY.md               Instruções técnicas
    └── demais scripts e SQL    Ferramentas de manutenção
```

## Abrir o aplicativo

Execute `Iniciar-SimpleGym.ps1` desta pasta pelo PowerShell:

```powershell
& 'D:\HTML\Tcc\Iniciar-SimpleGym.ps1'
```

Depois acesse **http://localhost:8080**. Não abra `index.php` com duplo clique.
Se o servidor já estiver iniciado, basta acessar o endereço.

## Banco e versões anteriores

O banco em uso continua no ambiente local em
`C:\Users\enzog\Documents\New project\.simplegym-runtime\mysql-data`.
Não apague nem mova essa pasta: ela guarda os dados reais. Não publique o runtime.
O SQL em `simplegym-suporte/banco` contém estrutura e catálogo inicial, não as contas atuais.
Para transferir as contas, exporte estrutura e dados pelo HeidiSQL.

As pastas `simplegym` e `.simplegym-*-work` em `C:\Users\enzog\Documents\New project`
são versões anteriores ou áreas de preparação; não são o aplicativo principal.
Foram preservadas. Use sempre o projeto em D: para novas alterações.

## Publicação

Publique somente o conteúdo de `simplegym`, sem `.git`, `.gitignore` nem a configuração
local `assets/php/config.local.php`. Configure as credenciais da hospedagem separadamente.
Nunca publique esta pasta inteira, os backups, o SQL ou arquivos com senhas.
Consulte `simplegym-suporte/DEPLOY.md`.
