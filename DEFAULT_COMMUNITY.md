# 🏛️ Comunidade e Conta Padrão SeriDigital

## 📋 Descrição

Implementação de dados padrão que são criados automaticamente na inicialização da aplicação:
- **Conta Oficial**: `SeriDigital`
- **Comunidade Oficial**: `SeriDigital`

## ✨ Características

### Conta SeriDigital

**Credenciais:**
- 📧 **Email**: `seridigital@oficial`
- 🔑 **Senha**: `seridigital123`
- 👤 **Nome**: `SeriDigital`
- 🛡️ **Tipo**: Administrador (is_admin=True)

**Propósito:**
- Proprietário da comunidade oficial
- Conta administrativa para gerenciar a plataforma
- Representação oficial da plataforma

### Comunidade SeriDigital

**Informações:**
- 🏷️ **Nome**: `SeriDigital`
- 📝 **Descrição**: "Comunidade oficial do SeriDigital. Participe das discussões sobre livros, manifestos e cultura digital!"
- 👤 **Dono**: Conta SeriDigital
- ✅ **Status**: `active`
- 🔓 **Filtrado**: `false` (conteúdo público)

**Propósito:**
- Comunidade principal da plataforma
- Espaço para discussões gerais
- Sempre disponível para todos os usuários

## 🔧 Implementação Técnica

### 1. Módulo de Inicialização (`init_default_data.py`)

```python
def create_default_account_and_community():
    """Cria a conta oficial SeriDigital e a comunidade padrão"""
    
    # 1. Verificar se conta existe
    seridigital_user = Usuario.query.filter_by(email='seridigital@oficial').first()
    
    # 2. Criar conta se não existir
    if not seridigital_user:
        seridigital_user = Usuario(
            nome='SeriDigital',
            email='seridigital@oficial',
            is_admin=True
        )
        seridigital_user.senha = 'seridigital123'
        db.session.add(seridigital_user)
        db.session.commit()
    
    # 3. Verificar se comunidade existe
    seridigital_community = Community.query.filter_by(name='SeriDigital').first()
    
    # 4. Criar comunidade se não existir
    if not seridigital_community:
        seridigital_community = Community(
            owner_id=seridigital_user.id,
            name='SeriDigital',
            description='Comunidade oficial...',
            status='active',
            is_filtered=False
        )
        db.session.add(seridigital_community)
        db.session.commit()
```

### 2. Integração no `__init__.py`

```python
with app.app_context():
    db.create_all()
    
    # Criar dados padrão
    try:
        from .init_default_data import create_default_account_and_community
        create_default_account_and_community()
    except Exception as e:
        print(f"⚠️  Erro ao criar dados padrão: {e}")
```

## 🔄 Comportamento na Inicialização

### Primeira Inicialização
```
🚀 Aplicação iniciando...
📊 Criando tabelas...
✅ Tabelas criadas
📝 Criando conta oficial SeriDigital...
✅ Conta SeriDigital criada com sucesso!
📝 Criando comunidade oficial SeriDigital...
✅ Comunidade SeriDigital criada com sucesso!
```

### Inicializações Subsequentes
```
🚀 Aplicação iniciando...
📊 Verificando tabelas...
✓ Conta SeriDigital já existe
✓ Comunidade SeriDigital já existe
```

## 🛡️ Segurança

### Proteções Implementadas

1. **Verificação de Existência**
   - ✅ Verifica antes de criar para evitar duplicatas
   - ✅ Usa `filter_by()` para busca confiável

2. **Hash de Senha**
   - ✅ Senha armazenada com hash (via setter)
   - ✅ Nunca armazenada em texto plano

3. **Conta Administrativa**
   - ✅ `is_admin=True` para privilégios administrativos
   - ✅ Pode gerenciar todas as comunidades

4. **Tratamento de Erros**
   - ✅ Try/except com rollback
   - ✅ Não quebra a aplicação se falhar
   - ✅ Log de erros para debug

## 🎯 Casos de Uso

### 1. Primeiro Acesso à Plataforma
```
Usuário → Acessa /comunidade/
       → Vê comunidade "SeriDigital"
       → Pode entrar e participar
```

### 2. Login como SeriDigital
```
Admin → Login com seridigital@oficial
      → Acesso total como administrador
      → Gerencia comunidade oficial
      → Pode moderar outras comunidades
```

### 3. Posts Oficiais
```
SeriDigital → Posta atualizações
            → Anuncia novidades
            → Comunica com usuários
```

## 📊 Estrutura de Dados

