# 🔧 Correção: Relacionamentos para Atividades Recentes

## 🚨 Problema Identificado

**Erro:** `AttributeError: type object 'CommunityPost' has no attribute 'user_id'`

**Causa:** Inconsistência nos nomes dos campos entre os modelos.

## 🔍 Problemas Encontrados

### 1. **Campo Incorreto em CommunityPost**
- ❌ **Usado:** `CommunityPost.user_id` 
- ✅ **Correto:** `CommunityPost.author_id`

### 2. **Relacionamentos Ausentes**
- ❌ `CommunityPostComment` sem relacionamento `post`
- ❌ `CommunityPostLike` sem relacionamento `post`

## ✅ Correções Aplicadas

### 1. **Correção do Campo em users.py**

**Antes (Incorreto):**
```python
recent_posts = CommunityPost.query.filter(
    CommunityPost.user_id == user_id,  # ❌ Campo não existe
    CommunityPost.created_at >= thirty_days_ago
).order_by(desc(CommunityPost.created_at)).limit(5).all()
```

**Depois (Correto):**
```python
recent_posts = CommunityPost.query.filter(
    CommunityPost.author_id == user_id,  # ✅ Campo correto
    CommunityPost.created_at >= thirty_days_ago
).order_by(desc(CommunityPost.created_at)).limit(5).all()
```

### 2. **Adição de Relacionamentos em models.py**

**CommunityPostLike (Antes):**
```python
class CommunityPostLike(db.Model):
    user_id = db.Column('cpl_user_id', db.Integer, db.ForeignKey('tb_users.usr_id'))
    post_id = db.Column('cpl_post_id', db.Integer, db.ForeignKey('tb_community_posts.post_id'))
    created_at = db.Column('cpl_created_at', db.DateTime, default=datetime.utcnow)
    # ❌ Sem relacionamentos
```

**CommunityPostLike (Depois):**
```python
class CommunityPostLike(db.Model):
    user_id = db.Column('cpl_user_id', db.Integer, db.ForeignKey('tb_users.usr_id'))
    post_id = db.Column('cpl_post_id', db.Integer, db.ForeignKey('tb_community_posts.post_id'))
    created_at = db.Column('cpl_created_at', db.DateTime, default=datetime.utcnow)
    
    # ✅ Relacionamentos adicionados
    user = db.relationship('Usuario')
    post = db.relationship('CommunityPost')
```

**CommunityPostComment (Antes):**
```python
class CommunityPostComment(db.Model):
    user_id = db.Column('cpc_user_id', db.Integer, db.ForeignKey('tb_users.usr_id'))
    post_id = db.Column('cpc_post_id', db.Integer, db.ForeignKey('tb_community_posts.post_id'))
    text = db.Column('cpc_text', db.Text, nullable=False)
    created_at = db.Column('cpc_created_at', db.DateTime, default=datetime.utcnow)
    
    # ❌ Apenas relacionamento com usuário
    user = db.relationship('Usuario')
```

**CommunityPostComment (Depois):**
```python
class CommunityPostComment(db.Model):
    user_id = db.Column('cpc_user_id', db.Integer, db.ForeignKey('tb_users.usr_id'))
    post_id = db.Column('cpc_post_id', db.Integer, db.ForeignKey('tb_community_posts.post_id'))
    text = db.Column('cpc_text', db.Text, nullable=False)
    created_at = db.Column('cpc_created_at', db.DateTime, default=datetime.utcnow)
    
    # ✅ Relacionamentos completos
    user = db.relationship('Usuario')
    post = db.relationship('CommunityPost')  # ← Adicionado
```

## 📊 Mapeamento de Campos por Modelo

| Modelo | Campo Usuário | Campo Post | Relacionamentos |
|--------|---------------|------------|-----------------|
| **CommunityPost** | `author_id` | - | `usuario`, `comunidade` |
| **CommunityPostComment** | `user_id` | `post_id` | `user`, `post` ✅ |
| **CommunityPostLike** | `user_id` | `post_id` | `user`, `post` ✅ |
| **Rating** | `user_id` | - | `usuario`, `content` |

## 🔗 Relacionamentos Necessários

### Para Atividades Recentes

**Rating → Content:**
```python
rating.content.title  # Nome da obra avaliada
```

**CommunityPost → Community:**
```python
post.comunidade.name  # Nome da comunidade
```

**CommunityPostComment → Post → Community:**
```python
comment.post.comunidade.name  # Nome da comunidade do post comentado
```

**CommunityPostLike → Post → Community:**
```python
like.post.comunidade.name  # Nome da comunidade do post curtido
```

## 🧪 Validação das Correções

### Teste 1: Consulta de Posts
```python
# Deve funcionar agora
recent_posts = CommunityPost.query.filter(
    CommunityPost.author_id == user_id
).all()

for post in recent_posts:
    print(post.comunidade.name)  # ✅ Deve funcionar
```

### Teste 2: Consulta de Comentários
```python
recent_comments = CommunityPostComment.query.filter(
    CommunityPostComment.user_id == user_id
).all()

for comment in recent_comments:
    print(comment.post.comunidade.name)  # ✅ Deve funcionar
```

### Teste 3: Consulta de Likes
```python
recent_likes = CommunityPostLike.query.filter(
    CommunityPostLike.user_id == user_id
).all()

for like in recent_likes:
    print(like.post.comunidade.name)  # ✅ Deve funcionar
```

### Teste 4: Consulta de Avaliações
```python
recent_ratings = Rating.query.filter(
    Rating.user_id == user_id
).all()

for rating in recent_ratings:
    print(rating.content.title)  # ✅ Deve funcionar
```

## 📁 Arquivos Modificados

### 1. **`app/blueprints/users.py`**
- **Linha 33:** `CommunityPost.user_id` → `CommunityPost.author_id`

### 2. **`app/models.py`**
- **Linhas 261-263:** Adicionado relacionamento `post` em `CommunityPostLike`
- **Linha 272:** Adicionado relacionamento `post` em `CommunityPostComment`

## ✅ Resultado

**Erro Resolvido:** ✅
- Consultas funcionando corretamente
- Relacionamentos estabelecidos
- Atividades recentes operacionais

## 🔄 Fluxo Corrigido

### Atividades Recentes - Fluxo Completo
```python
# 1. Buscar posts do usuário
posts = CommunityPost.query.filter(
    CommunityPost.author_id == user_id  # ✅ Campo correto
).all()

# 2. Acessar comunidade do post
for post in posts:
    community_name = post.comunidade.name  # ✅ Relacionamento existe

# 3. Buscar comentários do usuário
comments = CommunityPostComment.query.filter(
    CommunityPostComment.user_id == user_id
).all()

# 4. Acessar post e comunidade do comentário
for comment in comments:
    post_content = comment.post.content        # ✅ Relacionamento adicionado
    community_name = comment.post.comunidade.name  # ✅ Funciona

# 5. Buscar likes do usuário
likes = CommunityPostLike.query.filter(
    CommunityPostLike.user_id == user_id
).all()

# 6. Acessar post e comunidade do like
for like in likes:
    post_content = like.post.content           # ✅ Relacionamento adicionado
    community_name = like.post.comunidade.name     # ✅ Funciona
```

## 🎯 Status Final

**Problema:** ❌ `AttributeError: type object 'CommunityPost' has no attribute 'user_id'`
**Solução:** ✅ Campo corrigido + relacionamentos adicionados
**Status:** ✅ **Funcionalidade Operacional**

A página de perfil com atividades recentes deve funcionar corretamente agora! 🎉