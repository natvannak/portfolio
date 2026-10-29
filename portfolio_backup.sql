/*
 Navicat MySQL Dump SQL

 Source Server         : Database
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : portfoliodb

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 29/10/2026 22:36:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for cache
-- ----------------------------
DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of cache
-- ----------------------------
BEGIN;
INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES ('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba', 'i:2;', 1793288087);
INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES ('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer', 'i:1793288087;', 1793288087);
COMMIT;

-- ----------------------------
-- Table structure for cache_locks
-- ----------------------------
DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of cache_locks
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for experiences
-- ----------------------------
DROP TABLE IF EXISTS `experiences`;
CREATE TABLE `experiences` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `date_label` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `company` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `experiences_user_id_foreign` (`user_id`),
  CONSTRAINT `experiences_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of experiences
-- ----------------------------
BEGIN;
INSERT INTO `experiences` (`id`, `user_id`, `date_label`, `title`, `company`, `details`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, 'CURRENT', 'IT Lecturer / Teacher', 'University of South-East Asia', 'Teach .NET Technology and C++ Programming for IT students.\nPrepare lectures, exercises, programming examples, and practical activities.\nGuide students through programming, database, and software development concepts.\nDevelop and improve teaching materials and core study resources.', 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `experiences` (`id`, `user_id`, `date_label`, `title`, `company`, `details`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, 'PREVIOUS', 'IT / Developer / Database Role', 'Future Bright International School', 'Develop and maintain internal information systems.\nManage databases, servers, computers, and network infrastructure.\nProvide technical troubleshooting and IT support.\nResearch and implement software solutions for organizational needs.', 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for failed_jobs
-- ----------------------------
DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of failed_jobs
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for highlights
-- ----------------------------
DROP TABLE IF EXISTS `highlights`;
CREATE TABLE `highlights` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `highlights_user_id_foreign` (`user_id`),
  CONSTRAINT `highlights_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of highlights
-- ----------------------------
BEGIN;
INSERT INTO `highlights` (`id`, `user_id`, `icon`, `title`, `subtitle`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, '🎓', 'Master’s Student', 'Information Technology', 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `highlights` (`id`, `user_id`, `icon`, `title`, `subtitle`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, '👨‍🏫', 'University Lecturer', 'IT Major', 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `highlights` (`id`, `user_id`, `icon`, `title`, `subtitle`, `sort_order`, `created_at`, `updated_at`) VALUES (3, 2, '💻', 'Software Developer', 'Full-stack & Desktop', 3, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `highlights` (`id`, `user_id`, `icon`, `title`, `subtitle`, `sort_order`, `created_at`, `updated_at`) VALUES (4, 2, '🔬', 'Researcher', 'Technology & Education', 4, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for job_batches
-- ----------------------------
DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE `job_batches` (
  `id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of job_batches
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for jobs
-- ----------------------------
DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of jobs
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for migrations
-- ----------------------------
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of migrations
-- ----------------------------
BEGIN;
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (1, '0001_01_01_000000_create_users_table', 1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (2, '0001_01_01_000001_create_cache_table', 1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (3, '0001_01_01_000002_create_jobs_table', 1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (4, '2026_10_24_000001_add_portfolio_fields_to_users_table', 1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (5, '2026_10_24_000002_create_portfolio_tables', 1);
COMMIT;

-- ----------------------------
-- Table structure for password_reset_tokens
-- ----------------------------
DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of password_reset_tokens
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for profiles
-- ----------------------------
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '0',
  `full_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `headline` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_line1` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_line2` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `role_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_text` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `code_items` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `experience_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `projects_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `contact_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linkedin` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `github` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `footer_tagline` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `profiles_user_id_unique` (`user_id`),
  CONSTRAINT `profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of profiles
-- ----------------------------
BEGIN;
INSERT INTO `profiles` (`id`, `user_id`, `is_public`, `full_name`, `headline`, `hero_line1`, `hero_line2`, `hero_text`, `role_title`, `status_text`, `code_items`, `avatar`, `about_title`, `about_text`, `experience_title`, `skills_title`, `projects_title`, `research_title`, `research_text`, `contact_title`, `contact_text`, `email`, `linkedin`, `github`, `meta_description`, `footer_tagline`, `created_at`, `updated_at`) VALUES (1, 1, 0, 'Administrator', 'PORTFOLIO', 'Hello, I am Administrator.', 'Welcome to my portfolio.', NULL, NULL, NULL, NULL, NULL, 'About me.', NULL, 'Experience.', 'Skills.', 'Projects.', 'Research & learning.', NULL, 'Get in touch.', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 02:06:18', '2026-10-24 02:06:18');
INSERT INTO `profiles` (`id`, `user_id`, `is_public`, `full_name`, `headline`, `hero_line1`, `hero_line2`, `hero_text`, `role_title`, `status_text`, `code_items`, `avatar`, `about_title`, `about_text`, `experience_title`, `skills_title`, `projects_title`, `research_title`, `research_text`, `contact_title`, `contact_text`, `email`, `linkedin`, `github`, `meta_description`, `footer_tagline`, `created_at`, `updated_at`) VALUES (2, 2, 1, 'Nat Vannak', 'IT LECTURER • DEVELOPER • RESEARCHER', 'Building technology.', 'Teaching the future.', 'IT educator and software developer passionate about teaching, research, system development, and learning emerging technologies.', 'IT Lecturer & Software Developer', 'Available for collaboration', 'Teaching, Research, Development', NULL, 'Technology with a purpose.', 'I am currently teaching IT at the **University of South-East Asia**, where I am responsible for **.NET Technology** and **C++ Programming** subjects.\nI am also pursuing a **Master’s degree in Information Technology**. My interests include software development, database systems, education technology, research, and continuous self-learning.\nI enjoy adapting to new technologies and transforming technical knowledge into practical learning experiences for students.', 'Teaching & professional journey.', 'Tools I work with.', 'Selected work.', 'Always learning.\nAlways experimenting.', 'Interested in practical research at the intersection of software engineering, education technology, databases, AI, and emerging technologies.', 'Let’s build something useful.', 'Interested in collaboration, research, teaching, or software projects?', 'your.email@example.com', NULL, NULL, 'Modern IT Lecturer, Developer and Researcher Portfolio', 'IT Lecturer • Developer • Researcher', '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `profiles` (`id`, `user_id`, `is_public`, `full_name`, `headline`, `hero_line1`, `hero_line2`, `hero_text`, `role_title`, `status_text`, `code_items`, `avatar`, `about_title`, `about_text`, `experience_title`, `skills_title`, `projects_title`, `research_title`, `research_text`, `contact_title`, `contact_text`, `email`, `linkedin`, `github`, `meta_description`, `footer_tagline`, `created_at`, `updated_at`) VALUES (3, 3, 1, 'Test', 'PORTFOLIO', 'Hello, I am test.', 'Welcome to my portfolio.', NULL, 'Teacher English', 'Free all time', NULL, 'avatars/DsYJhuVZWJid8slBjieKE9UdCIIfGUZwRV0Dexwm.jpg', 'About me.', NULL, 'Experience.', 'Skills.', 'Projects.', 'Research & learning.', NULL, 'Get in touch.', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-24 02:07:43', '2026-10-29 15:35:20');
COMMIT;

-- ----------------------------
-- Table structure for projects
-- ----------------------------
DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `icon` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_label` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `projects_user_id_foreign` (`user_id`),
  CONSTRAINT `projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of projects
-- ----------------------------
BEGIN;
INSERT INTO `projects` (`id`, `user_id`, `icon`, `title`, `description`, `tags`, `link_url`, `link_label`, `featured`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, '📊', 'Training Management System', 'A management platform for organizing training programs, participants, schedules, and reporting.', 'ASP.NET, MySQL, Agile', '#contact', 'View project', 1, 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `projects` (`id`, `user_id`, `icon`, `title`, `description`, `tags`, `link_url`, `link_label`, `featured`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, '📱', 'Attendance System', 'Mobile attendance solution using QR verification, geofencing, authentication, and API services.', 'Flutter, Laravel, API', '#contact', 'View project', 0, 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `projects` (`id`, `user_id`, `icon`, `title`, `description`, `tags`, `link_url`, `link_label`, `featured`, `sort_order`, `created_at`, `updated_at`) VALUES (3, 2, '🧠', 'Khmer OCR Research', 'Exploring computer vision and custom CNN models for Khmer character recognition.', 'Python, CNN, AI', '#research', 'Research', 0, 3, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `projects` (`id`, `user_id`, `icon`, `title`, `description`, `tags`, `link_url`, `link_label`, `featured`, `sort_order`, `created_at`, `updated_at`) VALUES (4, 2, '☁️', 'Cloud & DevOps Lab', 'Hands-on experiments with AWS, Docker, Linux, Terraform, CI/CD, and cloud infrastructure.', 'AWS, Docker, Terraform', '#contact', 'View project', 0, 4, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for research_topics
-- ----------------------------
DROP TABLE IF EXISTS `research_topics`;
CREATE TABLE `research_topics` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `research_topics_user_id_foreign` (`user_id`),
  CONSTRAINT `research_topics_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of research_topics
-- ----------------------------
BEGIN;
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, 'Artificial Intelligence', 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, 'Education Technology', 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (3, 2, 'Software Engineering', 3, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (4, 2, 'Database Systems', 4, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (5, 2, 'Cloud Computing', 5, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES (6, 2, 'IoT & Blockchain', 6, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for sessions
-- ----------------------------
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of sessions
-- ----------------------------
BEGIN;
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES ('5Qfw5plwLPVcAbShKwPWeU0blNYS9vyenlgezfbU', NULL, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 'eyJfdG9rZW4iOiJKTnRMSkZoS2xweXF5czY4RmJTNWNFeWlVdmxrdWs1ZWI4bXZkbTNwIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9uYXR2YW5uYWsiLCJyb3V0ZSI6InBvcnRmb2xpby5zaG93In0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=', 1793032688);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES ('CO2Zcz23e3PN2beBqUs1RkUjw9SoWVVGbrOy14b5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', 'eyJfdG9rZW4iOiJrOXh4OWltMFhiSHRwUFBING51blh3WDRxT0ZDYVNzdVJiWWJoSVNmIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJfcHJldmlvdXMiOnsidXJsIjoiaHR0cDpcL1wvMTI3LjAuMC4xOjgwMDAiLCJyb3V0ZSI6ImhvbWUifX0=', 1792809654);
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES ('vL45jFVniRwXydI2szfGpaaTZGb3HvAijiOdDiIf', 3, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', 'eyJfdG9rZW4iOiJQNU9PdEJYRTluZUk0djVmeGQ2ZnhFT056d2ZMMEJEa2t0b242WDNnIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC90ZXN0MSIsInJvdXRlIjoicG9ydGZvbGlvLnNob3cifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI6MywicGFzc3dvcmRfaGFzaF93ZWIiOiIyZjczMmE3ZGRmMmQyMjhhN2NkYzE4YmI0ZTNmYWYyYjhhMDM1NTU2OWJjY2Y4YzhkNDIyZWJmNTU5OWZiZGQyIn0=', 1793288121);
COMMIT;

-- ----------------------------
-- Table structure for skill_categories
-- ----------------------------
DROP TABLE IF EXISTS `skill_categories`;
CREATE TABLE `skill_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `skills` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `skill_categories_user_id_foreign` (`user_id`),
  CONSTRAINT `skill_categories_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of skill_categories
-- ----------------------------
BEGIN;
INSERT INTO `skill_categories` (`id`, `user_id`, `name`, `skills`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, 'Programming', 'C#, C++, PHP, Java, Kotlin, Python', 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `skill_categories` (`id`, `user_id`, `name`, `skills`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, 'Web & Frameworks', '.NET, ASP.NET Core, Laravel, Flutter, Spring Boot', 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `skill_categories` (`id`, `user_id`, `name`, `skills`, `sort_order`, `created_at`, `updated_at`) VALUES (3, 2, 'Database & DevOps', 'MySQL, SQL, Docker, AWS, Git, Linux', 3, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `skill_categories` (`id`, `user_id`, `name`, `skills`, `sort_order`, `created_at`, `updated_at`) VALUES (4, 2, 'Professional', 'Teaching, Research, Problem Solving, Self-Learning, Teamwork', 4, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for stats
-- ----------------------------
DROP TABLE IF EXISTS `stats`;
CREATE TABLE `stats` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `value` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stats_user_id_foreign` (`user_id`),
  CONSTRAINT `stats_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of stats
-- ----------------------------
BEGIN;
INSERT INTO `stats` (`id`, `user_id`, `value`, `label`, `sort_order`, `created_at`, `updated_at`) VALUES (1, 2, 'IT', 'Lecturer', 1, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `stats` (`id`, `user_id`, `value`, `label`, `sort_order`, `created_at`, `updated_at`) VALUES (2, 2, '.NET', 'Technology', 2, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `stats` (`id`, `user_id`, `value`, `label`, `sort_order`, `created_at`, `updated_at`) VALUES (3, 2, 'C++', 'Programming', 3, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
COMMIT;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO `users` (`id`, `name`, `username`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES (1, 'Administrator', 'admin-user', 'admin@example.com', NULL, '$2y$12$WnlbQ3AUwthkbIXU4mz3ee/mKHZOJMzikRd1jLnsudAhFN9JWsjMy', 'admin', 1, NULL, '2026-10-24 02:06:18', '2026-10-24 02:06:18');
INSERT INTO `users` (`id`, `name`, `username`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES (2, 'Nat Vannak', 'natvannak', 'natvannak@example.com', NULL, '$2y$12$9PxJLms6mTEhBVYHd5ZojeGN9y4SYqEXsqKYfgj2NwtXgwp2oNYwC', 'user', 1, NULL, '2026-10-24 02:06:19', '2026-10-24 02:06:19');
INSERT INTO `users` (`id`, `name`, `username`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES (3, 'test1', 'test1', 'test1@gmail.com', NULL, '$2y$12$dgamfDz/9EdKl5pPV/wOCep2HsWrJRaMD.5wcoEu9ldNjZr0h1IG2', 'user', 1, NULL, '2026-10-24 02:07:43', '2026-10-29 15:34:57');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