### Usuário SeriDigital
```sql
INSERT INTO tb_users (
    usr_name, 
    usr_email, 
    usr_password, 
    is_admin
) VALUES (
    'SeriDigital',
    'seridigital@oficial',
    '<hash_bcrypt>',
    1
);
```

### Comunidade SeriDigital
```sql
INSERT INTO tb_communities (
    com_owner_id,
    com_name,
    com_description,
    com_status,
    com_is_filtered
) VALUES (
    <id_do_usuario_seridigital>,
    'SeriDigital',
    'Comunidade oficial do SeriDigital...',
    'active',
    0
);
```

## 🔍 Verificação Manual

### Via Python
```python
from app import create_app
from app.models import Usuario, Community, db

app = create_app()
with app.app_context():
    # Verificar conta
    user = Usuario.query.filter_by(email='seridigital@oficial').first()
    print(f"Conta: {user.nome if user else 'Não existe'}")
    
    # Verificar comunidade
    community = Community.query.filter_by(name='SeriDigital').first()
    print(f"Comunidade: {community.name if community else 'Não existe'}")
```

### Via SQL
```sql
-- Verificar conta
SELECT usr_name, usr_email, is_admin 
FROM tb_users 
WHERE usr_email = 'seridigital@oficial';

-- Verificar comunidade
SELECT com_name, com_description, com_status 
FROM tb_communities 
WHERE com_name = 'SeriDigital';
```

## 🧪 Como Testar

### Teste 1: Primeira Inicialização
1. Limpe o banco de dados (ou use um novo)
2. Inicie a aplicação
3. Verifique os logs de inicialização
4. ✅ Deve ver mensagens de criação

### Teste 2: Login na Conta Oficial
1. Acesse `/auth/login`
2. Email: `seridigital@oficial`
3. Senha: `seridigital123`
4. ✅ Login deve ser bem-sucedido

### Teste 3: Acessar Comunidade
1. Faça login (qualquer conta)
2. Acesse `/comunidade/`
3. ✅ Comunidade "SeriDigital" deve aparecer

### Teste 4: Postar na Comunidade
1. Login como SeriDigital
2. Entre na comunidade oficial
3. Crie um post
4. ✅ Post deve ser criado com sucesso

### Teste 5: Reininicialização
1. Reinicie a aplicação
2. Verifique os logs
3. ✅ Deve ver "já existe" ao invés de "criada"

## ⚠️ Considerações de Segurança

### ⚠️ IMPORTANTE - Produção

**A senha padrão `seridigital123` é para desenvolvimento/demonstração!**

Em produção, você deve:

1. **Trocar a senha imediatamente**
   ```python
   # Via Python
   user = Usuario.query.filter_by(email='seridigital@oficial').first()
   user.senha = 'nova_senha_forte_e_segura'
   db.session.commit()
   ```

2. **Usar variável de ambiente**
   ```python
   import os
   senha_padrao = os.getenv('SERIDIGITAL_PASSWORD', 'seridigital123')
   ```

3. **Implementar troca forçada no primeiro login**
   ```python
   if user.must_change_password:
       return redirect(url_for('auth.change_password'))
   ```

## 📁 Arquivos Criados/Modificados

1. **`app/init_default_data.py`** (novo)
   - Função para criar conta e comunidade padrão
   
2. **`app/__init__.py`** (modificado)
   - Linhas 36-41: Chamada para criar dados padrão
   
3. **`DEFAULT_COMMUNITY.md`** (novo)
   - Este arquivo de documentação

## 🎨 Personalização

### Alterar Descrição da Comunidade
```python
# Em init_default_data.py, linha ~30
description='Sua descrição personalizada aqui!'
```

### Alterar Nome da Conta
```python
# Em init_default_data.py, linha ~13
nome='Seu Nome Aqui'
```

### Alterar Email
```python
# Em init_default_data.py, linha ~14
email='seu@email.com'
```

## 📝 Mensagens de Log

### Sucesso
```
✅ Conta SeriDigital criada com sucesso!
✅ Comunidade SeriDigital criada com sucesso!
```

### Já Existe
```
✓ Conta SeriDigital já existe
✓ Comunidade SeriDigital já existe
```

### Erro
```
❌ Erro ao criar dados padrão: [detalhes do erro]
```

## ✅ Status

**Funcionalidade Implementada** 🎉

A conta e comunidade oficial SeriDigital são criadas automaticamente na primeira inicialização da aplicação!

### Credenciais de Acesso

📧 **Email**: `seridigital@oficial`  
🔑 **Senha**: `seridigital123`  
🏛️ **Comunidade**: Disponível em `/comunidade/`
