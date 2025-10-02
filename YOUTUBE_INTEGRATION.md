# 🎥 Integração Completa com YouTube

## 📋 Resumo das Mudanças

Sistema de obras agora totalmente integrado com YouTube:
1. ✅ **Thumbnail automática** do YouTube quando não há imagem manual
2. ✅ **Ícone de play centralizado** na imagem da obra
3. ✅ **PDF/EPUB opcional** quando há link do YouTube

## 🎯 Funcionalidades Implementadas

### 1. Thumbnail Automática do YouTube
Quando um link do YouTube é fornecido SEM uma URL de capa manual, o sistema:
- Extrai o ID do vídeo do YouTube
- Gera automaticamente a URL da thumbnail em alta qualidade (`maxresdefault`)
- Salva no campo `thumbnail` da obra

**Exemplo:**
```
URL: https://youtube.com/watch?v=abc123
Thumbnail gerada: https://img.youtube.com/vi/abc123/maxresdefault.jpg
```

### 2. Ícone de Play Centralizado
Quando uma obra tem link do YouTube:
- A thumbnail (automática ou manual) é exibida com um ícone de play centralizado
- Ao clicar na imagem, abre o vídeo do YouTube em nova aba
- Efeito hover: overlay escurece e ícone aumenta

**Visual:**
```
┌──────────────────────────┐
│                          │
│        THUMBNAIL         │
│           ◯              │  ← Play icon
│          ▶               │
│                          │
└──────────────────────────┘
```

### 3. PDF/EPUB Opcional
- **Antes:** Arquivo PDF/EPUB era OBRIGATÓRIO
- **Agora:** Arquivo OU YouTube é obrigatório
- Permite criar obras apenas com vídeo do YouTube
- Permite criar obras com vídeo E arquivo

## 📊 Casos de Uso

### Caso 1: Obra com YouTube (sem arquivo)
```
Título: "Análise do Manifesto Comunista"
Tipo: Manifesto
YouTube: https://youtube.com/watch?v=abc123
Arquivo: (vazio)
Thumbnail: (gerada automaticamente do YouTube)

Resultado:
✅ Obra criada com sucesso
✅ Thumbnail do vídeo do YouTube
✅ Play icon na thumbnail
✅ Clique abre YouTube
✅ Sem botão de download (não há arquivo)
```

### Caso 2: Obra com YouTube E arquivo
```
Título: "1984"
Tipo: Livro
YouTube: https://youtube.com/watch?v=xyz789
Arquivo: 1984.pdf
Thumbnail: (gerada automaticamente)

Resultado:
✅ Obra criada com sucesso
✅ Thumbnail do vídeo
✅ Play icon na thumbnail
✅ Clique na imagem → YouTube
✅ Botão "Baixar Obra" disponível
```

### Caso 3: Obra apenas com arquivo (sem YouTube)
```
Título: "Dom Casmurro"
Tipo: Livro
YouTube: (vazio)
Arquivo: dom-casmurro.epub
Thumbnail: (manual ou vazio)

Resultado:
✅ Obra criada com sucesso
✅ Thumbnail manual ou ícone de livro
✅ SEM play icon
✅ Botão "Baixar Obra" disponível
```

### Caso 4: Obra com YouTube e Thumbnail Manual
```
Título: "O Capital"
Tipo: Livro
YouTube: https://youtube.com/watch?v=123
Arquivo: (vazio)
Thumbnail: https://example.com/capa-capital.jpg (MANUAL)

Resultado:
✅ Obra criada com sucesso
✅ Usa thumbnail MANUAL (não gera do YouTube)
✅ Play icon na thumbnail
✅ Clique abre YouTube
```

## 🔧 Implementação Técnica

### Backend: `app/blueprints/content.py`

**Validação (criar):**
```python
# Validar: arquivo OU URL do YouTube é obrigatório
has_file = request.files.get('file') and request.files.get('file').filename != ''
has_youtube_url = url and url.strip() != ''

if not has_file and not has_youtube_url:
    flash('É obrigatório fornecer um arquivo (PDF/EPUB) ou um link do YouTube.', 'danger')
    return render_template('content/create.html')
```

**Upload opcional:**
```python
# Processar upload do arquivo (se fornecido)
relative_path = None
file_ext = None

file = request.files.get('file')
if file and file.filename != '':
    # ... processar upload
    relative_path = f"uploads/obras/{unique_filename}"
```

**Thumbnail automática:**
```python
# Gerar thumbnail do YouTube automaticamente se não houver thumbnail manual
if not thumbnail and url:
    from ..utils.helpers import extract_youtube_id, youtube_thumbnail_url
    video_id = extract_youtube_id(url)
    if video_id:
        thumbnail = youtube_thumbnail_url(video_id, quality='maxresdefault')
```

