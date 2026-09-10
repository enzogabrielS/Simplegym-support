CREATE TABLE IF NOT EXISTS usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- O cookie guarda o token original; somente seu hash fica no banco.
CREATE TABLE IF NOT EXISTS sessoes_persistentes (
    seletor CHAR(24) PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL,
    expira_em DATETIME NOT NULL,
    INDEX (usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tentativas_login (
    chave CHAR(64) PRIMARY KEY,
    tentativas INT UNSIGNED NOT NULL DEFAULT 0,
    inicio DATETIME NOT NULL
) ENGINE=InnoDB;
