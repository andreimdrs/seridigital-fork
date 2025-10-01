-- Script SQL para adicionar as colunas cnt_file_path e cnt_file_type
-- Execute este script no banco de dados para aplicar a migração

-- Adicionar coluna para o caminho do arquivo
ALTER TABLE tb_contents ADD COLUMN cnt_file_path VARCHAR(500);

-- Adicionar coluna para o tipo de arquivo (pdf ou epub)
ALTER TABLE tb_contents ADD COLUMN cnt_file_type VARCHAR(10);

-- Verificar as colunas adicionadas
SELECT sql FROM sqlite_master WHERE name='tb_contents';
