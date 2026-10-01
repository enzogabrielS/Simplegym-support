# Interface e foto de perfil

O projeto atualizado está em `D:\HTML\Tcc\simplegym`.

Mudanças: formulários organizados por seções, grupos expansíveis na montagem do
treino, remoção da demonstração em vídeo da interface, fontes no perfil, novos
painéis de aparência/privacidade e foto de perfil. A paleta preta original foi
preservada. A opção anteriormente chamada Violeta agora se chama Suave, mantendo
o mesmo identificador no banco para preservar preferências existentes.

Fotos são recortadas ao centro em 384 × 384, convertidas para JPEG e salvas na
conta. O envio aceita arquivos de até 5 MB e o servidor valida o JPEG resultante.
Ao remover a foto, o avatar volta a usar as iniciais do nome.

## Banco existente no Carmine

Faça backup e execute uma vez `banco/atualizar-foto-perfil.sql` antes de enviar
o novo PHP. O banco local já foi atualizado. A nova coluna é `usuarios.foto_perfil`.
Não importe o SQL completo sobre um banco existente.

Para instalação nova em banco vazio, `banco/simplegym.sql` já inclui a coluna.

## Arquivos alterados

- `assets/js/app.js`
- `views/app.php`
- `assets/css/experience.css` (novo)
- `assets/css/exercise-library.css`
- `assets/css/anatome.css`
- `assets/php/banco.php`
- `assets/php/funcoes.php`
- `assets/php/conta.php`

Ao publicar, preserve no `banco.php` os dados de conexão do servidor. Não envie
senhas locais. Nenhum dado de vídeo foi apagado do banco, apenas a funcionalidade
visual foi removida. As páginas passam a usar uma nova versão do JavaScript.

## Verificação

47 verificações de autenticação/dados/foto usando PHP e MySQL de teste reais;
testes visuais em 320, 390 e 1280 pixels, com os três temas. Criação de treino,
preservação do rascunho ao criar exercício, persistência/remoção de foto e
manutenção do mesmo scroll/elemento de imagem entre séries foram conferidos.
As imagens anatômicas externas foram simuladas nesses testes de layout.
Ambiente de teste: PHP 8.5.10 e MySQL 8.4.11; a sintaxe continua compatível com PHP 7.4.
