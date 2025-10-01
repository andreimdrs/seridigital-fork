# Reforma do Sistema de Obras

## Resumo das Alterações

O sistema foi reformulado para suportar livros e manifestos em formato digital (PDF e EPUB), substituindo o antigo sistema de séries e filmes.

## Mudanças Implementadas

### 1. Modelo de Dados (`app/models.py`)
- Adicionado campo `file_path` para armazenar o caminho do arquivo PDF/EPUB
- Adicionado campo `file_type` para identificar o tipo de arquivo (pdf ou epub)
- Tipos de conteúdo alterados de "série/filme/documentário/anime/novela" para "livro/manifesto"

### 2. Migração do Banco de Dados
- Criada migração em `migrations/versions/add_file_fields_to_content.py`
- Adiciona colunas `cnt_file_path` e `cnt_file_type` à tabela `tb_contents`

### 3. Blueprint de Conteúdo (`app/blueprints/content.py`)
- **create_content()**: Atualizado para processar upload de arquivos PDF/EPUB
- **edit_content()**: Atualizado para permitir atualização de arquivos
- **delete_content()**: Atualizado para deletar arquivos físicos ao remover obra
- **download_content()**: Nova rota para download de obras

### 4. Templates Atualizados

#### `app/templates/content/create.html`
- Formulário alterado para upload de arquivos (enctype="multipart/form-data")
- Tipos de obra: Livro e Manifesto
- Campo obrigatório para upload de arquivo PDF ou EPUB
- Removido campo URL (não aplicável para livros)

#### `app/templates/content/edit.html`
- Suporte para upload de novo arquivo (opcional)
- Exibe informação sobre arquivo atual
- Permite substituição do arquivo existente

#### `app/templates/content/view.html`
- Exibe badge com tipo de arquivo (PDF/EPUB)
- Botão de download da obra
- Ícone de livro ao invés de player de vídeo

#### `app/templates/content/list.html`
- Cards com ícone de livro para obras sem capa
- Badge mostrando formato do arquivo
- Altura ajustada para capas de livros (300px)

#### `app/templates/main/index.html`
- Textos alterados de "séries/filmes" para "livros/manifestos"
- Ícones de TV substituídos por ícones de livro
- Descrições atualizadas para refletir conteúdo literário

#### `app/templates/base.html`
- Menu "Conteúdo" renomeado para "Obras"

### 5. Estrutura de Diretórios
- Criado `/workspace/app/static/uploads/obras/` para armazenar arquivos
- Arquivo `.gitkeep` adicionado para manter diretório no controle de versão

## Como Usar

### Adicionar Nova Obra
1. Acesse "Obras" no menu
2. Clique em "Adicionar Obra"
3. Preencha título, tipo (Livro/Manifesto) e descrição
4. Faça upload do arquivo PDF ou EPUB
5. Opcionalmente, adicione URL da capa e data de publicação

### Editar Obra
1. Visualize a obra
2. Clique em "Editar"
3. Modifique os campos desejados
4. Para substituir o arquivo, faça upload de um novo

### Baixar Obra
1. Visualize a obra
2. Clique no botão "Baixar Obra"
3. O arquivo será baixado com o título da obra

## Validações Implementadas

- Apenas arquivos PDF e EPUB são aceitos
- Upload de arquivo é obrigatório na criação
- Nomes de arquivo são sanitizados com `secure_filename()`
- Nomes únicos gerados usando UUID para evitar conflitos
- Arquivo antigo é deletado ao substituir ou remover obra

## Segurança

- Arquivos são salvos em diretório protegido (`/static/uploads/obras/`)
- Validação de extensão de arquivo
- Sanitização de nomes de arquivo
- Autenticação requerida para upload e download

## Próximos Passos (Sugestões)

1. Adicionar visualizador de PDF inline
2. Implementar sistema de favoritos
3. Adicionar tags/categorias específicas para livros
4. Sistema de recomendação baseado em leitura
5. Estatísticas de download
6. Suporte para mais formatos (MOBI, AZW)
