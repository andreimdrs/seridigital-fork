# app/migrate_ratings.py
"""
Script para adicionar campo 'review' na tabela tb_ratings
"""
import os
import sqlite3

def migrate_ratings():
    """Adiciona campo review à tabela tb_ratings"""
    # Caminho do banco de dados
    db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'app', 'database', 'meubanco.db')
    
    # Tentar também o caminho alternativo
    if not os.path.exists(db_path):
        db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'instance', 'database.db')
    
    if not os.path.exists(db_path):
        print(f"❌ Banco de dados não encontrado em: {db_path}")
        return False
    
    print(f"📁 Usando banco de dados: {db_path}")
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Verificar se a tabela existe
        cursor.execute("""
            SELECT name FROM sqlite_master 
            WHERE type='table' AND name='tb_ratings'
        """)
        
        if not cursor.fetchone():
            print("⚠️  Tabela tb_ratings não existe ainda.")
            conn.close()
            return False
        
        # Verificar se a coluna já existe
        cursor.execute("PRAGMA table_info(tb_ratings)")
        columns = [column[1] for column in cursor.fetchall()]
        
        if 'rat_review' in columns:
            print("✓ Campo rat_review já existe na tabela tb_ratings")
            conn.close()
            return True
        
        # Adicionar coluna rat_review
        print("📝 Adicionando campo rat_review...")
        cursor.execute("""
            ALTER TABLE tb_ratings 
            ADD COLUMN rat_review TEXT
        """)
        
        conn.commit()
        conn.close()
        
        print("✅ Campo rat_review adicionado com sucesso!")
        return True
        
    except sqlite3.Error as e:
        print(f"❌ Erro ao migrar banco de dados: {e}")
        return False

if __name__ == '__main__':
    migrate_ratings()
