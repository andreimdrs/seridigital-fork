# 🌟 Sistema de Avaliações e Funcionalidades de Exclusão

## 📋 Resumo das Implementações

Este documento descreve as novas funcionalidades adicionadas ao sistema:

1. ✅ **Botões de editar e excluir obras melhorados**
2. ✅ **Sistema de avaliações com estrelas (estilo Google Play)**
3. ✅ **Sistema de comentários nas obras**
4. ✅ **Exclusão de posts em comunidades**
5. ✅ **Exclusão de comentários em posts de comunidades**
6. ✅ **Exclusão de avaliações nas obras**

---

## 🎨 1. Botões de Editar e Excluir Melhorados

### Antes
```html
<a href="..." class="btn btn-outline-primary btn-sm">Editar</a>
<button class="btn btn-outline-danger btn-sm">Deletar</button>
```

### Agora
```html
<a href="..." class="btn btn-primary">
    <i class="fas fa-edit"></i> Editar
</a>
<button class="btn btn-danger">
    <i class="fas fa-trash-alt"></i> Excluir
</button>
```

### Melhorias
- ✅ Cores sólidas (não apenas outline)
- ✅ Ícones FontAwesome
- ✅ Texto descritivo junto ao ícone
- ✅ Melhor hierarquia visual
- ✅ Confirmação ao excluir

---

## ⭐ 2. Sistema de Avaliações (Estilo Google Play)

### Funcionalidades

**Avaliação com Estrelas (1-5)**
- Interface intuitiva de seleção de estrelas
- Hover interativo
- Visualização da nota selecionada

**Comentário Opcional**
- Campo de texto para review detalhado
- Pode avaliar apenas com estrelas
- Ou adicionar comentário junto

**Média de Avaliações**
- Cálculo automático da média
- Exibição com estrelas visuais
- Contagem total de avaliações

**Atualização de Avaliação**
- Usuário pode editar sua avaliação
- Uma avaliação por usuário por obra
- Atualiza automaticamente se já existir

### Interface

**Formulário de Avaliação**
```
┌────────────────────────────────────┐
│ Deixe sua avaliação                │
├────────────────────────────────────┤
│ Sua nota:                          │
│ ☆ ☆ ☆ ☆ ☆  (clicável)             │
│                                    │
│ Seu comentário (opcional):         │
│ [_______________________________]  │
│ [_______________________________]  │
│                                    │
│ [📤 Enviar Avaliação]              │
└────────────────────────────────────┘
```

**Cabeçalho da Seção**
```
Avaliações e Comentários        ★★★★☆ 4.3 (15 avaliações)
```

**Lista de Avaliações**
```
┌────────────────────────────────────┐
│ João Silva        ★★★★★            │
│ 15/01/2025 às 14:30         [🗑]  │
│                                    │
│ Excelente obra! Recomendo muito.   │
└────────────────────────────────────┘
```

### Backend

**Modelo Rating Atualizado**
```python
class Rating(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('tb_users.usr_id'))
    content_id = db.Column(db.Integer, db.ForeignKey('tb_contents.cnt_id'))
    rating = db.Column(db.Integer, nullable=False)  # 1-5
    review = db.Column(db.Text)  # Comentário opcional
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    usuario = db.relationship('Usuario', backref='ratings')
```

**Rotas**

1. **POST `/content/<id>/rating`** - Adicionar/atualizar avaliação
   - Requer login
   - Valida nota (1-5)
   - Atualiza se já existir
   - Cria nova se não existir

2. **POST `/content/rating/<id>/delete`** - Excluir avaliação
   - Requer login
   - Apenas autor ou admin pode excluir
   - Remove do banco de dados
   - Atualiza média automaticamente

**Lógica na View**
```python
# Calcular média
avg_rating = db.session.query(func.avg(Rating.rating))\
    .filter_by(content_id=content_id).scalar()

# Buscar avaliação do usuário
user_rating = Rating.query.filter_by(
    user_id=current_user.id,
    content_id=content_id
).first()

# Listar todas as avaliações
ratings = Rating.query.filter_by(content_id=content_id)\
    .order_by(Rating.created_at.desc()).all()
```

### CSS para Estrelas

**Seleção de Estrelas (Input)**
```css
.rating-input {
    display: flex;
    flex-direction: row-reverse;
    justify-content: flex-end;
    gap: 5px;
}

.rating-input input[type="radio"] {
    display: none;
}

.rating-input label {
    cursor: pointer;
    font-size: 2rem;
    color: #ddd;
    transition: color 0.2s;
}

.rating-input label:hover,
.rating-input label:hover ~ label,
.rating-input input[type="radio"]:checked ~ label {
    color: #ffc107;
}
```

**Exibição de Estrelas**
```css
.rating-stars i {
    font-size: 1.2rem;
}
```