### Frontend: Templates

**`create.html` - Campos reordenados:**
```html
<!-- URL do YouTube ANTES do arquivo -->
<div class="mb-3">
    <label for="url" class="form-label">Link do YouTube</label>
    <input type="url" class="form-control" id="url" name="url" 
           placeholder="https://youtube.com/watch?v=...">
    <small class="text-muted">Link do YouTube relacionado à obra</small>
</div>

<!-- Arquivo agora é OPCIONAL -->
<div class="mb-3">
    <label for="file" class="form-label">
        Arquivo da Obra (PDF ou EPUB) - opcional se houver link do YouTube
    </label>
    <input type="file" class="form-control" id="file" name="file" 
           accept=".pdf,.epub">
    <small class="text-muted">
        Formatos aceitos: PDF, EPUB. Arquivo ou YouTube é obrigatório.
    </small>
</div>
```

**`view.html` - Thumbnail com play icon:**
```html
{% if content.url %}
    <!-- Thumbnail com play icon -->
    <a href="{{ content.url }}" target="_blank" class="text-decoration-none">
        <div class="obra-thumbnail-container">
            {% if content.thumbnail %}
                <img src="{{ content.thumbnail }}" class="img-fluid" alt="{{ content.title }}">
            {% else %}
                <div class="bg-light w-100 d-flex align-items-center justify-content-center" 
                     style="height: 300px;">
                    <i class="fas fa-book fa-5x text-muted"></i>
                </div>
            {% endif %}
            <div class="obra-thumbnail-overlay">
                <div class="obra-play-icon">
                    <i class="fas fa-play"></i>
                </div>
            </div>
        </div>
    </a>
{% else %}
    <!-- Apenas thumbnail sem play icon -->
    {% if content.thumbnail %}
        <img src="{{ content.thumbnail }}" class="img-fluid rounded" alt="{{ content.title }}">
    {% else %}
        <div class="bg-light w-100 d-flex align-items-center justify-content-center rounded" 
             style="height: 300px;">
            <i class="fas fa-book fa-5x text-muted"></i>
        </div>
    {% endif %}
{% endif %}
```

**`list.html` - Play icon nos cards:**
```html
{% if content.url %}
    <a href="{{ content.url }}" target="_blank" class="text-decoration-none">
        <div class="obra-thumbnail-container" style="border-radius: 0;">
            {% if content.thumbnail %}
                <img src="{{ content.thumbnail }}" class="card-img-top" 
                     alt="{{ content.title }}" 
                     style="height: 300px; object-fit: cover;">
            {% else %}
                <div class="card-img-top bg-light d-flex align-items-center justify-content-center" 
                     style="height: 300px;">
                    <i class="fas fa-book fa-4x text-muted"></i>
                </div>
            {% endif %}
            <div class="obra-thumbnail-overlay">
                <div class="obra-play-icon">
                    <i class="fas fa-play"></i>
                </div>
            </div>
        </div>
    </a>
{% else %}
    <!-- Sem play icon -->
{% endif %}
```

### CSS: `app/static/style.css`

**Container da thumbnail:**
```css
.obra-thumbnail-container {
    position: relative;
    display: inline-block;
    width: 100%;
    cursor: pointer;
    overflow: hidden;
    border-radius: 8px;
}

.obra-thumbnail-container img {
    width: 100%;
    height: auto;
    display: block;
    transition: transform 0.3s ease;
}
```

**Overlay escuro:**
```css
.obra-thumbnail-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.3);
    transition: background 0.3s ease;
    pointer-events: none;
}

.obra-thumbnail-container:hover .obra-thumbnail-overlay {
    background: rgba(0, 0, 0, 0.5);
}
```

**Ícone de play:**
```css
.obra-play-icon {
    width: 80px;
    height: 80px;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
}

.obra-thumbnail-container:hover .obra-play-icon {
    background: rgba(255, 255, 255, 1);
    transform: scale(1.15);
}

.obra-play-icon i {
    font-size: 36px;
    color: #dc3545;
    margin-left: 5px;
}
```

**Efeito hover:**
```css
.obra-thumbnail-container:hover img {
    transform: scale(1.05);
}
```

## 🎨 Interface do Usuário

### Formulário de Criação

**Antes:**
```
┌────────────────────────────┐
│ Título: [____________]     │
│ Descrição: [_________]     │
│ Arquivo: [Escolher] *      │ ← OBRIGATÓRIO
│ Vídeo: [__________]        │
└────────────────────────────┘
```

