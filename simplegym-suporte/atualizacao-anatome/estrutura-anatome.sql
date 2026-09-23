-- Banco existente: executar UMA VEZ antes do catálogo e dos arquivos PHP.
ALTER TABLE perfis_usuario ADD COLUMN preferencia_treino ENUM('musculacao','calistenia','ambas') NOT NULL DEFAULT 'ambas';
ALTER TABLE exercicios
 ADD COLUMN modalidade ENUM('musculacao','calistenia','ambas') NOT NULL DEFAULT 'ambas',
 ADD COLUMN anatome_id VARCHAR(180) NULL,
 ADD COLUMN categoria_api VARCHAR(100) NULL,
 ADD COLUMN equipamento VARCHAR(100) NULL,
 ADD COLUMN nivel_api VARCHAR(80) NULL,
 ADD COLUMN diagrama_url TEXT NULL,
 ADD COLUMN video_url TEXT NULL,
 ADD COLUMN idioma_instrucoes VARCHAR(12) NULL,
 ADD COLUMN atualizado_anatome_em TIMESTAMP NULL;
CREATE TABLE IF NOT EXISTS exercicio_anatomia (
 exercicio_id BIGINT UNSIGNED NOT NULL,
 papel ENUM('primario','secundario') NOT NULL,
 ordem INT UNSIGNED NOT NULL,
 musculo VARCHAR(200) NOT NULL,
 PRIMARY KEY (exercicio_id,papel,ordem),
 FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS exercicio_instrucoes (
 exercicio_id BIGINT UNSIGNED NOT NULL,
 ordem INT UNSIGNED NOT NULL,
 instrucao TEXT NOT NULL,
 PRIMARY KEY (exercicio_id,ordem),
 FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
