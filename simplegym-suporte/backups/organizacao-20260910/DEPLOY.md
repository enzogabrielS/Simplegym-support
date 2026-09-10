# SimpleGym: deploy e banco relacional

## Termo de responsabilidade e contagem de treinos

O cadastro exige aceite explícito da versão atual, sem checkbox pré-marcado. O PHP também valida o aceite. A tabela `aceites_termos` guarda usuário, versão, texto integral, hash SHA-256 e data do servidor. Contas anteriores não recebem aceite retroativo. O conteúdo compartilhado entre cadastro e perfil está em `views/termos-conteudo.php`; a versão é definida em `assets/php/termos.php`. Ao alterar os termos, publique uma nova versão sem editar registros de aceites anteriores.

O texto é uma minuta e deve passar por revisão jurídica antes da publicação. Ele esclarece riscos e responsabilidades pessoais, sem excluir responsabilidades legais do fornecedor ou direitos do consumidor (CDC, arts. 25 e 51).

Repetições sem XP não aumentam o total de treinos nem geram um novo dia de conclusão. O tempo real de atividade continua sendo contabilizado. O servidor usa os dias de conclusão registrados para impedir que totais inflados por repetições sejam salvos.

## Pastas

- `D:\HTML\Tcc\simplegym`: somente arquivos utilizados pelo site (PHP, CSS, JavaScript, layouts e configuração).
- `D:\HTML\Tcc\simplegym-suporte`: SQL de instalação, ferramentas locais, testes, instruções e backups. **Não publique esta pasta.**
- A pasta oculta `.git` e o `.gitignore` foram preservados como metadados do código. Exclua-os do upload; não publique o histórico.

Os arquivos `.json`, os HTML antigos de redirecionamento, os testes, os instaladores, o README e o servidor de desenvolvimento não fazem parte da pasta pública. Os originais removidos ficam no backup anterior à migração.

## Abrir localmente

Execute `Iniciar-SimpleGym.ps1` nesta pasta de suporte e acesse `http://localhost:8080`. O parâmetro `-Project` permite apontar para outra pasta e `-Port` para outra porta.

O ambiente portátil continua em `C:\Users\enzog\Documents\New project\.simplegym-runtime`. Não apague `mysql-data`, pois contém o banco real. A senha administrativa do MySQL fica no arquivo `admin.cnf` desse ambiente; não é a senha de login do aplicativo.

## Consultar no HeidiSQL

Conexão MariaDB/MySQL TCP/IP, host `127.0.0.1`, porta `3306`, usuário `root`, senha da linha `password=` do arquivo administrativo. Selecione o banco `simplegym`.

| Tabela | O que guarda |
| --- | --- |
| usuarios | Conta e hash da senha |
| exercicios | Nome, foto, descrição, execução, tipo e dono de cada exercício |
| grupos_musculares | Nome, descrição e ordem dos grupos |
| exercicio_grupos | Relação de cada exercício com um ou mais grupos |
| exercicio_musculos | Músculos em foco, um por linha |
| niveis | Nível, XP mínimo, título e descrição |
| treinos | Nome e dono do treino |
| treino_grupos | Grupos informados para cada treino |
| treino_exercicios | Ordem, exercício, séries, repetições e carga |
| configuracoes_exercicio | Valores padrão escolhidos pelo usuário |
| agenda_semanal | Treinos e ordem de cada dia |
| perfis_usuario | XP, sequência, total de treinos, minutos, tema e versão |
| atividades_diarias | Dias de treino concluído e check-in livre |
| treino_sessoes, sessao_treinos, sessao_exercicios | Treino em andamento/pausado |
| sessoes_persistentes, tentativas_login | Autenticação persistente e limite de tentativas |

Na tabela **exercicios**, `usuario_id IS NULL` indica exercício padrão. Um `usuario_id` preenchido vincula o exercício pessoal à conta. As duas origens usam colunas reais na mesma tabela; não é necessário criar uma tabela para cada pessoa. A coluna gerada `dono` garante um código único dentro de cada catálogo: 0 para padrão ou o ID da conta para pessoal. Não edite `dono` manualmente.

`foto` contém a URL ou a imagem enviada pelo dispositivo em formato data URL. Nenhum atributo é armazenado em um documento JSON. Não há colunas do tipo JSON nem arquivos JSON de catálogo. JSON é usado somente no transporte HTTP entre JavaScript e PHP, não como armazenamento.

