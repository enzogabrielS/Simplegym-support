# Atualização das preferências — kg/lb e aparência

1. Faça backup do banco e dos arquivos no servidor.
2. No HeidiSQL, selecione o banco usado pelo SimpleGym no Carmine.
3. Execute `atualizar-unidade-carga.sql` uma única vez. Não importe novamente o SQL completo do aplicativo.
4. Envie os cinco arquivos do projeto local, preservando seus caminhos:
   - `assets/js/app.js`
   - `views/app.php`
   - `assets/php/dados-iniciais.php`
   - `assets/php/validar-dados.php`
   - `assets/php/repositorio.php`
5. Atualize a página. Em Perfil > Preferências, selecione Unidade de carga.

A aparência foi movida de Configurações para Preferências. Meta semanal e Lembretes foram removidos.

A coluna `perfis_usuario.unidade_carga` guarda `kg` ou `lb`, com kg por padrão. As cargas continuam em kg em todas as tabelas, inclusive sessões pausadas. A interface converte para libras usando 1 lb = 0,45359237 kg. Os botões ±1 e ±5 usam a unidade selecionada. A exibição é arredondada para duas casas decimais.

Se aparecer erro de coluna duplicada, confira com `SHOW COLUMNS FROM perfis_usuario LIKE 'unidade_carga';` — a migração pode já ter sido aplicada. Não exclua nem recrie a tabela.

Não altere a configuração de conexão nem envie credenciais locais ao Carmine. Esta atualização mantém a correção para PHP 7.4. Os testes locais executaram em PHP 8.5 com `array_is_list` desativada; a validação final do ambiente PHP 7.4 deve ser feita no servidor.