### Permissões de Exclusão

**Pode excluir avaliação:**
- ✅ Autor da avaliação
- ✅ Administrador do sistema

**Não pode excluir:**
- ❌ Outros usuários
- ❌ Visitantes não autenticados

---

## 🗑️ 3. Exclusão de Posts em Comunidades

### Funcionalidade

**Botão de Exclusão**
- Aparece no canto superior direito do post
- Ícone de lixeira (trash-alt)
- Cor vermelha (danger)
- Tooltip "Excluir post"

**Permissões**
- ✅ Autor do post
- ✅ Dono da comunidade
- ✅ Administrador do sistema

**Confirmação**
- Modal de confirmação JavaScript
- "Tem certeza que deseja excluir este post?"
- Previne exclusões acidentais

**Exclusão em Cascata**
- Remove todos os comentários do post
- Remove todos os likes do post
- Remove o post em si

### Interface

**Estrutura do Post com Botão**
```
┌────────────────────────────────────┐
│ Texto do post...             [🗑]  │ ← Botão de excluir
│ Postado por João em 15/01/25       │
├────────────────────────────────────┤
│ [Curtir] [Comentar]                │
└────────────────────────────────────┘
```

### Implementação

**HTML Template**
```html
<div class="d-flex justify-content-between align-items-start mb-2">
    <div class="flex-grow-1">
        <p>{{ msg.content }}</p>
        <small>Postado por {{ msg.usuario.nome }}</small>
    </div>
    {% if current_user.is_authenticated and 
         (current_user.id == msg.user_id or 
          current_user.is_admin or 
          current_user.id == comunidade.owner_id) %}
        <button class="btn btn-sm btn-outline-danger delete-post-btn" 
                data-community-id="{{ comunidade.id }}" 
                data-post-id="{{ msg.id }}"
                title="Excluir post">
            <i class="fas fa-trash-alt"></i>
        </button>
    {% endif %}
</div>
```

**JavaScript**
```javascript
postsContainer.addEventListener('click', async (e) => {
    const btn = e.target.closest('.delete-post-btn');
    if (!btn) return;
    
    if (!confirm('Tem certeza que deseja excluir este post?')) return;
    
    const communityId = btn.getAttribute('data-community-id');
    const postId = btn.getAttribute('data-post-id');
    
    const res = await fetch(
        `/comunidade/${communityId}/post/${postId}/delete`,
        {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }
    );
    
    if (res.ok) {
        const card = btn.closest('.card');
        if (card) card.remove();
        alert('Post excluído com sucesso!');
    }
});
```

**Backend (comunidade.py)**
```python
@comunidade_bp.route('/<int:community_id>/post/<int:post_id>/delete', 
                     methods=['POST'])
@login_required
def delete_post(community_id, post_id):
    post = CommunityPost.query.get_or_404(post_id)
    comunidade = Community.query.get_or_404(community_id)
    
    # Verificar permissão
    if (current_user.id != post.user_id and 
        not current_user.is_admin and 
        current_user.id != comunidade.owner_id):
        return jsonify({'success': False}), 403
    
    # Deletar em cascata
    CommunityComment.query.filter_by(post_id=post_id).delete()
    CommunityLike.query.filter_by(post_id=post_id).delete()
    db.session.delete(post)
    db.session.commit()
    
    return jsonify({'success': True})
```

---

## 💬 4. Exclusão de Comentários em Posts

### Funcionalidade

**Botão de Exclusão**
- Aparece no canto direito do comentário
- Ícone X (times)
- Cor vermelha (danger)
- Pequeno e discreto (btn-sm)

**Permissões**
- ✅ Autor do comentário
- ✅ Dono da comunidade
- ✅ Administrador do sistema

**Atualização Automática**
- Remove comentário da interface
- Atualiza contagem de comentários
- Sem reload da página

### Interface

**Comentário com Botão**
```
┌────────────────────────────────────┐
│ Maria Silva      15/01/25 14:30 [×]│ ← Botão de excluir
│ Concordo totalmente!               │
└────────────────────────────────────┘
```

### Implementação

**HTML Template**
```html
<div class="comment-item">
    <div class="d-flex justify-content-between align-items-start">
        <div class="flex-grow-1">
            <strong>{{ c.user.nome }}</strong>
            <small>{{ c.created_at.strftime('%d/%m/%Y %H:%M') }}</small>
            <div>{{ c.text }}</div>
        </div>
        {% if current_user.is_authenticated and 
             (current_user.id == c.user_id or 
              current_user.is_admin or 
              current_user.id == comunidade.owner_id) %}
            <button class="btn btn-sm btn-outline-danger delete-comment-btn" 
                    data-comment-id="{{ c.id }}"
                    data-post-id="{{ msg.id }}"
                    title="Excluir comentário">
                <i class="fas fa-times"></i>
            </button>
        {% endif %}
    </div>
</div>
```

