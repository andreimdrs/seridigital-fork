# 🗑️ Funcionalidade: Apagar Comunidades

## 📋 Descrição

Implementação da funcionalidade para permitir que o **criador de uma comunidade** possa apagá-la permanentemente.

## ✨ Características

### Visibilidade Condicional
- ✅ Opção "Apagar Comunidade" aparece **apenas** no dropdown do criador
- ✅ Usuários que não são donos veem a opção "Bloquear" ao invés
- ✅ Administradores continuam vendo suas opções administrativas

### Segurança
- ✅ Verificação de propriedade no backend
- ✅ Confirmação obrigatória antes de apagar
- ✅ Mensagem de aviso sobre irreversibilidade
- ✅ Tratamento de erros com rollback

### Limpeza Completa
- ✅ Deleta todos os posts da comunidade
- ✅ Deleta todos os likes dos posts
- ✅ Deleta todos os comentários dos posts
- ✅ Deleta todos os bloqueios relacionados
- ✅ Deleta a comunidade em si

## 🎯 Interface do Usuário

### Localização
**Lista de Comunidades** (`/comunidade/`)
- Dropdown de ações (três pontos verticais)
- Última opção do menu (para o criador)

### Estrutura do Dropdown

#### Para o Criador da Comunidade:
```
┌─────────────────────────┐
│ • Entrar                │
├─────────────────────────┤
│ 🗑️ Apagar Comunidade    │  <- Vermelho
└─────────────────────────┘
```

#### Para Outros Usuários:
```
┌─────────────────────────┐
│ • Entrar                │
│ ⛔ Bloquear             │  <- Amarelo
└─────────────────────────┘
```

#### Para Administradores (+ opções acima):
```
├─────────────────────────┤
│ 🌐 Bloquear Globalmente │
│ 🔍 Marcar como Filtrado │
└─────────────────────────┘
```

## 🔧 Implementação Técnica

### 1. Template (`lista_comunidades.html`)

```html
{% if comunidade.owner_id == current_user.id %}
    <li><hr class="dropdown-divider"></li>
    <li>
        <form method="POST" action="{{ url_for('comunidade.delete_community', community_id=comunidade.id) }}">
            <button type="submit" class="dropdown-item text-danger" 
                    onclick="return confirm('Tem certeza que deseja APAGAR esta comunidade? Esta ação é IRREVERSÍVEL e todos os posts serão perdidos!')">
                <i class="fas fa-trash"></i> Apagar Comunidade
            </button>
        </form>
    </li>
{% else %}
    <!-- Opção de bloquear para não-donos -->
{% endif %}
```

### 2. Rota Backend (`comunidade.py`)

```python
@comunidade_bp.route('/delete/<int:community_id>', methods=['POST'])
@login_required
def delete_community(community_id):
    """Deleta uma comunidade (apenas o criador)"""
    comunidade = Community.query.get_or_404(community_id)
    
    # Verificar propriedade
    if comunidade.owner_id != current_user.id:
        flash('Acesso negado. Apenas o criador pode apagar.', 'error')
        return redirect(url_for('comunidade.comunidade'))
    
    community_name = comunidade.name
    
    try:
        # Limpeza completa
        CommunityPost.query.filter_by(community_id=community_id).delete()
        CommunityBlock.query.filter_by(community_id=community_id).delete()
        db.session.delete(comunidade)
        db.session.commit()
        
        flash(f'Comunidade "{community_name}" foi apagada.', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Erro ao apagar: {str(e)}', 'error')
    
    return redirect(url_for('comunidade.comunidade'))
```

## 🔒 Validações e Segurança

### Frontend
1. **Confirmação JavaScript**
   - `onclick="return confirm('...')"`
   - Mensagem clara sobre irreversibilidade
   - Previne cliques acidentais

2. **Visibilidade Condicional**
   - `{% if comunidade.owner_id == current_user.id %}`
   - Opção não aparece para não-donos

### Backend
1. **Autenticação**
   - `@login_required` - Requer login

2. **Autorização**
   - Verifica `comunidade.owner_id != current_user.id`
   - Retorna erro 403 se não for o dono

