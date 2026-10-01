-- Snapshot da tabela de contas antes de adicionar a foto. Contém dados privados.
SET NAMES utf8mb4;
CREATE TABLE `usuarios` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO usuarios (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('11','Enzo','penisdecachorro@gmail.com','$2y$12$D21TeeRx5BfvOt1fPx7EiOHNqUAJBsUgXp95oXrPtb1j0EZ4SeRCy','2026-09-09 17:30:46');
INSERT INTO usuarios (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('12','Adm','adm@gmail.ccom','$2y$12$qOWs/RBFOpeF2P1RkbY9juK8dnl3Fy7X5qUJeqA0lDZ3T9hyLhkIC','2026-09-09 19:48:13');
INSERT INTO usuarios (`id`,`nome`,`email`,`senha_hash`,`criado_em`) VALUES ('13','enzos','enzos@gm.com','$2y$12$Tt0.kVi7RvfITBjd0d4j6e3jQSI0gxlBQFcV1OvmYu9VjXd8qOtJy','2026-09-09 19:50:04');