**JavaScript**
```javascript
postsContainer.addEventListener('click', async (e) => {
    const btn = e.target.closest('.delete-comment-btn');
    if (!btn) return;
    
    if (!confirm('Tem certeza que deseja excluir este comentário?')) return;
    
    const commentId = btn.getAttribute('data-comment-id');
    const postId = btn.getAttribute('data-post-id');
    
    const res = await fetch(`/comunidade/comment/${commentId}/delete`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    });
    
    if (res.ok) {
        const data = await res.json();
        const commentItem = btn.closest('.comment-item');
        if (commentItem) commentItem.remove();
        
        // Atualizar contagem
        const countEl = document.querySelector(
            `.comments-count[data-post-id="${postId}"]`
        );
        if (countEl) {
            countEl.textContent = String(data.comments_count);
        }
        
        alert('Comentário excluído com sucesso!');
    }
});
```

**Backend (comunidade.py)**
```python
@comunidade_bp.route('/comment/<int:comment_id>/delete', methods=['POST'])
@login_required
def delete_comment(comment_id):
    comentario = CommunityComment.query.get_or_404(comment_id)
    post = CommunityPost.query.get(comentario.post_id)
    comunidade = Community.query.get(post.community_id)
    
    # Verificar permissão
    if (current_user.id != comentario.user_id and 
        not current_user.is_admin and 
        current_user.id != comunidade.owner_id):
        return jsonify({'success': False}), 403
    
    db.session.delete(comentario)
    db.session.commit()
    
    # Contar comentários restantes
    comments_count = CommunityComment.query\
        .filter_by(post_id=comentario.post_id).count()
    
    return jsonify({
        'success': True,
        'comments_count': comments_count
    })
```

---

## 🔐 Sistema de Permissões

### Matriz de Permissões

| Ação | Autor | Admin | Dono Comunidade | Outros |
|------|-------|-------|-----------------|--------|
| **Obras** | | | | |
| Editar obra | ✅ | ✅ | ❌ | ❌ |
| Excluir obra | ✅ | ✅ | ❌ | ❌ |
| Avaliar obra | ✅ | ✅ | ✅ | ✅ (logados) |
| Excluir avaliação | ✅ (própria) | ✅ | ❌ | ❌ |
| **Comunidades** | | | | |
| Criar post | ✅ | ✅ | ✅ | ✅ (membros) |
| Excluir post | ✅ (próprio) | ✅ | ✅ | ❌ |
| Comentar post | ✅ | ✅ | ✅ | ✅ (membros) |
| Excluir comentário | ✅ (próprio) | ✅ | ✅ | ❌ |
| Excluir comunidade | ❌ | ✅ | ✅ | ❌ |

---

## 🗄️ Migração do Banco de Dados

### Campo Adicionado

**Tabela: `tb_ratings`**
- **Coluna**: `rat_review`
- **Tipo**: TEXT
- **Nullable**: True (opcional)
- **Descrição**: Comentário/review do usuário sobre a obra

### Script de Migração

**Arquivo: `app/migrate_ratings.py`**
```python
def migrate_ratings():
    """Adiciona campo review à tabela tb_ratings"""
    cursor.execute("""
        ALTER TABLE tb_ratings 
        ADD COLUMN rat_review TEXT
    """)
    conn.commit()
```

**Integração no Startup**
- Executado automaticamente ao iniciar a aplicação
- Verifica se a coluna já existe
- Adiciona apenas se necessário
- Logs informativos

---

## 📁 Arquivos Modificados

### 1. **app/models.py**
- Adicionado campo `review` ao modelo `Rating`
- Adicionado relacionamento `usuario` em `Rating`

### 2. **app/blueprints/content.py**
- Adicionado import de `Rating`
- Atualizado `view_content()` para carregar avaliações
- Adicionado `add_rating()` - criar/atualizar avaliação
- Adicionado `delete_rating()` - excluir avaliação

### 3. **app/templates/content/view.html**
- **REESCRITO COMPLETAMENTE**
- Botões de editar/excluir melhorados
- Sistema completo de avaliações
- Formulário de avaliação com estrelas
- Lista de avaliações
- CSS inline para estrelas

### 4. **app/templates/comunidade.html**
- Adicionado botão de excluir posts
- Adicionado botão de excluir comentários
- JavaScript para exclusões (AJAX)
- Atualização dinâmica da interface

### 5. **app/blueprints/comunidade.py**
- Adicionado `delete_post()` - excluir posts
- Adicionado `delete_comment()` - excluir comentários
- Suporte a requisições AJAX
- Retorno JSON para atualização dinâmica

