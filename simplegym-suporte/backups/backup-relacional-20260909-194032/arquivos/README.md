# SimpleGym

Web app responsivo com HTML, CSS, JavaScript, PHP e MySQL. Login obrigatório, treinos personalizados por conta e preferência de aparência salvos no banco. O PHP usa funções pequenas, PDO, consultas preparadas e arquivos separados, sem framework.

## Abrir neste computador

O projeto está em **D:\HTML\Tcc\simplegym**. PHP e MySQL portáteis foram preparados em **C:\Users\enzog\Documents\New project\.simplegym-runtime**.

No PowerShell:

```powershell
cd D:\HTML\Tcc\simplegym
powershell -ExecutionPolicy Bypass -File .\Iniciar-SimpleGym.ps1
```

Abra **http://localhost:8080**, crie sua conta e monte seu primeiro treino. Se a porta já estiver ocupada pelo SimpleGym, basta abrir o endereço. Para outra porta, acrescente `-Port 8081`. O script inicia os processos em segundo plano; não inicia automaticamente com o Windows.

**Não abra pelo file:// nem pelo Live Server:** eles não executam PHP. Os antigos arquivos HTML apenas encaminham para as páginas PHP quando usados em servidor.

## Banco de dados local

- Banco: `simplegym`, MySQL local em `127.0.0.1:3306`.
- A conexão está em `assets/php/config.php`; os valores específicos deste computador ficam em `assets/php/config.local.php`, ignorado pelo Git.
- O usuário da aplicação possui apenas SELECT, INSERT, UPDATE e DELETE no banco SimpleGym.
- As senhas aleatórias do ambiente não estão no código versionado. A configuração administrativa fica em `.simplegym-runtime/admin.cnf`. Não publique esse arquivo nem `config.local.php`.
- Os dados reais ficam em `.simplegym-runtime/mysql-data`. Não exclua essa pasta; faça backup do banco antes de mover o ambiente. Copiar somente o projeto não copia as contas.

O arquivo `database/simplegym.sql` cria o banco e quatro tabelas, sem apagar registros:

| Tabela | Conteúdo |
| --- | --- |
| usuarios | Nome, email único e hash da senha |
| dados_usuario | Documento JSON de treinos, agenda, exercícios pessoais, configurações, estatísticas e treino pausado, isolado por usuário |
| sessoes_persistentes | Hash dos tokens de login com validade de 30 dias |
| tentativas_login | Limite de tentativas de autenticação |

A estrutura JSON preserva o modelo simples do JavaScript. O ID da conta vem da sessão PHP, nunca do navegador. O número de versão impede que uma aba sobrescreva alterações mais recentes de outra.

## Usar outro PHP/MySQL ou XAMPP

Requisitos: PHP 8.1+ com PDO MySQL e MySQL 8.0+. Em outro ambiente:

1. Importe `database/simplegym.sql` usando uma conta administrativa.
2. Crie um usuário para a aplicação com SELECT, INSERT, UPDATE e DELETE em `simplegym.*`.
3. Configure `assets/php/config.local.php` com as variáveis abaixo e os valores do seu ambiente. Não use as senhas do ambiente de desenvolvimento em produção.
4. Inicie Apache apontando para o projeto, ou use `php -S localhost:8080 -t . router.php` com PDO MySQL habilitado.

```php
<?php
$servidor = '127.0.0.1';
$porta = '3306';
$banco = 'simplegym';
$usuario = 'seu_usuario_mysql';
$senha = 'sua_senha_mysql';
```

Também são aceitas as variáveis de ambiente `SIMPLEGYM_DB_HOST`, `SIMPLEGYM_DB_PORT`, `SIMPLEGYM_DB_NAME`, `SIMPLEGYM_DB_USER` e `SIMPLEGYM_DB_PASSWORD` quando não há configuração local. `scripts/instalar-banco.php` é uma alternativa de importação pelo terminal, desde que a conexão possua permissão administrativa. `scripts/configurar-local.php` serve somente para a primeira preparação de uma instância portátil nova.

## Organização

