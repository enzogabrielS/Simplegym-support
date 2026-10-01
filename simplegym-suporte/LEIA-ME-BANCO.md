# Banco do SimpleGym

## Arquivo PHP único de banco

`simplegym/assets/php/banco.php` reúne configuração, conexão PDO, estado inicial,
consulta de catálogo e leitura/gravação de treinos. Os cinco valores da conexão
ficam no início de `conectarBanco()`. Variáveis de ambiente `SIMPLEGYM_DB_*`
continuam disponíveis e têm prioridade. Não publique esse arquivo com senhas.

Login, cadastro, sessão, respostas HTTP e validação continuam separados porque
são funcionalidades do aplicativo, não arquivos de configuração do banco.
Os antigos `config.php`, `config.local.php`, `conexao.php`, `catalogo.php`,
`repositorio.php` e `dados-iniciais.php` foram guardados em backup fora do site.

## SQL completo

Para um banco NOVO e VAZIO: selecione-o no HeidiSQL e execute `banco/simplegym.sql`.
Inclui todas as tabelas, os níveis e os 29 exercícios padrão. Não é um export dos
usuários existentes e não substitui uma migração de banco antigo.

## Manutenção de banco existente

O script `manutencao-banco.php`, nesta pasta de suporte, funciona apenas pelo
terminal. Usa a conexão do aplicativo e não deve ser colocado na pasta pública.

    php manutencao-banco.php --check
    php manutencao-banco.php --apply

`--check` verifica as colunas e tabelas desta atualização sem escrever.
`--apply` bloqueia temporariamente os acessos, faz um backup SQL, adiciona somente
as colunas ausentes e as duas tabelas de anatomia/instruções, e atualiza o catálogo
padrão. Não apaga usuários nem treinos. Requer permissão CREATE/ALTER no banco.
O backup fica em `backups/banco-DATA-HORA/antes.sql` e contém dados privados.
Para restaurá-lo, importe em outro banco vazio e confira antes de trocar a conexão.
DDL do MySQL não tem rollback: se houver falha, consulte o erro e mantenha o backup.

## Problemas corrigidos nesta revisão

- Banco local antigo: faltavam 11 colunas e duas tabelas exigidas pelo aplicativo.
- SQL completo: comparação entre collations diferentes podia causar o erro 1267.
  O SQL agora explicita charset/collation das tabelas novas e das expressões do catálogo.
- Mensagens de erro diferenciadas para estrutura desatualizada, conexão e falha interna.
- Listas de exercícios/grupos/séries recebidas com índices inválidos são rejeitadas
  pela validação antes de alcançar colunas numéricas do banco.

Os testes foram executados em MySQL 8.4.11 e PHP 8.5.10, com `array_is_list`
desabilitado. O código mantém a sintaxe de PHP 7.4; isso não substitui um teste
no PHP 7.4.19 do Carmine. Esta atualização local não altera o servidor Carmine.
