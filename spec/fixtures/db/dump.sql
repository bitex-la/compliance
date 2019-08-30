-- MySQL dump 10.13  Distrib 5.7.21, for macos10.13 (x86_64)
--
-- Host: localhost    Database: compliance_development
-- ------------------------------------------------------
-- Server version 5.7.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `active_admin_comments`
--

DROP TABLE IF EXISTS `active_admin_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_admin_comments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `namespace` varchar(255) DEFAULT NULL,
  `body` text,
  `resource_type` varchar(255) DEFAULT NULL,
  `resource_id` bigint(20) DEFAULT NULL,
  `author_type` varchar(255) DEFAULT NULL,
  `author_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_active_admin_comments_on_resource_type_and_resource_id` (`resource_type`,`resource_id`),
  KEY `index_active_admin_comments_on_author_type_and_author_id` (`author_type`,`author_id`),
  KEY `index_active_admin_comments_on_namespace` (`namespace`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active_admin_comments`
--

LOCK TABLES `active_admin_comments` WRITE;
/*!40000 ALTER TABLE `active_admin_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `active_admin_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admin_users_on_email` (`email`),
  UNIQUE KEY `index_admin_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (1,'yohan@bitex.la','$2a$11$gTwrezigX5/NpnsYww0u..auhivwpGHuOZHfRE6RXdHBinjBlxZH.',NULL,NULL,NULL,3,'2018-02-14 17:08:51','2018-02-06 16:59:06','::1','::1','2018-02-06 16:57:21','2018-02-14 17:08:51');
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ar_internal_metadata`
--

LOCK TABLES `ar_internal_metadata` WRITE;
/*!40000 ALTER TABLE `ar_internal_metadata` DISABLE KEYS */;
INSERT INTO `ar_internal_metadata` VALUES ('environment','development','2018-02-02 14:56:01','2018-02-02 14:56:01');
/*!40000 ALTER TABLE `ar_internal_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) DEFAULT NULL,
  `seed_to_id` int(11) DEFAULT NULL,
  `seed_to_type` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `document_file_name` varchar(255) DEFAULT NULL,
  `document_content_type` varchar(255) DEFAULT NULL,
  `document_file_size` int(11) DEFAULT NULL,
  `document_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attachments_on_person_id` (`person_id`),
  CONSTRAINT `fk_rails_cd920b4a09` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
INSERT INTO `attachments` VALUES (10,45,49,'DomicileSeed','2018-02-14 20:20:18','2018-02-14 20:21:51','dni_frente.png','image/png',82971,'2018-02-14 20:20:18'),(11,45,49,'DomicileSeed','2018-02-14 20:47:28','2018-02-14 20:47:45','simple.pdf','application/pdf',7945,'2018-02-14 20:47:28'),(12,45,49,'DomicileSeed','2018-02-14 20:51:14','2018-02-14 20:51:25','simple.zip','application/zip',1207340,'2018-02-14 20:51:14'),(13,45,23,'IdentificationSeed','2018-02-15 13:46:45','2018-02-15 13:51:46','simple.gif','image/gif',1183188,'2018-02-15 13:46:45'),(14,45,2,'NaturalDocketSeed','2018-02-15 13:58:58','2018-02-15 14:00:02','simple.jpg','image/jpeg',27661,'2018-02-15 13:58:58'),(15,45,2,'LegalEntityDocketSeed','2018-02-15 14:02:14','2018-02-15 14:03:24','simple.pdf','application/pdf',7945,'2018-02-15 14:02:14'),(16,45,2,'QuotaSeed','2018-02-15 14:11:50','2018-02-15 14:12:41','simple.png','image/png',3118,'2018-02-15 14:11:50');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `meta` text,
  `body` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (4,106,'Issue',NULL,'this is great',NULL,'thi is a test','2018-02-15 15:01:58','2018-02-15 15:01:58'),(5,106,'Issue',NULL,'ytry',NULL,'yttryrty','2018-02-15 15:18:33','2018-02-15 15:18:33');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domicile_seeds`
--

DROP TABLE IF EXISTS `domicile_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domicile_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  `street_number` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `floor` varchar(255) DEFAULT NULL,
  `apartment` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `domicile_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_domicile_seeds_on_issue_id` (`issue_id`),
  KEY `index_domicile_seeds_on_domicile_id` (`domicile_id`),
  CONSTRAINT `fk_rails_25ef5a7533` FOREIGN KEY (`domicile_id`) REFERENCES `domiciles` (`id`),
  CONSTRAINT `fk_rails_d6d82bde8a` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domicile_seeds`
--

LOCK TABLES `domicile_seeds` WRITE;
/*!40000 ALTER TABLE `domicile_seeds` DISABLE KEYS */;
INSERT INTO `domicile_seeds` VALUES (41,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',99,'2018-02-09 17:14:55','2018-02-09 17:14:55',NULL),(42,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',100,'2018-02-09 17:24:18','2018-02-09 17:24:18',NULL),(43,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',101,'2018-02-09 17:25:16','2018-02-09 17:25:16',NULL),(44,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',102,'2018-02-09 17:28:49','2018-02-09 17:28:49',NULL),(45,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',103,'2018-02-09 17:29:22','2018-02-09 17:29:22',NULL),(46,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',104,'2018-02-09 17:32:01','2018-02-09 17:32:01',NULL),(47,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',105,'2018-02-09 17:48:04','2018-02-09 17:48:04',NULL),(48,'argentina','buenos aires','CABA','cullen','2345','1234','4','a',106,'2018-02-09 17:48:42','2018-02-09 17:48:42',NULL),(49,'AR','Buenos Aires','CABA','cullen','5228','1431','5','a',106,'2018-02-14 19:59:41','2018-02-14 19:59:41',NULL);
/*!40000 ALTER TABLE `domicile_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domiciles`
--

DROP TABLE IF EXISTS `domiciles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domiciles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  `street_number` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `floor` varchar(255) DEFAULT NULL,
  `apartment` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_domiciles_on_issue_id` (`issue_id`),
  KEY `index_domiciles_on_person_id` (`person_id`),
  KEY `index_domiciles_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_972b6a1d57` FOREIGN KEY (`replaced_by_id`) REFERENCES `domiciles` (`id`),
  CONSTRAINT `fk_rails_c76ece1bc2` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_d15e68d26a` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domiciles`
--

LOCK TABLES `domiciles` WRITE;
/*!40000 ALTER TABLE `domiciles` DISABLE KEYS */;
/*!40000 ALTER TABLE `domiciles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `funding_seeds`
--

DROP TABLE IF EXISTS `funding_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `funding_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `funding_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_funding_seeds_on_issue_id` (`issue_id`),
  KEY `index_funding_seeds_on_funding_id` (`funding_id`),
  CONSTRAINT `fk_rails_1a67614af4` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_ca944aaca0` FOREIGN KEY (`funding_id`) REFERENCES `fundings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `funding_seeds`
--

LOCK TABLES `funding_seeds` WRITE;
/*!40000 ALTER TABLE `funding_seeds` DISABLE KEYS */;
/*!40000 ALTER TABLE `funding_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fundings`
--

DROP TABLE IF EXISTS `fundings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fundings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amount` decimal(10,0) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fundings_on_issue_id` (`issue_id`),
  KEY `index_fundings_on_person_id` (`person_id`),
  KEY `index_fundings_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_584435cd00` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_fe57900dde` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_ff1a837152` FOREIGN KEY (`replaced_by_id`) REFERENCES `fundings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fundings`
--

LOCK TABLES `fundings` WRITE;
/*!40000 ALTER TABLE `fundings` DISABLE KEYS */;
/*!40000 ALTER TABLE `fundings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identification_seeds`
--

DROP TABLE IF EXISTS `identification_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identification_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `number` varchar(255) DEFAULT NULL,
  `issuer` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `identification_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_identification_seeds_on_issue_id` (`issue_id`),
  KEY `index_identification_seeds_on_identification_id` (`identification_id`),
  CONSTRAINT `fk_rails_a900fbe3a0` FOREIGN KEY (`identification_id`) REFERENCES `identifications` (`id`),
  CONSTRAINT `fk_rails_df9682e6a3` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identification_seeds`
--

LOCK TABLES `identification_seeds` WRITE;
/*!40000 ALTER TABLE `identification_seeds` DISABLE KEYS */;
INSERT INTO `identification_seeds` VALUES (23,106,'passport','AQ45654','argentina','2018-02-14 19:10:06','2018-02-14 19:10:06',NULL);
/*!40000 ALTER TABLE `identification_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `identifications`
--

DROP TABLE IF EXISTS `identifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `issuer` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_identifications_on_issue_id` (`issue_id`),
  KEY `index_identifications_on_person_id` (`person_id`),
  KEY `index_identifications_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_24304a0c86` FOREIGN KEY (`replaced_by_id`) REFERENCES `identifications` (`id`),
  CONSTRAINT `fk_rails_6d1209c365` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_b97e74747a` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identifications`
--

LOCK TABLES `identifications` WRITE;
/*!40000 ALTER TABLE `identifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `identifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issues`
--

DROP TABLE IF EXISTS `issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issues` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `aasm_state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_issues_on_person_id` (`person_id`),
  CONSTRAINT `fk_rails_7450f76080` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issues`
--

LOCK TABLES `issues` WRITE;
/*!40000 ALTER TABLE `issues` DISABLE KEYS */;
INSERT INTO `issues` VALUES (98,37,'2018-02-09 14:35:32','2018-02-09 14:35:32','new'),(99,38,'2018-02-09 17:14:55','2018-02-09 17:14:55','new'),(100,39,'2018-02-09 17:24:18','2018-02-09 17:24:18','new'),(101,40,'2018-02-09 17:25:16','2018-02-09 17:25:16','new'),(102,41,'2018-02-09 17:28:49','2018-02-09 17:28:49','new'),(103,42,'2018-02-09 17:29:22','2018-02-09 17:29:22','new'),(104,43,'2018-02-09 17:32:01','2018-02-09 17:32:01','new'),(105,44,'2018-02-09 17:48:04','2018-02-09 17:48:04','new'),(106,45,'2018-02-09 17:48:42','2018-02-09 17:48:42','new');
/*!40000 ALTER TABLE `issues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `legal_entity_docket_seeds`
--

DROP TABLE IF EXISTS `legal_entity_docket_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legal_entity_docket_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `business_description` text,
  `country` varchar(255) DEFAULT NULL,
  `commercial_name` varchar(255) DEFAULT NULL,
  `legal_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `legal_entity_docket_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_legal_entity_docket_seeds_on_issue_id` (`issue_id`),
  KEY `index_legal_entity_docket_seeds_on_legal_entity_docket_id` (`legal_entity_docket_id`),
  CONSTRAINT `fk_rails_57bf45f9c8` FOREIGN KEY (`legal_entity_docket_id`) REFERENCES `legal_entity_dockets` (`id`),
  CONSTRAINT `fk_rails_e723696a41` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `legal_entity_docket_seeds`
--

LOCK TABLES `legal_entity_docket_seeds` WRITE;
/*!40000 ALTER TABLE `legal_entity_docket_seeds` DISABLE KEYS */;
INSERT INTO `legal_entity_docket_seeds` VALUES (2,106,'videogames','to build AAA game experiences','CA','funny games','Fgames LLC','2018-02-14 19:36:37','2018-02-14 19:36:37',NULL);
/*!40000 ALTER TABLE `legal_entity_docket_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `legal_entity_dockets`
--

DROP TABLE IF EXISTS `legal_entity_dockets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legal_entity_dockets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `industry` varchar(255) DEFAULT NULL,
  `business_description` text,
  `country` varchar(255) DEFAULT NULL,
  `commercial_name` varchar(255) DEFAULT NULL,
  `legal_name` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_legal_entity_dockets_on_issue_id` (`issue_id`),
  KEY `index_legal_entity_dockets_on_person_id` (`person_id`),
  KEY `index_legal_entity_dockets_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_416a83f34e` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_51dce2f423` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_9cea259789` FOREIGN KEY (`replaced_by_id`) REFERENCES `legal_entity_dockets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `legal_entity_dockets`
--

LOCK TABLES `legal_entity_dockets` WRITE;
/*!40000 ALTER TABLE `legal_entity_dockets` DISABLE KEYS */;
/*!40000 ALTER TABLE `legal_entity_dockets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_docket_seeds`
--

DROP TABLE IF EXISTS `natural_docket_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_docket_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `nationality` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `marital_status` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `natural_docket_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_natural_docket_seeds_on_issue_id` (`issue_id`),
  KEY `index_natural_docket_seeds_on_natural_docket_id` (`natural_docket_id`),
  CONSTRAINT `fk_rails_21bc7645f6` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_a644f8fca8` FOREIGN KEY (`natural_docket_id`) REFERENCES `natural_dockets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_docket_seeds`
--

LOCK TABLES `natural_docket_seeds` WRITE;
/*!40000 ALTER TABLE `natural_docket_seeds` DISABLE KEYS */;
INSERT INTO `natural_docket_seeds` VALUES (2,106,'joe','doe','2013-01-04','Argelia','Male','Single','2018-02-14 19:22:13','2018-02-14 19:22:13',NULL);
/*!40000 ALTER TABLE `natural_docket_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_dockets`
--

DROP TABLE IF EXISTS `natural_dockets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_dockets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `nationality` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `marital_status` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_natural_dockets_on_issue_id` (`issue_id`),
  KEY `index_natural_dockets_on_person_id` (`person_id`),
  KEY `index_natural_dockets_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_4a049721c5` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_8a1c762da4` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_f535aad76b` FOREIGN KEY (`replaced_by_id`) REFERENCES `natural_dockets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_dockets`
--

LOCK TABLES `natural_dockets` WRITE;
/*!40000 ALTER TABLE `natural_dockets` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_dockets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `people`
--

LOCK TABLES `people` WRITE;
/*!40000 ALTER TABLE `people` DISABLE KEYS */;
INSERT INTO `people` VALUES (37,'2018-02-09 14:35:32','2018-02-09 14:35:32'),(38,'2018-02-09 17:14:55','2018-02-09 17:14:55'),(39,'2018-02-09 17:24:18','2018-02-09 17:24:18'),(40,'2018-02-09 17:25:16','2018-02-09 17:25:16'),(41,'2018-02-09 17:28:49','2018-02-09 17:28:49'),(42,'2018-02-09 17:29:22','2018-02-09 17:29:22'),(43,'2018-02-09 17:32:01','2018-02-09 17:32:01'),(44,'2018-02-09 17:48:04','2018-02-09 17:48:04'),(45,'2018-02-09 17:48:42','2018-02-09 17:48:42');
/*!40000 ALTER TABLE `people` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quota`
--

DROP TABLE IF EXISTS `quota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `weight` decimal(10,0) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `person_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `replaced_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quota_on_issue_id` (`issue_id`),
  KEY `index_quota_on_person_id` (`person_id`),
  KEY `index_quota_on_replaced_by_id` (`replaced_by_id`),
  CONSTRAINT `fk_rails_16972bcf3e` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_3b222a73f5` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_dcf8249341` FOREIGN KEY (`replaced_by_id`) REFERENCES `quota` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quota`
--

LOCK TABLES `quota` WRITE;
/*!40000 ALTER TABLE `quota` DISABLE KEYS */;
/*!40000 ALTER TABLE `quota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quota_seeds`
--

DROP TABLE IF EXISTS `quota_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `weight` decimal(10,0) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `issue_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `quota_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_quota_seeds_on_issue_id` (`issue_id`),
  KEY `index_quota_seeds_on_quota_id` (`quota_id`),
  CONSTRAINT `fk_rails_78f865168f` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`),
  CONSTRAINT `fk_rails_c065d0a320` FOREIGN KEY (`quota_id`) REFERENCES `quota` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quota_seeds`
--

LOCK TABLES `quota_seeds` WRITE;
/*!40000 ALTER TABLE `quota_seeds` DISABLE KEYS */;
INSERT INTO `quota_seeds` VALUES (1,10,1000,'USD',98,'2018-02-09 14:35:32','2018-02-09 14:35:32',NULL),(2,10,1000,'USD',106,'2018-02-14 19:43:11','2018-02-14 19:43:11',NULL);
/*!40000 ALTER TABLE `quota_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relationship_seeds`
--

DROP TABLE IF EXISTS `relationship_seeds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship_seeds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `issue_id` bigint(20) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_relationship_seeds_on_issue_id` (`issue_id`),
  CONSTRAINT `fk_rails_8674ebe247` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relationship_seeds`
--

LOCK TABLES `relationship_seeds` WRITE;
/*!40000 ALTER TABLE `relationship_seeds` DISABLE KEYS */;
/*!40000 ALTER TABLE `relationship_seeds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20180202145539'),('20180202145951'),('20180202151445'),('20180202152609'),('20180202154501'),('20180202174319'),('20180202180036'),('20180202182937'),('20180202183832'),('20180202192416'),('20180202200038'),('20180205155215'),('20180205162033'),('20180205172712'),('20180206131035'),('20180206131303'),('20180206131630'),('20180206133111'),('20180206133151'),('20180206133349'),('20180206140841'),('20180206141139'),('20180206141337'),('20180206142151'),('20180206142401'),('20180206142551'),('20180206165610'),('20180206165613'),('20180209135645'),('20180209135925'),('20180209140318'),('20180209140603'),('20180209150152'),('20180215172048');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-15 15:24:23