## Adicionar exercício padrão no HeidiSQL

1. Insira uma linha em `exercicios`, mantendo `usuario_id` como NULL. Informe `codigo` único (ex.: `elevacao-lateral`), `nome`, `foto`, `descricao`, `execucao`, `tipo` (`forca` ou `cardio`) e `ordem`. O campo `id` é automático.
2. Em `exercicio_grupos`, relacione esse `id` com um ou mais IDs de `grupos_musculares`, indicando a ordem a partir de 0.
3. Em `exercicio_musculos`, cadastre os músculos em foco, um por linha, com ordem a partir de 0.
4. Atualize o aplicativo. Os valores são lidos diretamente do banco, sem catálogo de reserva no JavaScript.

Os exercícios pessoais devem ser criados pela interface; ela preenche o vínculo com o usuário e protege o catálogo padrão. Antes de remover exercícios usados por treinos, faça backup: a exclusão no banco remove os vínculos correspondentes.

## Publicar

1. Use PHP 8.1+ com PDO MySQL e MySQL 8.0+, HTTPS e um servidor próprio para produção (Apache/Nginx).
2. Crie um banco vazio, selecione-o no HeidiSQL e importe `simplegym.sql` desta pasta. Ele contém estrutura e catálogo inicial, sem contas de demonstração. Não importe o backup local para produção sem intenção explícita de copiar os dados dos usuários.
3. Crie um usuário MySQL com SELECT, INSERT, UPDATE e DELETE somente nesse banco.
4. Envie o conteúdo de `simplegym`, excluindo `.git`, `.gitignore` e `assets/php/config.local.php` local. Configure as variáveis `SIMPLEGYM_DB_HOST`, `SIMPLEGYM_DB_PORT`, `SIMPLEGYM_DB_NAME`, `SIMPLEGYM_DB_USER` e `SIMPLEGYM_DB_PASSWORD` no servidor, ou crie um `config.local.php` com as variáveis `$servidor`, `$porta`, `$banco`, `$usuario`, `$senha` da hospedagem.
5. A entrada é `index.php`. No Apache, habilite as regras `.htaccess`; no Nginx configure bloqueio a arquivos ocultos, à pasta `views` e aos helpers privados `config`, `conexao`, `funcoes`, `dados-iniciais`, `validar-dados`, `catalogo` e `repositorio` em `assets/php`.
6. Não use o servidor embutido do PHP nem publique credenciais, backups ou esta pasta de suporte em produção.

## Migração e recuperação

A migração preserva contas, treinos, exercícios pessoais, agenda, estatísticas, configurações e sessões pausadas, comparando o estado completo antes e depois. Somente após essa comparação ela remove a antiga tabela `dados_usuario`. O dump anterior e os arquivos anteriores ficam em `backup-relacional-*`, fora do site. Para reverter, restaure **juntos** os arquivos e o banco daquele backup, com o app desligado, preferencialmente primeiro em ambiente de teste.

O esquema e o catálogo para uma instalação nova estão reunidos em `simplegym.sql`. Os arquivos `estrutura.sql`, `catalogo-inicial.sql` e `autenticacao.sql` são usados pelas ferramentas de migração e testes, sem necessidade de upload.

## Testes de integração

`preparar-teste.php` cria o banco isolado `simplegym_relational_test` usando a credencial administrativa local. Aponte um servidor PHP de teste para o projeto com `SIMPLEGYM_DB_NAME=simplegym_relational_test`, em outra porta. Execute `testes/auth.integration.mjs` com Node e as variáveis:

- `SIMPLEGYM_DB_NAME=simplegym_relational_test`
- `SIMPLEGYM_PROJECT_PATH=D:\HTML\Tcc\simplegym`
- `SIMPLEGYM_TEST_URL=http://127.0.0.1:8081`
- `SIMPLEGYM_TEST_PHP=C:\Users\enzog\Documents\New project\.simplegym-runtime\php\php.exe`
- `SIMPLEGYM_TEST_PHP_EXT=C:\Users\enzog\Documents\New project\.simplegym-runtime\php\ext`

As verificações incluem cadastro/login, CSRF, logout, persistência, isolamento, leitura direta do catálogo, colunas relacionais e conflitos entre abas. Apenas contas temporárias do próprio teste são removidas.
