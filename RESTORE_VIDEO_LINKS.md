# 🎥 Restauração: Links de Vídeo em Obras

## 📋 Descrição

Restauração do campo de URL para permitir adicionar links de vídeos relacionados às obras (especialmente do YouTube).

## ✨ Funcionalidade

### O que foi Restaurado

Campo **"Link de Vídeo Relacionado"** nos formulários de obras, permitindo:
- Adicionar links do YouTube
- Adicionar outros links de vídeo
- Complementar a obra com conteúdo audiovisual

### Caso de Uso

**Exemplo:**
- Obra: "O Manifesto Comunista"
- Arquivo: PDF do livro
- Vídeo: Link para uma análise/resumo no YouTube

## 🎯 Localização

### 1. Formulário de Criação (`/content/create`)
- Campo: "Link de Vídeo Relacionado (opcional)"
- Placeholder: `https://youtube.com/watch?v=...`
- Posição: Entre arquivo e capa

### 2. Formulário de Edição (`/content/<id>/edit`)
- Campo: "Link de Vídeo Relacionado (opcional)"
- Valor pré-preenchido se existir
- Pode ser atualizado ou removido

### 3. Visualização (`/content/<id>`)
- Seção: "Vídeo Relacionado"
- Botão: "Assistir Vídeo" (abre em nova aba)
- Aparece apenas se houver URL

## 🔧 Implementação

### 1. Templates

**`create.html` - Novo campo:**
```html
<div class="mb-3">
    <label for="url" class="form-label">Link de Vídeo Relacionado (opcional)</label>
    <input type="url" class="form-control" id="url" name="url" 
           placeholder="https://youtube.com/watch?v=...">
    <small class="text-muted">
        Adicione um link do YouTube ou outro vídeo relacionado à obra
    </small>
</div>
```

**`edit.html` - Campo com valor:**
```html
<div class="mb-3">
    <label for="url" class="form-label">Link de Vídeo Relacionado (opcional)</label>
    <input type="url" class="form-control" id="url" name="url" 
           value="{{ content.url or '' }}" 
           placeholder="https://youtube.com/watch?v=...">
    <small class="text-muted">
        Adicione um link do YouTube ou outro vídeo relacionado à obra
    </small>
</div>
```

**`view.html` - Exibição:**
```html
{% if content.url %}
    <div class="mt-3 mb-3">
        <h5>Vídeo Relacionado</h5>
        <a href="{{ content.url }}" target="_blank" class="btn btn-outline-primary">
            <i class="fab fa-youtube"></i> Assistir Vídeo
        </a>
    </div>
{% endif %}
```

### 2. Backend

**`create_content()` - Captura URL:**
```python
url = request.form.get('url')  # Link de vídeo relacionado

new_content = Content(
    title=title,
    description=description,
    type=content_type,
    url=url,  # ← Adicionado
    thumbnail=thumbnail,
    release_date=release_date_obj,
    file_path=relative_path,
    file_type=file_ext
)
```

**`edit_content()` - Atualiza URL:**
```python
# Atualizar URL de vídeo relacionado
new_url = request.form.get('url')
content.url = new_url
```

## 🎨 Interface

### Formulário de Criação

```
┌────────────────────────────────────┐
│ Título: [________________]         │
│                                    │
│ Tipo: [Livro ▼]                   │
│                                    │
│ Descrição:                         │
│ [_____________________________]    │
│                                    │
│ Arquivo: [Escolher arquivo]        │
│                                    │
│ Link de Vídeo: [______________]   │ ← RESTAURADO
│ (YouTube ou outro vídeo)           │
│                                    │
│ Capa: [____________________]       │
│                                    │
│ [Cancelar]        [Adicionar Obra] │
└────────────────────────────────────┘
```

### Visualização da Obra

```
┌────────────────────────────────────┐
│ O Manifesto Comunista              │
│ [Livro] [1848] [PDF]              │
├────────────────────────────────────┤
│ Descrição:                         │
│ Obra fundamental do socialismo...  │
│                                    │
│ Vídeo Relacionado:                │ ← NOVO
│ [🎥 Assistir Vídeo]               │
│                                    │
│ [📥 Baixar Obra]                  │
└────────────────────────────────────┘
```

## 📊 Fluxo de Dados

### Criar Obra com Vídeo
```
1. Usuário preenche formulário
2. Adiciona link do YouTube
3. Faz upload do PDF
4. Submete formulário
         ↓
5. Backend captura URL
6. Salva no campo content.url
7. Salva arquivo e outros dados
         ↓
8. Obra criada com vídeo vinculado
```

### Visualizar Obra com Vídeo
```
1. Usuário acessa obra
2. Template verifica if content.url
3. Se existir, mostra botão
4. Usuário clica "Assistir Vídeo"
         ↓
5. Abre link em nova aba
6. Assiste vídeo relacionado
```

## 🎯 Casos de Uso

