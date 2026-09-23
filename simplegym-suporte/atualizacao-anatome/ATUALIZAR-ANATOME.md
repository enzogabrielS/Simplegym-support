# SimpleGym — modalidades e Anatome

## Aplicar no Carmine

Esta atualização NÃO foi executada no servidor Carmine nem no banco real local. A antiga credencial administrativa local não foi aceita. A migração foi validada em um MySQL isolado.

1. Exporte o banco atual (estrutura e dados) no HeidiSQL e guarde também uma cópia dos arquivos do site. Não publique os backups.
2. Confirme que a atualização anterior de `unidade_carga` já foi aplicada. Confira com `SHOW COLUMNS FROM perfis_usuario LIKE 'unidade_carga';`.
3. Planeje uma breve janela de manutenção. No HeidiSQL, selecione explicitamente o banco do SimpleGym.
4. Execute **estrutura-anatome.sql uma única vez**. O script adiciona colunas e duas tabelas; não apaga contas. DDL no MySQL faz commit implícito: pare se ocorrer erro e confira o esquema antes de repetir. Não exclua tabelas para resolver coluna duplicada.
5. Execute **catalogo-anatome.sql**. Atualiza somente os exercícios padrão (`usuario_id IS NULL`), mantém seus IDs e insere os novos. É transacional e pode ser repetido sem duplicar os exercícios.
6. Envie os arquivos da pasta `app` do pacote, preservando os caminhos e mesclando com o site. O pacote contém somente arquivos alterados; não substitua a pasta inteira apagando os demais. Não altere `config.php`/`config.local.php`.
7. Atualize a página e teste cadastro, modalidade, biblioteca, detalhes, treino já salvo e exercício pessoal. Use uma conta de teste.

Se houver falha, consulte o log PHP com prefixo `SimpleGym:`. Restaure banco e arquivos juntos a partir do backup para reverter.

## Arquivos da aplicação alterados

- assets/php/cadastrar.php
- assets/php/catalogo.php
- assets/php/dados-iniciais.php
- assets/php/repositorio.php
- assets/php/validar-dados.php
- assets/js/app.js
- assets/css/anatome.css (novo)
- views/cadastro.php
- views/app.php

## Comportamento

- Cadastro exige Musculação, Calistenia ou Ambas. A escolha pode ser alterada em Perfil > Preferências > Modalidade de treino.
- Contas anteriores recebem Ambas. A preferência é persistida em `perfis_usuario.preferencia_treino`.
- A biblioteca e o seletor de novos treinos são filtrados por modalidade. Exercícios pessoais e itens já usados/selecionados permanecem acessíveis. Mudar preferência não apaga treinos, carga, histórico ou exercícios.
- São 29 exercícios padrão: 15 de musculação, 10 de calistenia e 4 compartilhados (3 cardios e prancha). Foram adicionados 18 exercícios aos 11 existentes. Não são prescrições individualizadas nem planos automáticos.
- Cargas continuam em kg no banco, independentemente de kg/lb na interface.
- O catálogo completo permanece disponível à aplicação para abrir os treinos antigos. A modalidade é uma preferência de apresentação, não uma restrição de acesso.

## Anatome

Fonte oficial: https://api.anatome.dev/openapi
Projeto: https://github.com/NextSolutionsStudio/anatome
Consulta: 23/09/2026.

Foi usado exclusivamente `/getExercise` para dados e `anatome_imageSrc` (`/generateImage`) para anatomia. O importador não acessa `/exerciseGif`, `/exerciseImage`, `/exerciseMedia` ou `/exerciseVideo`.

Os diagramas destacam músculos e NÃO demonstram a execução. A interface informa isso explicitamente. Sete exercícios do lote possuem `video_url`: o botão abre a URL HTTPS original em outra aba, sem baixar ou hospedar o vídeo. Sem URL, informa-se indisponibilidade. Valores de nível ausentes permanecem NULL, sem inventar classificação.

Os passos originais são guardados por linha em `exercicio_instrucoes`; o idioma é identificado. A API consultada não oferece português. Nomes e rótulos da interface são em português; instruções originais em inglês ficam em uma seção identificada.

Os músculos primários e secundários ficam em `exercicio_anatomia`. Equipamento, nível, categoria, modalidade, ID da API, URL do diagrama, URL de vídeo e data de atualização ficam em colunas de `exercicios`. Não há catálogo nem colunas JSON.

Prancha estática: não foi encontrada correspondência exata no catálogo consultado. Seu ID da API permanece NULL; usa um diagrama muscular público de abdômen/glúteos, sem atribuir a ela o vídeo ou ID de uma variação diferente. Os demais 28 exercícios têm IDs conferidos. Veja MAPEAMENTO.md.

Imagens dependem da disponibilidade e das condições do serviço público Anatome. Não há sincronização automática nem solicitação paga configurada. Os dados são um retrato importado nesta data; uma atualização futura deve revisar os IDs e gerar/aplicar novo SQL. Em falha do diagrama, os textos continuam disponíveis.

## Fontes e atribuição

Anatome by NextSolutions (Apache-2.0). Diagramas baseados em react-native-body-highlighter (MIT, Hicham El Boussarghini). Metadados públicos conforme a atribuição retornada pelo Anatome (wrkout/exercises.json / free-exercise-db, Unlicense). Os vídeos permanecem nos sites originais e pertencem a seus autores. Nenhuma foto/GIF GymVisual foi baixada ou redistribuída. Os créditos também aparecem nos detalhes do exercício.

## Instalação nova e testes

`simplegym-suporte/banco/simplegym.sql` foi atualizado para instalação em banco vazio. Não o importe sobre o banco em uso para fazer esta atualização: use os dois scripts incrementais acima.

Testes: migração sobre esquema anterior com conta, XP, treino e exercício pessoal; importação repetida sem duplicação; instalação nova; cadastro com escolha obrigatória; persistência de modalidade/unidade; privacidade de contas; alteração de senha; exclusão de conta; UI móvel a 390px e diagrama público; sintaxe PHP/JS. Execução local em PHP 8.5 com array_is_list desativada, mantendo código compatível com PHP 7.4 (a versão 7.4 não está instalada para execução local).
