-- Restaurar em banco vazio selecionado. Contém dados privados: guarde com segurança.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
CREATE TABLE `aceites_termos` (
  `usuario_id` int unsigned NOT NULL,
  `versao` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `texto` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `texto_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `aceito_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`,`versao`),
  CONSTRAINT `aceites_termos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `agenda_semanal` (
  `usuario_id` int unsigned NOT NULL,
  `dia` enum('domingo','segunda','terca','quarta','quinta','sexta','sabado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `treino_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`usuario_id`,`dia`,`treino_id`),
  KEY `treino_id` (`treino_id`),
  CONSTRAINT `agenda_semanal_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `agenda_semanal_ibfk_2` FOREIGN KEY (`treino_id`) REFERENCES `treinos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `agenda_semanal` (`usuario_id`,`dia`,`treino_id`,`ordem`) VALUES ('12','quarta','1','0');
INSERT INTO `agenda_semanal` (`usuario_id`,`dia`,`treino_id`,`ordem`) VALUES ('13','quarta','2','0');
CREATE TABLE `atividades_diarias` (
  `usuario_id` int unsigned NOT NULL,
  `dia` date NOT NULL,
  `tipo` enum('treino','checkin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`usuario_id`,`dia`,`tipo`),
  CONSTRAINT `atividades_diarias_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `atividades_diarias` (`usuario_id`,`dia`,`tipo`) VALUES ('11','2026-09-09','checkin');
INSERT INTO `atividades_diarias` (`usuario_id`,`dia`,`tipo`) VALUES ('12','2026-09-09','treino');
INSERT INTO `atividades_diarias` (`usuario_id`,`dia`,`tipo`) VALUES ('13','2026-09-09','treino');
CREATE TABLE `configuracoes_exercicio` (
  `usuario_id` int unsigned NOT NULL,
  `exercicio_id` bigint unsigned NOT NULL,
  `series` int unsigned NOT NULL,
  `repeticoes` int unsigned NOT NULL,
  `carga` double NOT NULL,
  PRIMARY KEY (`usuario_id`,`exercicio_id`),
  KEY `exercicio_id` (`exercicio_id`),
  CONSTRAINT `configuracoes_exercicio_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `configuracoes_exercicio_ibfk_2` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `exercicio_grupos` (
  `exercicio_id` bigint unsigned NOT NULL,
  `grupo_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`exercicio_id`,`grupo_id`),
  KEY `grupo_id` (`grupo_id`),
  CONSTRAINT `exercicio_grupos_ibfk_1` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exercicio_grupos_ibfk_2` FOREIGN KEY (`grupo_id`) REFERENCES `grupos_musculares` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('1','biceps','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('1','costas','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('2','ombros','2');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('2','peito','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('2','triceps','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('3','biceps','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('3','costas','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('4','ombros','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('4','triceps','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('5','gluteos','2');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('5','pernas','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('5','posteriores','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('6','gluteos','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('6','pernas','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('7','antebracos','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('7','biceps','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('8','core','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('9','cardio','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('9','pernas','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('10','cardio','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('10','pernas','1');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('11','cardio','0');
INSERT INTO `exercicio_grupos` (`exercicio_id`,`grupo_id`,`ordem`) VALUES ('11','pernas','1');
CREATE TABLE `exercicio_musculos` (
  `exercicio_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `nome` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`exercicio_id`,`ordem`),
  CONSTRAINT `exercicio_musculos_ibfk_1` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('1','0','Dorsal');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('1','1','Bíceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('2','0','Peitoral');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('2','1','Tríceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('2','2','Ombros');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('3','0','Dorsal');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('3','1','Rombóides');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('3','2','Bíceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('4','0','Ombros');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('4','1','Tríceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('5','0','Quadríceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('5','1','Glúteos');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('5','2','Posterior');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('6','0','Quadríceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('6','1','Glúteos');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('7','0','Bíceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('7','1','Antebraços');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('8','0','Core');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('8','1','Abdômen');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('8','2','Lombar');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('9','0','Sistema cardiovascular');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('9','1','Pernas');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('10','0','Sistema cardiovascular');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('10','1','Quadríceps');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('11','0','Sistema cardiovascular');
INSERT INTO `exercicio_musculos` (`exercicio_id`,`ordem`,`nome`) VALUES ('11','1','Panturrilhas');
CREATE TABLE `exercicios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned DEFAULT NULL,
  `codigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `execucao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('forca','cardio') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'forca',
  `ordem` int unsigned NOT NULL DEFAULT '0',
  `dono` int unsigned GENERATED ALWAYS AS (ifnull(`usuario_id`,0)) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exercicio_por_dono` (`dono`,`codigo`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `exercicios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('1',NULL,'puxada-alta','Puxada alta','https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=900&q=80','Puxe a barra em direção à parte superior do peito, mantendo o tronco firme e os cotovelos apontados para baixo.','Sente-se com os pés apoiados, segure a barra com as mãos um pouco além da largura dos ombros e solte de forma controlada.','forca','0');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('2',NULL,'supino-reto','Supino reto','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a carga para cima partindo da linha do peito, sem perder o apoio das escápulas no banco.','Mantenha os pés firmes no chão, desça a barra de forma controlada e expire ao empurrar.','forca','1');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('3',NULL,'remada-baixa','Remada baixa','https://images.unsplash.com/photo-1581009137042-c552e485697a?auto=format&fit=crop&w=900&q=80','Puxe o triângulo em direção ao abdômen e aproxime as escápulas no fim do movimento.','Evite balançar o tronco. Faça o retorno lentamente até os braços quase estenderem.','forca','2');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('4',NULL,'desenvolvimento','Desenvolvimento com halteres','https://images.unsplash.com/photo-1517963879433-6ad2b056d712?auto=format&fit=crop&w=900&q=80','Eleve os halteres acima da cabeça respeitando a linha natural dos ombros.','Mantenha o abdômen contraído, não force a lombar e controle a descida até a altura das orelhas.','forca','3');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('5',NULL,'agachamento','Agachamento livre','https://images.unsplash.com/photo-1538805060514-97d9cc17730c?auto=format&fit=crop&w=900&q=80','Desça o quadril para trás e para baixo mantendo os joelhos acompanhando a direção dos pés.','Mantenha o peito aberto, calcanhares apoiados e suba empurrando o chão.','forca','4');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('6',NULL,'leg-press','Leg press 45°','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a plataforma sem bloquear completamente os joelhos no topo.','Apoie toda a lombar no encosto e desça até onde conseguir manter a postura.','forca','5');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('7',NULL,'rosca-direta','Rosca direta','https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=900&q=80','Flexione os cotovelos levando a barra em direção ao peito sem projetar os ombros para frente.','Mantenha os cotovelos próximos ao corpo e evite usar o balanço para subir a carga.','forca','6');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('8',NULL,'prancha','Prancha abdominal','https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?auto=format&fit=crop&w=900&q=80','Sustente o corpo alinhado, apoiando antebraços e pontas dos pés no chão.','Contraia o abdômen e os glúteos. Evite elevar ou deixar cair o quadril.','forca','7');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('9',NULL,'esteira','Caminhada ou corrida na esteira','https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=900&q=80','Caminhe ou corra em ritmo progressivo para trabalhar o condicionamento cardiovascular.','Comece leve, mantenha a postura ereta e aumente o ritmo gradualmente.','cardio','8');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('10',NULL,'bicicleta','Bicicleta ergométrica','https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=900&q=80','Pedale em intensidade controlada para desenvolver resistência cardiovascular.','Ajuste o banco, mantenha os joelhos alinhados e escolha uma resistência confortável.','cardio','9');
INSERT INTO `exercicios` (`id`,`usuario_id`,`codigo`,`nome`,`foto`,`descricao`,`execucao`,`tipo`,`ordem`) VALUES ('11',NULL,'corda','Pular corda','https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80','Salte de forma leve e contínua para elevar a frequência cardíaca.','Use giros curtos com os punhos, mantenha o abdômen firme e pouse suavemente.','cardio','10');
CREATE TABLE `grupos_musculares` (
  `id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('antebracos','Antebraços','Músculos de pegada e antebraço','9');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('biceps','Bíceps','Parte frontal do braço','2');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('cardio','Cardio e condicionamento','Sistema cardiovascular e resistência','10');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('core','Core e abdômen','Abdômen, lombar e estabilizadores','8');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('costas','Costas','Dorsal, rombóides e região média das costas','1');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('gluteos','Glúteos','Região glútea','7');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('ombros','Ombros','Deltoides','4');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('peito','Peito','Músculos peitorais','0');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('pernas','Pernas','Principalmente quadríceps','5');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('posteriores','Posteriores de perna','Posterior da coxa','6');
INSERT INTO `grupos_musculares` (`id`,`nome`,`descricao`,`ordem`) VALUES ('triceps','Tríceps','Parte posterior do braço','3');
CREATE TABLE `niveis` (
  `nivel` int unsigned NOT NULL,
  `xp_minimo` int unsigned NOT NULL,
  `titulo` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`nivel`),
  UNIQUE KEY `xp_minimo` (`xp_minimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('1','0','Primeiro passo','Comece no seu ritmo e transforme cada treino em hábito.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('2','120','Em movimento','Você já iniciou uma rotina. Continue registrando seus treinos.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('3','300','Ritmo constante','A constância está aparecendo nos seus resultados.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('4','550','Foco total','Seu comprometimento está cada vez mais forte.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('5','900','Evolução visível','Você conquistou uma base sólida para novos desafios.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('6','1400','Alta consistência','Treinar já faz parte da sua semana.');
INSERT INTO `niveis` (`nivel`,`xp_minimo`,`titulo`,`descricao`) VALUES ('7','2100','Referência de rotina','Você atingiu o nível máximo atual do SimpleGym.');
CREATE TABLE `perfis_usuario` (
  `usuario_id` int unsigned NOT NULL,
  `versao` int unsigned NOT NULL DEFAULT '0',
  `xp` int unsigned NOT NULL DEFAULT '0',
  `dias_seguidos` int unsigned NOT NULL DEFAULT '0',
  `treinos_concluidos` int unsigned NOT NULL DEFAULT '0',
  `minutos_atividade` double NOT NULL DEFAULT '0',
  `tema` enum('dark','light','violet') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'dark',
  `atualizado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `perfis_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `perfis_usuario` (`usuario_id`,`versao`,`xp`,`dias_seguidos`,`treinos_concluidos`,`minutos_atividade`,`tema`,`atualizado_em`) VALUES ('11','4','0','0','0','0','dark','2026-09-09 19:40:34');
INSERT INTO `perfis_usuario` (`usuario_id`,`versao`,`xp`,`dias_seguidos`,`treinos_concluidos`,`minutos_atividade`,`tema`,`atualizado_em`) VALUES ('12','18','60','1','1','0.32418333333333','dark','2026-09-09 20:02:13');
INSERT INTO `perfis_usuario` (`usuario_id`,`versao`,`xp`,`dias_seguidos`,`treinos_concluidos`,`minutos_atividade`,`tema`,`atualizado_em`) VALUES ('13','74','60','1','1','0.32246666666667','dark','2026-09-09 20:02:13');
CREATE TABLE `sessao_exercicios` (
  `usuario_id` int unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `exercicio_id` bigint unsigned NOT NULL,
  `codigo_treino` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nome_treino` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `series` int unsigned NOT NULL,
  `repeticoes` int unsigned NOT NULL,
  `carga` double NOT NULL,
  PRIMARY KEY (`usuario_id`,`ordem`),
  KEY `exercicio_id` (`exercicio_id`),
  CONSTRAINT `sessao_exercicios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `treino_sessoes` (`usuario_id`) ON DELETE CASCADE,
  CONSTRAINT `sessao_exercicios_ibfk_2` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `sessao_treinos` (
  `usuario_id` int unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `codigo_treino` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`usuario_id`,`ordem`),
  CONSTRAINT `sessao_treinos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `treino_sessoes` (`usuario_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `sessoes_persistentes` (
  `seletor` char(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int unsigned NOT NULL,
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expira_em` datetime NOT NULL,
  PRIMARY KEY (`seletor`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `sessoes_persistentes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `sessoes_persistentes` (`seletor`,`usuario_id`,`token_hash`,`expira_em`) VALUES ('02cfabbf0ef8fd29a0db207f','11','f0bc3f41c5615b447e623bc1220aba6c417bd9a57a45d41d95370b068c2c2aa3','2026-10-26 23:52:58');
INSERT INTO `sessoes_persistentes` (`seletor`,`usuario_id`,`token_hash`,`expira_em`) VALUES ('303386fd37a65714fd9643e8','13','08ef90c2fe61b0ae0ddd28212b7727b53bc7032df650c94e697ed4a0c077208c','2026-10-09 22:50:04');
CREATE TABLE `tentativas_login` (
  `chave` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tentativas` int unsigned NOT NULL DEFAULT '0',
  `inicio` datetime NOT NULL,
  PRIMARY KEY (`chave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('4f1d47759e31c2594472ce3e8ea46f7a7e1079c8aa3bdd7b1adb1ae25449dfd7','1','2026-09-09 22:48:12');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('59891c16d3deb4b0fa7c45c45da6a1ac9d5108408b7dd07d165fc8652e7f87ea','2','2026-09-26 23:51:20');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('6fb2e068ca9365a006668bfb49cbb9b7565cace43e690017058120d63e884b91','1','2026-09-09 20:31:01');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('87321fb51bb946d73cbd96c345bf8f3c70230af8842dff3ca249bcb4746bcc1e','2','2026-09-26 23:48:55');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('93810e462b8e7cdba0ea3371c29eabe3c14dc98f53f9f1b6e97db32d4a627b58','1','2026-09-27 00:00:17');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('ade980f2f7f69e547c740f391cbbe4173b66701d4b468f1811b191d03d41ea55','1','2026-09-26 23:49:36');
INSERT INTO `tentativas_login` (`chave`,`tentativas`,`inicio`) VALUES ('fac8ab61077d4ce69913d7e34be4f0990b4c76ecbc45ff6fa27dcd22b0f3f74d','1','2026-09-09 22:50:03');
CREATE TABLE `treino_exercicios` (
  `treino_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `exercicio_id` bigint unsigned NOT NULL,
  `series` int unsigned NOT NULL,
  `repeticoes` int unsigned NOT NULL,
  `carga` double NOT NULL,
  PRIMARY KEY (`treino_id`,`ordem`),
  KEY `exercicio_id` (`exercicio_id`),
  CONSTRAINT `treino_exercicios_ibfk_1` FOREIGN KEY (`treino_id`) REFERENCES `treinos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `treino_exercicios_ibfk_2` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `treino_exercicios` (`treino_id`,`ordem`,`exercicio_id`,`series`,`repeticoes`,`carga`) VALUES ('1','0','2','3','12','0');
INSERT INTO `treino_exercicios` (`treino_id`,`ordem`,`exercicio_id`,`series`,`repeticoes`,`carga`) VALUES ('1','1','1','3','12','0');
INSERT INTO `treino_exercicios` (`treino_id`,`ordem`,`exercicio_id`,`series`,`repeticoes`,`carga`) VALUES ('2','0','2','3','12','0');
INSERT INTO `treino_exercicios` (`treino_id`,`ordem`,`exercicio_id`,`series`,`repeticoes`,`carga`) VALUES ('2','1','3','3','12','0');
INSERT INTO `treino_exercicios` (`treino_id`,`ordem`,`exercicio_id`,`series`,`repeticoes`,`carga`) VALUES ('2','2','1','3','12','0');
CREATE TABLE `treino_grupos` (
  `treino_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `nome` varchar(260) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`treino_id`,`ordem`),
  CONSTRAINT `treino_grupos_ibfk_1` FOREIGN KEY (`treino_id`) REFERENCES `treinos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `treino_grupos` (`treino_id`,`ordem`,`nome`) VALUES ('1','0','Peito e costas e biceps');
INSERT INTO `treino_grupos` (`treino_id`,`ordem`,`nome`) VALUES ('2','0','ada');
CREATE TABLE `treino_sessoes` (
  `usuario_id` int unsigned NOT NULL,
  `indice_exercicio` int unsigned NOT NULL,
  `series_concluidas` int unsigned NOT NULL,
  `pausado` tinyint(1) NOT NULL,
  `iniciado_em_ms` bigint unsigned NOT NULL,
  `atividade_ms` double NOT NULL,
  `concede_xp` tinyint(1) NOT NULL,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `treino_sessoes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `treinos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `codigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `treino_por_usuario` (`usuario_id`,`codigo`),
  CONSTRAINT `treinos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `treinos` (`id`,`usuario_id`,`codigo`,`nome`,`ordem`) VALUES ('1','12','treino-1788994122950','Treino 12','0');
INSERT INTO `treinos` (`id`,`usuario_id`,`codigo`,`nome`,`ordem`) VALUES ('2','13','treino-1788994216033','ada','0');
CREATE TABLE `usuarios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('11','Enzo','penisdecachorro@gmail.com','$2y$12$D21TeeRx5BfvOt1fPx7EiOHNqUAJBsUgXp95oXrPtb1j0EZ4SeRCy','2026-09-09 17:30:46');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('12','Adm','adm@gmail.ccom','$2y$12$qOWs/RBFOpeF2P1RkbY9juK8dnl3Fy7X5qUJeqA0lDZ3T9hyLhkIC','2026-09-09 19:48:13');
INSERT INTO `usuarios` (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('13','enzos','enzos@gm.com','$2y$12$Tt0.kVi7RvfITBjd0d4j6e3jQSI0gxlBQFcV1OvmYu9VjXd8qOtJy','2026-09-09 19:50:04');
SET FOREIGN_KEY_CHECKS=1;