### Caso 1: Resumo em Vídeo
```
Obra: "Sapiens" (PDF)
URL: https://youtube.com/watch?v=resumo-sapiens
→ Usuário baixa livro E assiste resumo
```

### Caso 2: Análise Crítica
```
Obra: "1984" (EPUB)
URL: https://youtube.com/watch?v=analise-1984
→ Complementa leitura com análise
```

### Caso 3: Audiolivro
```
Obra: "Dom Casmurro" (PDF)
URL: https://youtube.com/watch?v=audiolivro
→ Pode ler PDF ou ouvir audiolivro
```

### Caso 4: Documentário
```
Obra: "Capital" de Marx (PDF)
URL: https://youtube.com/watch?v=documentario-marx
→ Entende contexto através do vídeo
```

## 🔗 Tipos de Links Suportados

✅ **YouTube** - `https://youtube.com/watch?v=...`  
✅ **YouTube Shorts** - `https://youtube.com/shorts/...`  
✅ **Vimeo** - `https://vimeo.com/...`  
✅ **Dailymotion** - `https://dailymotion.com/...`  
✅ **Outros** - Qualquer URL válida  

## 🛡️ Validações

### Frontend
- ✅ Tipo `url` no input
- ✅ Validação HTML5 de URL
- ✅ Placeholder com exemplo

### Backend
- ✅ Campo opcional (não obrigatório)
- ✅ Aceita URL vazia ou nula
- ✅ Armazenado como string

## 📱 Comportamento

### Se URL Não Fornecida
- Campo fica vazio no banco
- Seção "Vídeo Relacionado" não aparece
- Obra funciona normalmente só com arquivo

### Se URL Fornecida
- Botão "Assistir Vídeo" aparece
- Link abre em nova aba (`target="_blank"`)
- Ícone do YouTube para clareza

### Se URL Inválida
- HTML5 valida formato
- Usuário deve corrigir antes de submeter

## 🎨 Estilização

### Botão de Vídeo
- Classe: `btn btn-outline-primary`
- Ícone: `fab fa-youtube` (FontAwesome)
- Cor: Azul (primária)
- Abre em nova aba

### Seção
- Título: "Vídeo Relacionado"
- Espaçamento: `mt-3 mb-3`
- Posição: Entre descrição e download

## 📁 Arquivos Modificados

1. **`app/templates/content/create.html`**
   - Linhas 42-46: Campo URL adicionado

2. **`app/templates/content/edit.html`**
   - Linhas 48-52: Campo URL adicionado

3. **`app/templates/content/view.html`**
   - Linhas 52-59: Exibição de vídeo

4. **`app/blueprints/content.py`**
   - Linha 68: Captura URL no create
   - Linha 115: Salva URL no banco
   - Linhas 176-177: Atualiza URL no edit

## 🧪 Como Testar

### Teste 1: Criar Obra com Vídeo
1. Acesse `/content/create`
2. Preencha título, tipo, descrição
3. Faça upload do PDF
4. **Adicione URL do YouTube** (ex: `https://youtube.com/watch?v=test`)
5. Salve
6. ✅ Obra deve ser criada com vídeo

### Teste 2: Visualizar Vídeo
1. Acesse a obra criada
2. ✅ Deve ver seção "Vídeo Relacionado"
3. ✅ Botão "Assistir Vídeo" deve aparecer
4. Clique no botão
5. ✅ Deve abrir YouTube em nova aba

### Teste 3: Obra Sem Vídeo
1. Crie obra sem preencher URL
2. Visualize a obra
3. ✅ Seção "Vídeo Relacionado" NÃO deve aparecer
4. ✅ Apenas botão de download

### Teste 4: Editar e Adicionar Vídeo
1. Edite obra existente sem vídeo
2. Adicione URL na edição
3. Salve
4. ✅ Vídeo deve aparecer agora

### Teste 5: Editar e Remover Vídeo
1. Edite obra com vídeo
2. Limpe o campo URL
3. Salve
4. ✅ Vídeo não deve mais aparecer

## 💡 Melhorias Futuras (Sugestões)

1. **Preview do Vídeo**
   ```html
   <iframe src="youtube-embed-url"></iframe>
   ```

2. **Extração Automática de Thumbnail**
   - Pegar thumbnail do YouTube automaticamente

3. **Player Integrado**
   - Assistir sem sair da página

4. **Múltiplos Vídeos**
   - Lista de vídeos relacionados

5. **Validação de URL do YouTube**
   - Verificar se é realmente do YouTube
   - Aceitar vários formatos de URL

## ✅ Status

**Funcionalidade Restaurada e Testada** 🎉

O campo de URL para vídeos relacionados está de volta e totalmente funcional!

### Benefícios

✅ **Conteúdo Complementar** - Enriquece a obra com vídeos  
✅ **Flexibilidade** - Aceita YouTube e outros  
✅ **Opcional** - Não obriga uso  
✅ **Intuitivo** - Fácil de adicionar e visualizar  
