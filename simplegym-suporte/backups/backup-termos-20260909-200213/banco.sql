-- MySQL dump 10.13  Distrib 8.4.11, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: simplegym
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `simplegym`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `simplegym` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `simplegym`;

--
-- Table structure for table `agenda_semanal`
--

DROP TABLE IF EXISTS `agenda_semanal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agenda_semanal` (
  `usuario_id` int unsigned NOT NULL,
  `dia` enum('domingo','segunda','terca','quarta','quinta','sexta','sabado') COLLATE utf8mb4_unicode_ci NOT NULL,
  `treino_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`usuario_id`,`dia`,`treino_id`),
  KEY `treino_id` (`treino_id`),
  CONSTRAINT `agenda_semanal_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `agenda_semanal_ibfk_2` FOREIGN KEY (`treino_id`) REFERENCES `treinos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agenda_semanal`
--

LOCK TABLES `agenda_semanal` WRITE;
/*!40000 ALTER TABLE `agenda_semanal` DISABLE KEYS */;
INSERT INTO `agenda_semanal` VALUES (12,'quarta',1,0),(13,'quarta',2,0);
/*!40000 ALTER TABLE `agenda_semanal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `atividades_diarias`
--

DROP TABLE IF EXISTS `atividades_diarias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atividades_diarias` (
  `usuario_id` int unsigned NOT NULL,
  `dia` date NOT NULL,
  `tipo` enum('treino','checkin') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`usuario_id`,`dia`,`tipo`),
  CONSTRAINT `atividades_diarias_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atividades_diarias`
--

LOCK TABLES `atividades_diarias` WRITE;
/*!40000 ALTER TABLE `atividades_diarias` DISABLE KEYS */;
INSERT INTO `atividades_diarias` VALUES (11,'2026-09-09','checkin'),(12,'2026-09-09','treino'),(13,'2026-09-09','treino');
/*!40000 ALTER TABLE `atividades_diarias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracoes_exercicio`
--

DROP TABLE IF EXISTS `configuracoes_exercicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracoes_exercicio`
--

LOCK TABLES `configuracoes_exercicio` WRITE;
/*!40000 ALTER TABLE `configuracoes_exercicio` DISABLE KEYS */;
/*!40000 ALTER TABLE `configuracoes_exercicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercicio_grupos`
--

DROP TABLE IF EXISTS `exercicio_grupos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercicio_grupos` (
  `exercicio_id` bigint unsigned NOT NULL,
  `grupo_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`exercicio_id`,`grupo_id`),
  KEY `grupo_id` (`grupo_id`),
  CONSTRAINT `exercicio_grupos_ibfk_1` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exercicio_grupos_ibfk_2` FOREIGN KEY (`grupo_id`) REFERENCES `grupos_musculares` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercicio_grupos`
--

LOCK TABLES `exercicio_grupos` WRITE;
/*!40000 ALTER TABLE `exercicio_grupos` DISABLE KEYS */;
INSERT INTO `exercicio_grupos` VALUES (1,'biceps',1),(1,'costas',0),(2,'ombros',2),(2,'peito',0),(2,'triceps',1),(3,'biceps',1),(3,'costas',0),(4,'ombros',0),(4,'triceps',1),(5,'gluteos',2),(5,'pernas',0),(5,'posteriores',1),(6,'gluteos',1),(6,'pernas',0),(7,'antebracos',1),(7,'biceps',0),(8,'core',0),(9,'cardio',0),(9,'pernas',1),(10,'cardio',0),(10,'pernas',1),(11,'cardio',0),(11,'pernas',1);
/*!40000 ALTER TABLE `exercicio_grupos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercicio_musculos`
--

DROP TABLE IF EXISTS `exercicio_musculos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercicio_musculos` (
  `exercicio_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `nome` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`exercicio_id`,`ordem`),
  CONSTRAINT `exercicio_musculos_ibfk_1` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercicio_musculos`
--

LOCK TABLES `exercicio_musculos` WRITE;
/*!40000 ALTER TABLE `exercicio_musculos` DISABLE KEYS */;
INSERT INTO `exercicio_musculos` VALUES (1,0,'Dorsal'),(1,1,'Bíceps'),(2,0,'Peitoral'),(2,1,'Tríceps'),(2,2,'Ombros'),(3,0,'Dorsal'),(3,1,'Rombóides'),(3,2,'Bíceps'),(4,0,'Ombros'),(4,1,'Tríceps'),(5,0,'Quadríceps'),(5,1,'Glúteos'),(5,2,'Posterior'),(6,0,'Quadríceps'),(6,1,'Glúteos'),(7,0,'Bíceps'),(7,1,'Antebraços'),(8,0,'Core'),(8,1,'Abdômen'),(8,2,'Lombar'),(9,0,'Sistema cardiovascular'),(9,1,'Pernas'),(10,0,'Sistema cardiovascular'),(10,1,'Quadríceps'),(11,0,'Sistema cardiovascular'),(11,1,'Panturrilhas');
/*!40000 ALTER TABLE `exercicio_musculos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercicios`
--

DROP TABLE IF EXISTS `exercicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercicios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned DEFAULT NULL,
  `codigo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `execucao` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('forca','cardio') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'forca',
  `ordem` int unsigned NOT NULL DEFAULT '0',
  `dono` int unsigned GENERATED ALWAYS AS (ifnull(`usuario_id`,0)) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exercicio_por_dono` (`dono`,`codigo`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `exercicios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercicios`
--

LOCK TABLES `exercicios` WRITE;
/*!40000 ALTER TABLE `exercicios` DISABLE KEYS */;
INSERT INTO `exercicios` (`id`, `usuario_id`, `codigo`, `nome`, `foto`, `descricao`, `execucao`, `tipo`, `ordem`) VALUES (1,NULL,'puxada-alta','Puxada alta','https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=900&q=80','Puxe a barra em direção à parte superior do peito, mantendo o tronco firme e os cotovelos apontados para baixo.','Sente-se com os pés apoiados, segure a barra com as mãos um pouco além da largura dos ombros e solte de forma controlada.','forca',0),(2,NULL,'supino-reto','Supino reto','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a carga para cima partindo da linha do peito, sem perder o apoio das escápulas no banco.','Mantenha os pés firmes no chão, desça a barra de forma controlada e expire ao empurrar.','forca',1),(3,NULL,'remada-baixa','Remada baixa','https://images.unsplash.com/photo-1581009137042-c552e485697a?auto=format&fit=crop&w=900&q=80','Puxe o triângulo em direção ao abdômen e aproxime as escápulas no fim do movimento.','Evite balançar o tronco. Faça o retorno lentamente até os braços quase estenderem.','forca',2),(4,NULL,'desenvolvimento','Desenvolvimento com halteres','https://images.unsplash.com/photo-1517963879433-6ad2b056d712?auto=format&fit=crop&w=900&q=80','Eleve os halteres acima da cabeça respeitando a linha natural dos ombros.','Mantenha o abdômen contraído, não force a lombar e controle a descida até a altura das orelhas.','forca',3),(5,NULL,'agachamento','Agachamento livre','https://images.unsplash.com/photo-1538805060514-97d9cc17730c?auto=format&fit=crop&w=900&q=80','Desça o quadril para trás e para baixo mantendo os joelhos acompanhando a direção dos pés.','Mantenha o peito aberto, calcanhares apoiados e suba empurrando o chão.','forca',4),(6,NULL,'leg-press','Leg press 45°','https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=900&q=80','Empurre a plataforma sem bloquear completamente os joelhos no topo.','Apoie toda a lombar no encosto e desça até onde conseguir manter a postura.','forca',5),(7,NULL,'rosca-direta','Rosca direta','https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=900&q=80','Flexione os cotovelos levando a barra em direção ao peito sem projetar os ombros para frente.','Mantenha os cotovelos próximos ao corpo e evite usar o balanço para subir a carga.','forca',6),(8,NULL,'prancha','Prancha abdominal','https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?auto=format&fit=crop&w=900&q=80','Sustente o corpo alinhado, apoiando antebraços e pontas dos pés no chão.','Contraia o abdômen e os glúteos. Evite elevar ou deixar cair o quadril.','forca',7),(9,NULL,'esteira','Caminhada ou corrida na esteira','https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=900&q=80','Caminhe ou corra em ritmo progressivo para trabalhar o condicionamento cardiovascular.','Comece leve, mantenha a postura ereta e aumente o ritmo gradualmente.','cardio',8),(10,NULL,'bicicleta','Bicicleta ergométrica','https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=900&q=80','Pedale em intensidade controlada para desenvolver resistência cardiovascular.','Ajuste o banco, mantenha os joelhos alinhados e escolha uma resistência confortável.','cardio',9),(11,NULL,'corda','Pular corda','https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80','Salte de forma leve e contínua para elevar a frequência cardíaca.','Use giros curtos com os punhos, mantenha o abdômen firme e pouse suavemente.','cardio',10);
/*!40000 ALTER TABLE `exercicios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupos_musculares`
--

DROP TABLE IF EXISTS `grupos_musculares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupos_musculares` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupos_musculares`
--

LOCK TABLES `grupos_musculares` WRITE;
/*!40000 ALTER TABLE `grupos_musculares` DISABLE KEYS */;
INSERT INTO `grupos_musculares` VALUES ('antebracos','Antebraços','Músculos de pegada e antebraço',9),('biceps','Bíceps','Parte frontal do braço',2),('cardio','Cardio e condicionamento','Sistema cardiovascular e resistência',10),('core','Core e abdômen','Abdômen, lombar e estabilizadores',8),('costas','Costas','Dorsal, rombóides e região média das costas',1),('gluteos','Glúteos','Região glútea',7),('ombros','Ombros','Deltoides',4),('peito','Peito','Músculos peitorais',0),('pernas','Pernas','Principalmente quadríceps',5),('posteriores','Posteriores de perna','Posterior da coxa',6),('triceps','Tríceps','Parte posterior do braço',3);
/*!40000 ALTER TABLE `grupos_musculares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `niveis`
--

DROP TABLE IF EXISTS `niveis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `niveis` (
  `nivel` int unsigned NOT NULL,
  `xp_minimo` int unsigned NOT NULL,
  `titulo` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`nivel`),
  UNIQUE KEY `xp_minimo` (`xp_minimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `niveis`
--

LOCK TABLES `niveis` WRITE;
/*!40000 ALTER TABLE `niveis` DISABLE KEYS */;
INSERT INTO `niveis` VALUES (1,0,'Primeiro passo','Comece no seu ritmo e transforme cada treino em hábito.'),(2,120,'Em movimento','Você já iniciou uma rotina. Continue registrando seus treinos.'),(3,300,'Ritmo constante','A constância está aparecendo nos seus resultados.'),(4,550,'Foco total','Seu comprometimento está cada vez mais forte.'),(5,900,'Evolução visível','Você conquistou uma base sólida para novos desafios.'),(6,1400,'Alta consistência','Treinar já faz parte da sua semana.'),(7,2100,'Referência de rotina','Você atingiu o nível máximo atual do SimpleGym.');
/*!40000 ALTER TABLE `niveis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfis_usuario`
--

DROP TABLE IF EXISTS `perfis_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfis_usuario` (
  `usuario_id` int unsigned NOT NULL,
  `versao` int unsigned NOT NULL DEFAULT '0',
  `xp` int unsigned NOT NULL DEFAULT '0',
  `dias_seguidos` int unsigned NOT NULL DEFAULT '0',
  `treinos_concluidos` int unsigned NOT NULL DEFAULT '0',
  `minutos_atividade` double NOT NULL DEFAULT '0',
  `tema` enum('dark','light','violet') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'dark',
  `atualizado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `perfis_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfis_usuario`
--

LOCK TABLES `perfis_usuario` WRITE;
/*!40000 ALTER TABLE `perfis_usuario` DISABLE KEYS */;
INSERT INTO `perfis_usuario` VALUES (11,4,0,0,0,0,'dark','2026-09-09 22:40:34'),(12,17,60,1,2,0.32418333333333,'dark','2026-09-09 22:49:29'),(13,73,60,1,7,0.32246666666667,'dark','2026-09-09 22:50:55');
/*!40000 ALTER TABLE `perfis_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessao_exercicios`
--

DROP TABLE IF EXISTS `sessao_exercicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessao_exercicios` (
  `usuario_id` int unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `exercicio_id` bigint unsigned NOT NULL,
  `codigo_treino` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nome_treino` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `series` int unsigned NOT NULL,
  `repeticoes` int unsigned NOT NULL,
  `carga` double NOT NULL,
  PRIMARY KEY (`usuario_id`,`ordem`),
  KEY `exercicio_id` (`exercicio_id`),
  CONSTRAINT `sessao_exercicios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `treino_sessoes` (`usuario_id`) ON DELETE CASCADE,
  CONSTRAINT `sessao_exercicios_ibfk_2` FOREIGN KEY (`exercicio_id`) REFERENCES `exercicios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessao_exercicios`
--

LOCK TABLES `sessao_exercicios` WRITE;
/*!40000 ALTER TABLE `sessao_exercicios` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessao_exercicios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessao_treinos`
--

DROP TABLE IF EXISTS `sessao_treinos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessao_treinos` (
  `usuario_id` int unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `codigo_treino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`usuario_id`,`ordem`),
  CONSTRAINT `sessao_treinos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `treino_sessoes` (`usuario_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessao_treinos`
--

LOCK TABLES `sessao_treinos` WRITE;
/*!40000 ALTER TABLE `sessao_treinos` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessao_treinos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessoes_persistentes`
--

DROP TABLE IF EXISTS `sessoes_persistentes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessoes_persistentes` (
  `seletor` char(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int unsigned NOT NULL,
  `token_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expira_em` datetime NOT NULL,
  PRIMARY KEY (`seletor`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `sessoes_persistentes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessoes_persistentes`
--

LOCK TABLES `sessoes_persistentes` WRITE;
/*!40000 ALTER TABLE `sessoes_persistentes` DISABLE KEYS */;
INSERT INTO `sessoes_persistentes` VALUES ('303386fd37a65714fd9643e8',13,'08ef90c2fe61b0ae0ddd28212b7727b53bc7032df650c94e697ed4a0c077208c','2026-10-09 22:50:04');
/*!40000 ALTER TABLE `sessoes_persistentes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tentativas_login`
--

DROP TABLE IF EXISTS `tentativas_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tentativas_login` (
  `chave` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tentativas` int unsigned NOT NULL DEFAULT '0',
  `inicio` datetime NOT NULL,
  PRIMARY KEY (`chave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tentativas_login`
--

LOCK TABLES `tentativas_login` WRITE;
/*!40000 ALTER TABLE `tentativas_login` DISABLE KEYS */;
INSERT INTO `tentativas_login` VALUES ('4f1d47759e31c2594472ce3e8ea46f7a7e1079c8aa3bdd7b1adb1ae25449dfd7',1,'2026-09-09 22:48:12'),('6fb2e068ca9365a006668bfb49cbb9b7565cace43e690017058120d63e884b91',1,'2026-09-09 20:31:01'),('fac8ab61077d4ce69913d7e34be4f0990b4c76ecbc45ff6fa27dcd22b0f3f74d',1,'2026-09-09 22:50:03');
/*!40000 ALTER TABLE `tentativas_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treino_exercicios`
--

DROP TABLE IF EXISTS `treino_exercicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treino_exercicios`
--

LOCK TABLES `treino_exercicios` WRITE;
/*!40000 ALTER TABLE `treino_exercicios` DISABLE KEYS */;
INSERT INTO `treino_exercicios` VALUES (1,0,2,3,12,0),(1,1,1,3,12,0),(2,0,2,3,12,0),(2,1,3,3,12,0),(2,2,1,3,12,0);
/*!40000 ALTER TABLE `treino_exercicios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treino_grupos`
--

DROP TABLE IF EXISTS `treino_grupos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `treino_grupos` (
  `treino_id` bigint unsigned NOT NULL,
  `ordem` int unsigned NOT NULL,
  `nome` varchar(260) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`treino_id`,`ordem`),
  CONSTRAINT `treino_grupos_ibfk_1` FOREIGN KEY (`treino_id`) REFERENCES `treinos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treino_grupos`
--

LOCK TABLES `treino_grupos` WRITE;
/*!40000 ALTER TABLE `treino_grupos` DISABLE KEYS */;
INSERT INTO `treino_grupos` VALUES (1,0,'Peito e costas e biceps'),(2,0,'ada');
/*!40000 ALTER TABLE `treino_grupos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treino_sessoes`
--

DROP TABLE IF EXISTS `treino_sessoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treino_sessoes`
--

LOCK TABLES `treino_sessoes` WRITE;
/*!40000 ALTER TABLE `treino_sessoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `treino_sessoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treinos`
--

DROP TABLE IF EXISTS `treinos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `treinos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `codigo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `treino_por_usuario` (`usuario_id`,`codigo`),
  CONSTRAINT `treinos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treinos`
--

LOCK TABLES `treinos` WRITE;
/*!40000 ALTER TABLE `treinos` DISABLE KEYS */;
INSERT INTO `treinos` VALUES (1,12,'treino-1788994122950','Treino 12',0),(2,13,'treino-1788994216033','ada',0);
/*!40000 ALTER TABLE `treinos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (11,'Enzo','penisdecachorro@gmail.com','$2y$12$D21TeeRx5BfvOt1fPx7EiOHNqUAJBsUgXp95oXrPtb1j0EZ4SeRCy','2026-09-09 20:30:46'),(12,'Adm','adm@gmail.ccom','$2y$12$qOWs/RBFOpeF2P1RkbY9juK8dnl3Fy7X5qUJeqA0lDZ3T9hyLhkIC','2026-09-09 22:48:13'),(13,'enzos','enzos@gm.com','$2y$12$Tt0.kVi7RvfITBjd0d4j6e3jQSI0gxlBQFcV1OvmYu9VjXd8qOtJy','2026-09-09 22:50:04');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-09 20:02:13
