CREATE DATABASE IF NOT EXISTS simplegym CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE simplegym;

CREATE TABLE IF NOT EXISTS usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Um documento por usuário preserva a ordem dos exercícios, a agenda e os dados do app.
CREATE TABLE IF NOT EXISTS dados_usuario (
    usuario_id INT UNSIGNED PRIMARY KEY,
    dados JSON NOT NULL,
    versao INT UNSIGNED NOT NULL DEFAULT 0,
    atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
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