### 6. **app/migrate_ratings.py** (NOVO)
- Script de migração do banco de dados
- Adiciona campo `rat_review`

---

## 🧪 Como Testar

### Teste 1: Avaliar Obra
1. Acesse uma obra
2. Role até "Avaliações e Comentários"
3. Selecione estrelas (1-5)
4. (Opcional) Escreva comentário
5. Clique "Enviar Avaliação"
6. ✅ Avaliação deve aparecer na lista
7. ✅ Média deve ser atualizada

### Teste 2: Editar Avaliação
1. Acesse obra já avaliada por você
2. Formulário deve mostrar sua avaliação
3. Altere estrelas ou comentário
4. Clique "Atualizar Avaliação"
5. ✅ Avaliação deve ser atualizada
6. ✅ Média recalculada

### Teste 3: Excluir Avaliação
1. Acesse obra com sua avaliação
2. Localize sua avaliação na lista
3. Clique no botão lixeira
4. Confirme exclusão
5. ✅ Avaliação deve sumir
6. ✅ Média recalculada

### Teste 4: Excluir Post
1. Acesse comunidade
2. Localize post seu (ou sendo admin/dono)
3. Clique botão lixeira no post
4. Confirme exclusão
5. ✅ Post deve sumir
6. ✅ Comentários deletados junto

### Teste 5: Excluir Comentário
1. Acesse comunidade
2. Localize seu comentário em um post
3. Clique X no comentário
4. Confirme exclusão
5. ✅ Comentário deve sumir
6. ✅ Contagem atualizada

### Teste 6: Permissões
1. Tente excluir avaliação de outro usuário
2. ✅ Botão não deve aparecer
3. Tente excluir post de outro (não sendo dono/admin)
4. ✅ Botão não deve aparecer
5. Login como admin
6. ✅ Botões devem aparecer para tudo

---

## 🎨 Melhorias de UX

### Antes vs Agora

**Botões de Ação**
```
ANTES:
[Editar] [Deletar]  (texto simples, outline)

AGORA:
[📝 Editar] [🗑️ Excluir]  (ícones, cores sólidas)
```

**Avaliações**
```
ANTES:
"Funcionalidade em desenvolvimento"

AGORA:
⭐⭐⭐⭐⭐ 4.5 (20 avaliações)
[Formulário interativo]
[Lista de reviews completa]
```

**Exclusões**
```
ANTES:
Não havia como excluir posts/comentários

AGORA:
[🗑️] Botões discretos mas acessíveis
Confirmação antes de excluir
Feedback visual imediato
```

---

## 🚀 Próximas Melhorias (Sugestões)

### Para o Sistema de Avaliações
1. **Filtros de Avaliações**
   - Ordenar por: mais recentes, mais úteis, maior/menor nota
   - Filtrar por: 5 estrelas, 4 estrelas, etc.

2. **Utilidade de Avaliações**
   - Botões "Esta avaliação foi útil?"
   - Contadores de utilidade

3. **Respostas a Avaliações**
   - Autor da obra pode responder reviews
   - Thread de discussão

### Para Comunidades
1. **Edição de Posts**
   - Permitir editar posts após publicação
   - Marcar como "editado"

2. **Denúncias**
   - Botão para denunciar posts/comentários
   - Sistema de moderação

3. **Reações**
   - Além de curtir: ❤️ 😂 😮 😢 😠
   - Múltiplas reações

### Para Interface
1. **Toasts em vez de Alerts**
   - Notificações elegantes
   - Não bloqueiam a tela

2. **Loading States**
   - Spinners durante requisições
   - Feedback visual de carregamento

3. **Animações**
   - Fade out ao excluir
   - Slide in ao adicionar

---

## ✅ Status de Implementação

| Funcionalidade | Status | Arquivo |
|----------------|--------|---------|
| Botões melhorados | ✅ Completo | `content/view.html` |
| Sistema de estrelas | ✅ Completo | `content/view.html` |
| Avaliações com comentário | ✅ Completo | `content.py` + `view.html` |
| Excluir avaliações | ✅ Completo | `content.py` |
| Excluir posts | ✅ Completo | `comunidade.py` + `comunidade.html` |
| Excluir comentários | ✅ Completo | `comunidade.py` + `comunidade.html` |
| Migração do BD | ✅ Completo | `migrate_ratings.py` |

---

## 🎉 Conclusão

Todas as funcionalidades solicitadas foram implementadas com sucesso:

✅ **Botões bonitos** - Ícones + cores sólidas  
✅ **Avaliações estilo Google Play** - Estrelas + comentários  
✅ **Exclusão de posts** - Com permissões adequadas  
✅ **Exclusão de comentários** - Interface dinâmica  
✅ **Exclusão de avaliações** - Apenas autor ou admin  

O sistema está pronto para uso!