```text
simplegym/
├── index.php                 # Entrada protegida por sessão
├── auth/login.php            # Login
├── auth/cadastro.php         # Cadastro
├── views/                    # Layouts das páginas
├── assets/php/               # Conexão, autenticação e API de dados
├── assets/js/api.js          # Comunicação JSON/CSRF com o PHP
├── assets/js/app.js          # Treinos, exercícios e perfil
├── assets/css/app.css        # Estilos responsivos
├── auth/assets/              # Estilos e JavaScript da autenticação
├── data/                     # Catálogos públicos em JSON
├── database/simplegym.sql    # Estrutura do banco
├── scripts/                  # Preparação pelo terminal
├── tests/                    # Testes de integração
├── router.php                # Roteador do servidor local
└── Iniciar-SimpleGym.ps1      # Inicia o ambiente deste computador
```

## Comportamento

- Novas contas começam com **0 XP, 0 dias seguidos, 0 treinos e 0 minutos**, sem treinos pessoais ou agenda pré-preenchida. Os dados de demonstração do antigo localStorage não são importados; somente as chaves antigas do SimpleGym são removidas ao entrar.
- Em **Meus treinos → Exercícios**, os botões ajustam séries e repetições em ±1 e carga em ±1/±5. Exercícios não utilizados ainda podem receber valores padrão para novos treinos. Se o exercício já está em um treino, o ajuste vale para aquela ocorrência.
- Nome, foto, descrição e grupos só podem ser editados em exercícios pessoais. O catálogo padrão continua em `data/exercises.json`, com grupos em `data/muscle-groups.json` e níveis em `data/levels.json`.
- As alterações são salvas na conta. Em caso de falha aparece **Tentar novamente**; em conflito entre abas, **Recarregar**. Não feche o aplicativo enquanto houver alterações pendentes.
- A atividade usa o tempo real do treino, excluindo pausas. Um ponto de salvamento é feito a cada série e a cada 30 segundos. Ao reabrir um treino, ele fica pausado, sem contar o tempo em que o aplicativo esteve fechado; um fechamento abrupto pode perder o intervalo desde o último ponto salvo.
- O primeiro treino concluído do dia concede 60 XP. Repetições aumentam treinos/atividade, mas não concedem XP novamente. A sequência usa dias locais com treino concluído.
- O check-in de dia livre é permitido somente no dia atual e não simula treino, XP ou tempo de atividade.
- **Sair da conta** encerra a sessão, revoga o token persistente deste login e retorna ao login. O login é lembrado por até 30 dias; após esse prazo será solicitado novamente.
- Meta semanal e lembretes ainda são componentes demonstrativos da interface; não enviam notificações. Recuperação de senha e edição dos dados da conta não foram implementadas.

## Segurança e publicação

Senhas são armazenadas com `password_hash` e verificadas com `password_verify`. Cookies são HttpOnly/SameSite=Lax e recebem Secure quando o site roda em HTTPS. As gravações exigem token CSRF. As entradas são validadas e as consultas usam parâmetros preparados.

O servidor portátil é apenas para desenvolvimento, limitado a 127.0.0.1. Para publicar, use HTTPS, um servidor PHP adequado, credenciais de produção, backups e proteja os diretórios privados (as regras .htaccess são para Apache; configure equivalentes em Nginx). Os contadores são calculados pelo cliente e persistidos no banco; não são um sistema antifraude para rankings ou recompensas financeiras.

## Testes

Com o servidor ligado, no PowerShell (Node.js necessário):

```powershell
$env:SIMPLEGYM_TEST_PHP = 'C:\Users\enzog\Documents\New project\.simplegym-runtime\php\php.exe'
$env:SIMPLEGYM_TEST_PHP_EXT = 'C:\Users\enzog\Documents\New project\.simplegym-runtime\php\ext'
node tests/auth.integration.mjs
```

O teste cria duas contas temporárias com domínio `simplegym.test`, verifica autenticação, sessão persistente, dados zerados, isolamento, validação, conflitos e logout. Ao finalizar, remove somente os emails exatos criados naquela execução. Os demais usuários são preservados. Para outra porta, configure `SIMPLEGYM_TEST_URL`.
