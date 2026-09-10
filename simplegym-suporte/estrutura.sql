CREATE TABLE IF NOT EXISTS perfis_usuario (
    usuario_id INT UNSIGNED PRIMARY KEY,
    versao INT UNSIGNED NOT NULL DEFAULT 0,
    xp INT UNSIGNED NOT NULL DEFAULT 0,
    dias_seguidos INT UNSIGNED NOT NULL DEFAULT 0,
    treinos_concluidos INT UNSIGNED NOT NULL DEFAULT 0,
    minutos_atividade DOUBLE NOT NULL DEFAULT 0,
    tema ENUM('dark','light','violet') NOT NULL DEFAULT 'dark',
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS grupos_musculares (
    id VARCHAR(100) PRIMARY KEY,
    nome VARCHAR(180) NOT NULL,
    descricao TEXT NOT NULL,
    ordem INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS niveis (
    nivel INT UNSIGNED PRIMARY KEY,
    xp_minimo INT UNSIGNED NOT NULL UNIQUE,
    titulo VARCHAR(180) NOT NULL,
    descricao TEXT NOT NULL
) ENGINE=InnoDB;

-- usuario_id NULL = exercício do aplicativo. Preenchido = exercício pessoal.
CREATE TABLE IF NOT EXISTS exercicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NULL,
    codigo VARCHAR(100) NOT NULL,
    nome VARCHAR(180) NOT NULL,
    foto MEDIUMTEXT NOT NULL,
    descricao TEXT NOT NULL,
    execucao TEXT NOT NULL,
    tipo ENUM('forca','cardio') NOT NULL DEFAULT 'forca',
    ordem INT UNSIGNED NOT NULL DEFAULT 0,
    dono INT UNSIGNED GENERATED ALWAYS AS (IFNULL(usuario_id, 0)) STORED,
    UNIQUE KEY exercicio_por_dono (dono, codigo),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exercicio_grupos (
    exercicio_id BIGINT UNSIGNED NOT NULL,
    grupo_id VARCHAR(100) NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    PRIMARY KEY (exercicio_id, grupo_id),
    FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES grupos_musculares(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exercicio_musculos (
    exercicio_id BIGINT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    nome VARCHAR(200) NOT NULL,
    PRIMARY KEY (exercicio_id, ordem),
    FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS treinos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    codigo VARCHAR(100) NOT NULL,
    nome VARCHAR(180) NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    UNIQUE KEY treino_por_usuario (usuario_id, codigo),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS treino_grupos (
    treino_id BIGINT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    nome VARCHAR(260) NOT NULL,
    PRIMARY KEY (treino_id, ordem),
    FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS treino_exercicios (
    treino_id BIGINT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    exercicio_id BIGINT UNSIGNED NOT NULL,
    series INT UNSIGNED NOT NULL,
    repeticoes INT UNSIGNED NOT NULL,
    carga DOUBLE NOT NULL,
    PRIMARY KEY (treino_id, ordem),
    FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE CASCADE,
    FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS configuracoes_exercicio (
    usuario_id INT UNSIGNED NOT NULL,
    exercicio_id BIGINT UNSIGNED NOT NULL,
    series INT UNSIGNED NOT NULL,
    repeticoes INT UNSIGNED NOT NULL,
    carga DOUBLE NOT NULL,
    PRIMARY KEY (usuario_id, exercicio_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS agenda_semanal (
    usuario_id INT UNSIGNED NOT NULL,
    dia ENUM('domingo','segunda','terca','quarta','quinta','sexta','sabado') NOT NULL,
    treino_id BIGINT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    PRIMARY KEY (usuario_id, dia, treino_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS atividades_diarias (
    usuario_id INT UNSIGNED NOT NULL,
    dia DATE NOT NULL,
    tipo ENUM('treino','checkin') NOT NULL,
    PRIMARY KEY (usuario_id, dia, tipo),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS treino_sessoes (
    usuario_id INT UNSIGNED PRIMARY KEY,
    indice_exercicio INT UNSIGNED NOT NULL,
    series_concluidas INT UNSIGNED NOT NULL,
    pausado BOOLEAN NOT NULL,
    iniciado_em_ms BIGINT UNSIGNED NOT NULL,
    atividade_ms DOUBLE NOT NULL,
    concede_xp BOOLEAN NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessao_treinos (
    usuario_id INT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    codigo_treino VARCHAR(100) NOT NULL,
    PRIMARY KEY (usuario_id, ordem),
    FOREIGN KEY (usuario_id) REFERENCES treino_sessoes(usuario_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessao_exercicios (
    usuario_id INT UNSIGNED NOT NULL,
    ordem INT UNSIGNED NOT NULL,
    exercicio_id BIGINT UNSIGNED NOT NULL,
    codigo_treino VARCHAR(100) NULL,
    nome_treino VARCHAR(180) NULL,
    series INT UNSIGNED NOT NULL,
    repeticoes INT UNSIGNED NOT NULL,
    carga DOUBLE NOT NULL,
    PRIMARY KEY (usuario_id, ordem),
    FOREIGN KEY (usuario_id) REFERENCES treino_sessoes(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