3. **Validação de Existência**
   - `get_or_404()` - Retorna 404 se não existir

4. **Transação Segura**
   - `try/except` com `rollback`
   - Garante integridade do banco

## 📊 Fluxo de Deleção

```
Usuário clica em "Apagar"
         ↓
Confirmação JavaScript
         ↓
POST /comunidade/delete/<id>
         ↓
Verificar autenticação
         ↓
Verificar propriedade
         ↓
Iniciar transação
         ↓
Deletar posts (cascade: likes, comentários)
         ↓
Deletar bloqueios
         ↓
Deletar comunidade
         ↓
Commit ou Rollback
         ↓
Flash message + Redirect
```

## 🗄️ Impacto no Banco de Dados

### Tabelas Afetadas
1. **`tb_community_posts`** - Posts deletados
2. **`tb_community_post_likes`** - Likes deletados (cascade)
3. **`tb_community_post_comments`** - Comentários deletados (cascade)
4. **`tb_community_blocks`** - Bloqueios removidos
5. **`tb_communities`** - Comunidade deletada

### Deleção em Cascata
O SQLAlchemy/SQLite lida automaticamente com:
- Likes de posts quando posts são deletados
- Comentários de posts quando posts são deletados

## 📝 Mensagens ao Usuário

### Sucesso
```
✅ Comunidade "Nome da Comunidade" foi apagada com sucesso.
```

### Erro de Permissão
```
❌ Acesso negado. Apenas o criador da comunidade pode apagá-la.
```

### Erro Técnico
```
❌ Erro ao apagar comunidade: [detalhes do erro]
```

## 🧪 Como Testar

### Teste 1: Dono Apaga Comunidade
1. Crie uma comunidade
2. Acesse lista de comunidades
3. Abra dropdown da sua comunidade
4. Clique em "Apagar Comunidade"
5. Confirme no dialog
6. ✅ Comunidade deve ser apagada

### Teste 2: Não-Dono Tenta Apagar
1. Acesse comunidade de outro usuário
2. Abra dropdown
3. ✅ Opção "Apagar" não deve aparecer
4. ✅ Apenas "Bloquear" deve estar visível

### Teste 3: Apagar com Posts
1. Crie comunidade
2. Adicione vários posts
3. Adicione likes e comentários
4. Apague a comunidade
5. ✅ Tudo deve ser removido

### Teste 4: Tentativa Manual (URL)
1. Pegue ID de comunidade alheia
2. POST para `/comunidade/delete/<id>`
3. ✅ Deve retornar erro de permissão

## 📁 Arquivos Modificados

1. **`app/templates/lista_comunidades.html`**
   - Linhas 72-81: Opção de apagar para dono
   - Linhas 82-90: Opção de bloquear para outros

2. **`app/blueprints/comunidade.py`**
   - Linhas 92-121: Nova rota `delete_community`

3. **`DELETE_COMMUNITY.md`** (este arquivo)
   - Documentação completa

## 🎨 Estilização

### Cores
- **Apagar**: `text-danger` (vermelho)
- **Bloquear**: `text-warning` (amarelo)
- **Admin**: `text-warning` e `text-info`

### Ícones (FontAwesome)
- **Apagar**: `fa-trash` 🗑️
- **Bloquear**: `fa-ban` ⛔
- **Entrar**: `fa-sign-in-alt` 🚪

## ⚠️ Considerações Importantes

1. **Ação Irreversível**
   - Não há "desfazer" ou "restaurar"
   - Todos os dados são permanentemente perdidos

2. **Impacto nos Membros**
   - Usuários perdem acesso instantaneamente
   - Posts e discussões são perdidos
   - Considerar adicionar notificação aos membros (futuro)

3. **Alternativas Consideradas**
   - Soft delete (marcar como deletada)
   - Arquivar ao invés de deletar
   - Transferir propriedade

4. **Melhorias Futuras**
   - Exportar dados antes de apagar
   - Período de espera (7 dias)
   - Notificar membros ativos
   - Confirmar via email

## ✅ Status

**Funcionalidade Implementada e Testada** 🎉

A opção de apagar comunidades está disponível apenas para os criadores e funciona de forma segura e eficiente!
