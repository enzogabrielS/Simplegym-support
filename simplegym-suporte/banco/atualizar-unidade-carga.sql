-- Selecione o banco do SimpleGym no HeidiSQL antes de executar.
-- Execute uma única vez, antes de enviar o novo código PHP/JS.
-- Preserva todas as cargas existentes em kg.
ALTER TABLE perfis_usuario
    ADD COLUMN unidade_carga ENUM('kg','lb') NOT NULL DEFAULT 'kg';
