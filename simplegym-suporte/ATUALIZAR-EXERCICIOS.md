# Atualização visual da biblioteca

Pré-requisito: a integração anterior de modalidades e diagramas deve estar instalada. Esta atualização não exige SQL e não altera o banco.

Envie os quatro arquivos, preservando os caminhos:

- assets/js/app.js
- assets/js/exercise-library.js (novo)
- assets/css/exercise-library.css (novo)
- views/app.php

Mantenha assets/css/anatome.css e todos os demais arquivos existentes. Não envie configurações ou credenciais locais. Atualize os quatro juntos para que os novos módulos sejam carregados. Faça backup dos arquivos antes da substituição.

## Alterações

- Cards únicos, com mapa muscular, nome, equipamento, dificuldade quando conhecida e indicador de exercício pessoal.
- Busca sem distinção de acentos; filtro muscular e alternância entre Musculação, Calistenia e Ambas. Os filtros são locais à biblioteca e não modificam a preferência da conta, a agenda ou treinos existentes.
- Itens compartilhados e pessoais em seções próprias, sem duplicar o mesmo exercício a cada grupo muscular.
- Orientações editoriais curtas em português para os 29 exercícios padrão do catálogo atual. Registros originais e instruções em inglês continuam no banco, mas não são exibidos. Exercícios padrão adicionados futuramente devem receber adaptação em português em exerciseGuidance antes de apresentar instruções; não se usa tradução automática não verificada.
- Dificuldade ausente não é inventada. Equipamento desconhecido recebe rótulo neutro. Vídeo só aparece com URL HTTPS disponível e abre a fonte original; a URL não é exibida como texto.
- A biblioteca ajusta os valores padrão. Quando o exercício já está em um treino, a seção “Ajustar nos meus treinos” preserva o acesso à configuração individual de cada ocorrência.
- Nome/foto/descrição de exercícios pessoais continuam editáveis; seus textos são preservados.
- Origem técnica e créditos não aparecem nos detalhes do usuário. A documentação técnica e o mapeamento anterior permanecem no suporte.

Testes com dados fictícios: pesquisa por acento, filtros, resultados vazios, cards sem duplicação, instruções PT, vídeo condicional, edição da carga em treino salvo, temas claro/escuro e larguras 320/390/1280px. Nenhuma operação foi feita no banco real.