**Agora:**
```
┌────────────────────────────┐
│ Título: [____________]     │
│ Descrição: [_________]     │
│ YouTube: [__________]      │ ← Arquivo OU YouTube
│ Arquivo: [Escolher]        │
│                            │
│ Arquivo ou YouTube         │
│ é obrigatório              │
└────────────────────────────┘
```

### Visualização da Obra

**Com YouTube:**
```
┌───────────────────────────┐
│    ┌─────────────────┐    │
│    │   THUMBNAIL     │    │
│    │                 │    │
│    │       ◯         │    │ ← Play icon centralizado
│    │      ▶          │    │
│    │                 │    │
│    └─────────────────┘    │
│                           │
│ Título da Obra            │
│ [Livro] [2024] [PDF]      │
│                           │
│ Descrição...              │
│                           │
│ [📥 Baixar Obra]          │ ← Só se tiver arquivo
└───────────────────────────┘
```

**Sem YouTube:**
```
┌───────────────────────────┐
│    ┌─────────────────┐    │
│    │   THUMBNAIL     │    │
│    │      ou         │    │
│    │   ÍCONE LIVRO   │    │
│    └─────────────────┘    │ ← SEM play icon
│                           │
│ Título da Obra            │
│ [Livro] [2024] [PDF]      │
│                           │
│ [📥 Baixar Obra]          │
└───────────────────────────┘
```

## 🔄 Fluxo de Criação

### Fluxo 1: Criar com YouTube
```
1. Usuário acessa /content/create
2. Preenche título, tipo, descrição
3. Cola URL do YouTube
4. NÃO envia arquivo
5. Clica "Adicionar Obra"
         ↓
6. Backend valida: has_youtube_url = True
7. Backend extrai ID do vídeo
8. Backend gera thumbnail automática
9. Salva obra SEM arquivo
         ↓
10. Obra criada com sucesso
11. Thumbnail do YouTube aparece
12. Play icon na thumbnail
13. Clique → abre YouTube
```

### Fluxo 2: Criar com YouTube e Arquivo
```
1. Usuário acessa /content/create
2. Preenche título, tipo, descrição
3. Cola URL do YouTube
4. Faz upload do PDF
5. Clica "Adicionar Obra"
         ↓
6. Backend valida: has_file AND has_youtube_url = True
7. Processa upload do arquivo
8. Extrai ID do vídeo
9. Gera thumbnail do YouTube
10. Salva obra COM arquivo e URL
         ↓
11. Obra criada com sucesso
12. Thumbnail do YouTube
13. Play icon na thumbnail
14. Botão de download disponível
```

### Fluxo 3: Criar só com Arquivo
```
1. Usuário acessa /content/create
2. Preenche título, tipo, descrição
3. NÃO cola URL do YouTube
4. Faz upload do PDF/EPUB
5. Clica "Adicionar Obra"
         ↓
6. Backend valida: has_file = True
7. Processa upload do arquivo
8. NÃO gera thumbnail automática
9. Salva obra COM arquivo, SEM URL
         ↓
10. Obra criada com sucesso
11. Thumbnail manual ou ícone de livro
12. SEM play icon
13. Botão de download disponível
```

## 🛡️ Validações

### Frontend
- ✅ Campo URL aceita qualquer URL válida
- ✅ Campo arquivo aceita apenas .pdf e .epub
- ✅ Nenhum dos dois é `required` (validação no backend)

### Backend

**Criar obra:**
```python
# Validação principal
if not has_file and not has_youtube_url:
    flash('É obrigatório fornecer um arquivo (PDF/EPUB) ou um link do YouTube.', 'danger')
    return render_template('content/create.html')
```

**Editar obra:**
- Arquivo e URL permanecem opcionais
- Thumbnail automática gerada se URL for fornecida sem thumbnail manual

## 📊 Matriz de Funcionalidades

| Situação | Arquivo | YouTube | Thumbnail | Play Icon | Download | Comportamento |
|----------|---------|---------|-----------|-----------|----------|---------------|
| 1 | ✅ | ❌ | Manual/Vazio | ❌ | ✅ | Obra tradicional |
| 2 | ❌ | ✅ | Automática | ✅ | ❌ | Só vídeo |
| 3 | ✅ | ✅ | Automática | ✅ | ✅ | Completa |
| 4 | ✅ | ✅ | Manual | ✅ | ✅ | Completa custom |
| 5 | ❌ | ❌ | - | - | - | ❌ INVÁLIDO |

## 🎯 Helpers do YouTube

