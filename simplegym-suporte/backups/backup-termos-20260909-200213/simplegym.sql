-- Importe em um banco MySQL 8.0+ vazio, selecionado no HeidiSQL.
SET NAMES utf8mb4;

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

-- Catálogo inicial: os dados passam a ser administrados no MySQL.
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('peito','Peito','Músculos peitorais',0);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('costas','Costas','Dorsal, rombóides e região média das costas',1);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('biceps','Bíceps','Parte frontal do braço',2);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('triceps','Tríceps','Parte posterior do braço',3);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('ombros','Ombros','Deltoides',4);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('pernas','Pernas','Principalmente quadríceps',5);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('posteriores','Posteriores de perna','Posterior da coxa',6);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('gluteos','Glúteos','Região glútea',7);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('core','Core e abdômen','Abdômen, lombar e estabilizadores',8);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('antebracos','Antebraços','Músculos de pegada e antebraço',9);
INSERT IGNORE INTO grupos_musculares (id,nome,descricao,ordem) VALUES ('cardio','Cardio e condicionamento','Sistema cardiovascular e resistência',10);
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (1,0,'Primeiro passo','Comece no seu ritmo e transforme cada treino em hábito.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (2,120,'Em movimento','Você já iniciou uma rotina. Continue registrando seus treinos.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (3,300,'Ritmo constante','A constância está aparecendo nos seus resultados.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (4,550,'Foco total','Seu comprometimento está cada vez mais forte.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (5,900,'Evolução visível','Você conquistou uma base sólida para novos desafios.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (6,1400,'Alta consistência','Treinar já faz parte da sua semana.');
INSERT IGNORE INTO niveis (nivel,xp_minimo,titulo,descricao) VALUES (7,2100,'Referência de rotina','Você atingiu o nível máximo atual do SimpleGym.');
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'puxada-alta','Puxada alta','https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=900&q=80','Puxe a barra em direção à parte superior do peito, mantendo o tronco firme e os cotovelos apontados para baixo.','Sente-se com os pés apoiados, segure a barra com as mãos um pouco além da largura dos ombros e solte de forma controlada.','forca',0);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'costas',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='puxada-alta';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'biceps',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='puxada-alta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Dorsal' FROM exercicios WHERE usuario_id IS NULL AND codigo='puxada-alta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Bíceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='puxada-alta';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'supino-reto','Supino reto','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a carga para cima partindo da linha do peito, sem perder o apoio das escápulas no banco.','Mantenha os pés firmes no chão, desça a barra de forma controlada e expire ao empurrar.','forca',1);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'peito',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'triceps',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'ombros',2 FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Peitoral' FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Tríceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,2,'Ombros' FROM exercicios WHERE usuario_id IS NULL AND codigo='supino-reto';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'remada-baixa','Remada baixa','https://images.unsplash.com/photo-1581009137042-c552e485697a?auto=format&fit=crop&w=900&q=80','Puxe o triângulo em direção ao abdômen e aproxime as escápulas no fim do movimento.','Evite balançar o tronco. Faça o retorno lentamente até os braços quase estenderem.','forca',2);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'costas',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='remada-baixa';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'biceps',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='remada-baixa';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Dorsal' FROM exercicios WHERE usuario_id IS NULL AND codigo='remada-baixa';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Rombóides' FROM exercicios WHERE usuario_id IS NULL AND codigo='remada-baixa';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,2,'Bíceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='remada-baixa';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'desenvolvimento','Desenvolvimento com halteres','https://images.unsplash.com/photo-1517963879433-6ad2b056d712?auto=format&fit=crop&w=900&q=80','Eleve os halteres acima da cabeça respeitando a linha natural dos ombros.','Mantenha o abdômen contraído, não force a lombar e controle a descida até a altura das orelhas.','forca',3);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'ombros',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='desenvolvimento';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'triceps',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='desenvolvimento';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Ombros' FROM exercicios WHERE usuario_id IS NULL AND codigo='desenvolvimento';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Tríceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='desenvolvimento';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'agachamento','Agachamento livre','https://images.unsplash.com/photo-1538805060514-97d9cc17730c?auto=format&fit=crop&w=900&q=80','Desça o quadril para trás e para baixo mantendo os joelhos acompanhando a direção dos pés.','Mantenha o peito aberto, calcanhares apoiados e suba empurrando o chão.','forca',4);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'pernas',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'posteriores',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'gluteos',2 FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Quadríceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Glúteos' FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,2,'Posterior' FROM exercicios WHERE usuario_id IS NULL AND codigo='agachamento';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'leg-press','Leg press 45°','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a plataforma sem bloquear completamente os joelhos no topo.','Apoie toda a lombar no encosto e desça até onde conseguir manter a postura.','forca',5);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'pernas',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='leg-press';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'gluteos',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='leg-press';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Quadríceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='leg-press';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Glúteos' FROM exercicios WHERE usuario_id IS NULL AND codigo='leg-press';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'rosca-direta','Rosca direta','https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=900&q=80','Flexione os cotovelos levando a barra em direção ao peito sem projetar os ombros para frente.','Mantenha os cotovelos próximos ao corpo e evite usar o balanço para subir a carga.','forca',6);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'biceps',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='rosca-direta';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'antebracos',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='rosca-direta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Bíceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='rosca-direta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Antebraços' FROM exercicios WHERE usuario_id IS NULL AND codigo='rosca-direta';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'prancha','Prancha abdominal','https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?auto=format&fit=crop&w=900&q=80','Sustente o corpo alinhado, apoiando antebraços e pontas dos pés no chão.','Contraia o abdômen e os glúteos. Evite elevar ou deixar cair o quadril.','forca',7);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'core',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='prancha';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Core' FROM exercicios WHERE usuario_id IS NULL AND codigo='prancha';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Abdômen' FROM exercicios WHERE usuario_id IS NULL AND codigo='prancha';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,2,'Lombar' FROM exercicios WHERE usuario_id IS NULL AND codigo='prancha';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'esteira','Caminhada ou corrida na esteira','https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=900&q=80','Caminhe ou corra em ritmo progressivo para trabalhar o condicionamento cardiovascular.','Comece leve, mantenha a postura ereta e aumente o ritmo gradualmente.','cardio',8);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'cardio',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='esteira';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'pernas',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='esteira';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Sistema cardiovascular' FROM exercicios WHERE usuario_id IS NULL AND codigo='esteira';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Pernas' FROM exercicios WHERE usuario_id IS NULL AND codigo='esteira';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'bicicleta','Bicicleta ergométrica','https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=900&q=80','Pedale em intensidade controlada para desenvolver resistência cardiovascular.','Ajuste o banco, mantenha os joelhos alinhados e escolha uma resistência confortável.','cardio',9);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'cardio',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='bicicleta';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'pernas',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='bicicleta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Sistema cardiovascular' FROM exercicios WHERE usuario_id IS NULL AND codigo='bicicleta';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Quadríceps' FROM exercicios WHERE usuario_id IS NULL AND codigo='bicicleta';
INSERT IGNORE INTO exercicios (usuario_id,codigo,nome,foto,descricao,execucao,tipo,ordem) VALUES (NULL,'corda','Pular corda','https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80','Salte de forma leve e contínua para elevar a frequência cardíaca.','Use giros curtos com os punhos, mantenha o abdômen firme e pouse suavemente.','cardio',10);
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'cardio',0 FROM exercicios WHERE usuario_id IS NULL AND codigo='corda';
INSERT IGNORE INTO exercicio_grupos (exercicio_id,grupo_id,ordem) SELECT id,'pernas',1 FROM exercicios WHERE usuario_id IS NULL AND codigo='corda';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,0,'Sistema cardiovascular' FROM exercicios WHERE usuario_id IS NULL AND codigo='corda';
INSERT IGNORE INTO exercicio_musculos (exercicio_id,ordem,nome) SELECT id,1,'Panturrilhas' FROM exercicios WHERE usuario_id IS NULL AND codigo='corda';
