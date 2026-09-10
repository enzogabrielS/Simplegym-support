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
-- Table structure for table `dados_usuario`
--

DROP TABLE IF EXISTS `dados_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dados_usuario` (
  `usuario_id` int unsigned NOT NULL,
  `dados` json NOT NULL,
  `versao` int unsigned NOT NULL DEFAULT '0',
  `atualizado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `dados_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dados_usuario`
--

LOCK TABLES `dados_usuario` WRITE;
/*!40000 ALTER TABLE `dados_usuario` DISABLE KEYS */;
INSERT INTO `dados_usuario` VALUES (11,'{\"xp\": 0, \"plans\": [], \"theme\": \"dark\", \"streak\": 0, \"session\": null, \"schedule\": {\"sexta\": [], \"terca\": [], \"quarta\": [], \"quinta\": [], \"sabado\": [], \"domingo\": [], \"segunda\": []}, \"totalWorkouts\": 0, \"completedDates\": {}, \"activityMinutes\": 0, \"customExercises\": [], \"freeDayCheckins\": {\"2026-09-09\": true}, \"exerciseDefaults\": {}}',4,'2026-09-09 20:31:55');
/*!40000 ALTER TABLE `dados_usuario` ENABLE KEYS */;
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
INSERT INTO `sessoes_persistentes` VALUES ('0320d570d18fc2b738fb0bfe',11,'48a4c7fb0cc11a3610e72c8726e2ea8b3ced84612eb3b918d0d8e46eee845ef8','2026-10-09 20:31:13');
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
INSERT INTO `tentativas_login` VALUES ('6fb2e068ca9365a006668bfb49cbb9b7565cace43e690017058120d63e884b91',1,'2026-09-09 20:31:01');
/*!40000 ALTER TABLE `tentativas_login` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (11,'Enzo','penisdecachorro@gmail.com','$2y$12$D21TeeRx5BfvOt1fPx7EiOHNqUAJBsUgXp95oXrPtb1j0EZ4SeRCy','2026-09-09 20:30:46');
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

-- Dump completed on 2026-09-09 19:40:33