### `extract_youtube_id(url)`
Extrai o ID do vídeo de várias formas de URL do YouTube.

**Formatos suportados:**
- `https://youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://youtube.com/embed/VIDEO_ID`
- `https://youtube.com/shorts/VIDEO_ID`
- `https://m.youtube.com/watch?v=VIDEO_ID`

**Exemplo:**
```python
from app.utils.helpers import extract_youtube_id

url = "https://youtube.com/watch?v=abc123"
video_id = extract_youtube_id(url)
# Retorna: "abc123"
```

### `youtube_thumbnail_url(video_id, quality)`
Gera a URL da thumbnail do YouTube.

**Qualidades disponíveis:**
- `default` - 120x90
- `mqdefault` - 320x180
- `hqdefault` - 480x360
- `sddefault` - 640x480
- `maxresdefault` - 1280x720 (usado por padrão)

**Exemplo:**
```python
from app.utils.helpers import youtube_thumbnail_url

video_id = "abc123"
thumbnail = youtube_thumbnail_url(video_id, quality='maxresdefault')
# Retorna: "https://img.youtube.com/vi/abc123/maxresdefault.jpg"
```

## 🧪 Testes

### Teste 1: Criar Obra só com YouTube
1. Acesse `/content/create`
2. Título: "Teste YouTube"
3. Tipo: Livro
4. URL: `https://youtube.com/watch?v=dQw4w9WgXcQ`
5. Arquivo: (vazio)
6. Salve
7. ✅ Deve criar obra com thumbnail do YouTube
8. ✅ Deve mostrar play icon
9. ✅ Clicar na imagem abre YouTube

### Teste 2: Criar Obra com Ambos
1. Acesse `/content/create`
2. Preencha todos os campos
3. YouTube: `https://youtube.com/watch?v=test`
4. Arquivo: teste.pdf
5. Salve
6. ✅ Deve criar obra com thumbnail do YouTube
7. ✅ Play icon na imagem
8. ✅ Botão de download disponível

### Teste 3: Criar Obra só com Arquivo
1. Acesse `/content/create`
2. Preencha campos
3. YouTube: (vazio)
4. Arquivo: teste.pdf
5. Salve
6. ✅ Deve criar obra
7. ✅ SEM play icon
8. ✅ Botão de download disponível

### Teste 4: Erro - Sem Arquivo e Sem YouTube
1. Acesse `/content/create`
2. Preencha apenas título e descrição
3. YouTube: (vazio)
4. Arquivo: (vazio)
5. Tente salvar
6. ✅ Deve mostrar erro: "É obrigatório fornecer um arquivo (PDF/EPUB) ou um link do YouTube."

### Teste 5: Thumbnail Manual Prevalece
1. Acesse `/content/create`
2. YouTube: `https://youtube.com/watch?v=test`
3. Thumbnail: `https://example.com/custom.jpg`
4. Salve
5. ✅ Deve usar thumbnail custom (não a do YouTube)
6. ✅ Play icon deve aparecer

### Teste 6: Hover na Thumbnail
1. Acesse obra com YouTube
2. Passe o mouse sobre a thumbnail
3. ✅ Overlay deve escurecer
4. ✅ Play icon deve aumentar
5. ✅ Imagem deve dar zoom leve

## 📁 Arquivos Modificados

1. **`app/blueprints/content.py`**
   - Linhas 78-84: Validação arquivo OU YouTube
   - Linhas 86-111: Upload opcional de arquivo
   - Linhas 113-118: Thumbnail automática do YouTube
   - Linhas 198-203: Thumbnail automática no edit

2. **`app/templates/content/create.html`**
   - Linhas 36-46: Campos YouTube e arquivo reordenados

3. **`app/templates/content/edit.html`**
   - Linhas 42-52: Mesma estrutura do create

4. **`app/templates/content/view.html`**
   - Linhas 27-54: Thumbnail com play icon condicional
   - Removido botão "Assistir Vídeo"

5. **`app/templates/content/list.html`**
   - Linhas 21-48: Cards com play icon condicional

6. **`app/static/style.css`**
   - Linhas finais: CSS do play icon e overlay

## ✅ Status

**Implementação Completa** 🎉

Todas as funcionalidades solicitadas foram implementadas:
- ✅ Thumbnail automática do YouTube
- ✅ Play icon centralizado na imagem
- ✅ PDF/EPUB opcional com YouTube
- ✅ Validação arquivo OU YouTube obrigatório
- ✅ Interface responsiva e moderna

O sistema agora oferece flexibilidade total para criar obras com vídeo, arquivo, ou ambos!
