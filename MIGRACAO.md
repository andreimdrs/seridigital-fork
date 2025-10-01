# 🔧 Guia de Migração do Banco de Dados

## Problema

Após a reforma do sistema de obras, o banco de dados precisa de duas novas colunas na tabela `tb_contents`:
- `cnt_file_path` - Para armazenar o caminho do arquivo PDF/EPUB
- `cnt_file_type` - Para armazenar o tipo do arquivo (pdf ou epub)

## Solução Automática ✅

A migração agora é **aplicada automaticamente** quando a aplicação inicia!

O arquivo `app/__init__.py` foi modificado para executar `app/migrate_on_startup.py` que adiciona as colunas necessárias caso elas não existam.

### O que acontece na inicialização:

1. A aplicação cria todas as tabelas (`db.create_all()`)
2. Verifica se a tabela `tb_contents` existe
3. Verifica se as colunas `cnt_file_path` e `cnt_file_type` existem
4. Se não existirem, adiciona automaticamente
5. Confirma as mudanças no banco de dados

## Solução Manual (se necessário)

Se por algum motivo a migração automática não funcionar, você pode aplicar manualmente:

### Opção 1: Usando Python

```bash
cd /workspace
python3 apply_migration.py
```

### Opção 2: Usando SQL direto

```bash
cd /workspace
sqlite3 <caminho_do_banco> < add_columns.sql
```

### Opção 3: Linha de comando SQL

```sql
-- Conecte ao banco de dados e execute:
ALTER TABLE tb_contents ADD COLUMN cnt_file_path VARCHAR(500);
ALTER TABLE tb_contents ADD COLUMN cnt_file_type VARCHAR(10);
```

## Verificação

Para verificar se a migração foi aplicada com sucesso:

```python
import sqlite3
conn = sqlite3.connect('instance/database.db')  # ou outro caminho
cursor = conn.cursor()
cursor.execute('PRAGMA table_info(tb_contents)')
columns = [col[1] for col in cursor.fetchall()]
print('cnt_file_path' in columns and 'cnt_file_type' in columns)
conn.close()
```

Se retornar `True`, a migração foi aplicada com sucesso!

## Localização do Banco de Dados

O banco de dados pode estar em diferentes locais dependendo da configuração:

- `instance/database.db` (padrão Flask)
- `app/database/meubanco.db` (configurado em config.py)

A aplicação usará o caminho definido em `app/config.py`:
```python
SQLALCHEMY_DATABASE_URI = os.getenv(
    "DATABASE_URL",
    f"sqlite:///{os.path.join(basedir, 'database/meubanco.db')}"
)
```

## Mensagens de Log

Quando a aplicação iniciar, você verá uma destas mensagens:

- ✅ `✓ Banco de dados já está atualizado` - Tudo certo!
- 📝 `Adicionando coluna cnt_file_path...` - Aplicando migração
- ✅ `Migração aplicada com sucesso!` - Migração concluída
- ⚠️ `Erro ao aplicar migração: ...` - Algo deu errado

## Troubleshooting

### Erro: "no such column: tb_contents.cnt_file_path"

**Solução**: Reinicie a aplicação. A migração será aplicada automaticamente.

### Erro: "table tb_contents has no column named cnt_file_path"

**Solução**: 
1. Pare a aplicação
2. Execute `python3 apply_migration.py`
3. Reinicie a aplicação

### Erro: "database is locked"

**Solução**:
1. Pare todos os processos que estão acessando o banco
2. Execute a migração novamente

## Arquivos Relacionados

- `app/__init__.py` - Aplicação principal (chama a migração)
- `app/migrate_on_startup.py` - Script de migração automática
- `apply_migration.py` - Script de migração manual
- `add_columns.sql` - SQL direto para migração
- `migrations/versions/add_file_fields_to_content.py` - Arquivo de migração Alembic

## Status

✅ **Migração Automática Configurada**

A próxima vez que a aplicação iniciar, as colunas serão adicionadas automaticamente!
