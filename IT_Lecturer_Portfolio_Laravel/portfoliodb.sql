-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 24, 2026 at 02:46 AM
-- Server version: 8.4.7
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `portfoliodb`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba', 'i:2;', 1792807714),
('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer', 'i:1792807714;', 1792807714);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `experiences`
--

DROP TABLE IF EXISTS `experiences`;
CREATE TABLE IF NOT EXISTS `experiences` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `date_label` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text COLLATE utf8mb4_unicode_ci,
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `experiences_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `experiences`
--

INSERT INTO `experiences` (`id`, `user_id`, `date_label`, `title`, `company`, `details`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, 'CURRENT', 'IT Lecturer / Teacher', 'University of South-East Asia', 'Teach .NET Technology and C++ Programming for IT students.\nPrepare lectures, exercises, programming examples, and practical activities.\nGuide students through programming, database, and software development concepts.\nDevelop and improve teaching materials and core study resources.', 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, 'PREVIOUS', 'IT / Developer / Database Role', 'Future Bright International School', 'Develop and maintain internal information systems.\nManage databases, servers, computers, and network infrastructure.\nProvide technical troubleshooting and IT support.\nResearch and implement software solutions for organizational needs.', 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `highlights`
--

DROP TABLE IF EXISTS `highlights`;
CREATE TABLE IF NOT EXISTS `highlights` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `icon` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtitle` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `highlights_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `highlights`
--

INSERT INTO `highlights` (`id`, `user_id`, `icon`, `title`, `subtitle`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, '🎓', 'Master’s Student', 'Information Technology', 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, '👨‍🏫', 'University Lecturer', 'IT Major', 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 2, '💻', 'Software Developer', 'Full-stack & Desktop', 3, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(4, 2, '🔬', 'Researcher', 'Technology & Education', 4, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_10_24_000001_add_portfolio_fields_to_users_table', 1),
(5, '2026_10_24_000002_create_portfolio_tables', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE IF NOT EXISTS `profiles` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '0',
  `full_name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `headline` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_line1` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_line2` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hero_text` text COLLATE utf8mb4_unicode_ci,
  `role_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_text` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `code_items` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_text` text COLLATE utf8mb4_unicode_ci,
  `experience_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `projects_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `research_text` text COLLATE utf8mb4_unicode_ci,
  `contact_title` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_text` text COLLATE utf8mb4_unicode_ci,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linkedin` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `github` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_description` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `footer_tagline` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `profiles_user_id_unique` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `profiles`
--

INSERT INTO `profiles` (`id`, `user_id`, `is_public`, `full_name`, `headline`, `hero_line1`, `hero_line2`, `hero_text`, `role_title`, `status_text`, `code_items`, `avatar`, `about_title`, `about_text`, `experience_title`, `skills_title`, `projects_title`, `research_title`, `research_text`, `contact_title`, `contact_text`, `email`, `linkedin`, `github`, `meta_description`, `footer_tagline`, `created_at`, `updated_at`) VALUES
(1, 1, 0, 'Administrator', 'PORTFOLIO', 'Hello, I am Administrator.', 'Welcome to my portfolio.', NULL, NULL, NULL, NULL, NULL, 'About me.', NULL, 'Experience.', 'Skills.', 'Projects.', 'Research & learning.', NULL, 'Get in touch.', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-23 19:06:18', '2026-10-23 19:06:18'),
(2, 2, 1, 'Nat Vannak', 'IT LECTURER • DEVELOPER • RESEARCHER', 'Building technology.', 'Teaching the future.', 'IT educator and software developer passionate about teaching, research, system development, and learning emerging technologies.', 'IT Lecturer & Software Developer', 'Available for collaboration', 'Teaching, Research, Development', NULL, 'Technology with a purpose.', 'I am currently teaching IT at the **University of South-East Asia**, where I am responsible for **.NET Technology** and **C++ Programming** subjects.\nI am also pursuing a **Master’s degree in Information Technology**. My interests include software development, database systems, education technology, research, and continuous self-learning.\nI enjoy adapting to new technologies and transforming technical knowledge into practical learning experiences for students.', 'Teaching & professional journey.', 'Tools I work with.', 'Selected work.', 'Always learning.\nAlways experimenting.', 'Interested in practical research at the intersection of software engineering, education technology, databases, AI, and emerging technologies.', 'Let’s build something useful.', 'Interested in collaboration, research, teaching, or software projects?', 'your.email@example.com', NULL, NULL, 'Modern IT Lecturer, Developer and Researcher Portfolio', 'IT Lecturer • Developer • Researcher', '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 3, 1, 'sophoan', 'PORTFOLIO', 'Hello, I am sophoan.', 'Welcome to my portfolio.', NULL, 'Teacher English', 'Free all time', NULL, 'avatars/DsYJhuVZWJid8slBjieKE9UdCIIfGUZwRV0Dexwm.jpg', 'About me.', NULL, 'Experience.', 'Skills.', 'Projects.', 'Research & learning.', NULL, 'Get in touch.', NULL, NULL, NULL, NULL, NULL, NULL, '2026-10-23 19:07:43', '2026-10-23 19:13:45');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
CREATE TABLE IF NOT EXISTS `projects` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `icon` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `tags` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_label` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `projects_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `user_id`, `icon`, `title`, `description`, `tags`, `link_url`, `link_label`, `featured`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, '📊', 'Training Management System', 'A management platform for organizing training programs, participants, schedules, and reporting.', 'ASP.NET, MySQL, Agile', '#contact', 'View project', 1, 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, '📱', 'Attendance System', 'Mobile attendance solution using QR verification, geofencing, authentication, and API services.', 'Flutter, Laravel, API', '#contact', 'View project', 0, 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 2, '🧠', 'Khmer OCR Research', 'Exploring computer vision and custom CNN models for Khmer character recognition.', 'Python, CNN, AI', '#research', 'Research', 0, 3, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(4, 2, '☁️', 'Cloud & DevOps Lab', 'Hands-on experiments with AWS, Docker, Linux, Terraform, CI/CD, and cloud infrastructure.', 'AWS, Docker, Terraform', '#contact', 'View project', 0, 4, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `research_topics`
--

DROP TABLE IF EXISTS `research_topics`;
CREATE TABLE IF NOT EXISTS `research_topics` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `research_topics_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_topics`
--

INSERT INTO `research_topics` (`id`, `user_id`, `name`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, 'Artificial Intelligence', 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, 'Education Technology', 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 2, 'Software Engineering', 3, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(4, 2, 'Database Systems', 4, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(5, 2, 'Cloud Computing', 5, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(6, 2, 'IoT & Blockchain', 6, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('CO2Zcz23e3PN2beBqUs1RkUjw9SoWVVGbrOy14b5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', 'eyJfdG9rZW4iOiJrOXh4OWltMFhiSHRwUFBING51blh3WDRxT0ZDYVNzdVJiWWJoSVNmIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJfcHJldmlvdXMiOnsidXJsIjoiaHR0cDpcL1wvMTI3LjAuMC4xOjgwMDAiLCJyb3V0ZSI6ImhvbWUifX0=', 1792809654);

-- --------------------------------------------------------

--
-- Table structure for table `skill_categories`
--

DROP TABLE IF EXISTS `skill_categories`;
CREATE TABLE IF NOT EXISTS `skill_categories` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `skills` text COLLATE utf8mb4_unicode_ci,
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `skill_categories_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `skill_categories`
--

INSERT INTO `skill_categories` (`id`, `user_id`, `name`, `skills`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, 'Programming', 'C#, C++, PHP, Java, Kotlin, Python', 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, 'Web & Frameworks', '.NET, ASP.NET Core, Laravel, Flutter, Spring Boot', 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 2, 'Database & DevOps', 'MySQL, SQL, Docker, AWS, Git, Linux', 3, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(4, 2, 'Professional', 'Teaching, Research, Problem Solving, Self-Learning, Teamwork', 4, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
CREATE TABLE IF NOT EXISTS `stats` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `value` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` smallint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stats_user_id_foreign` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stats`
--

INSERT INTO `stats` (`id`, `user_id`, `value`, `label`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 2, 'IT', 'Lecturer', 1, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(2, 2, '.NET', 'Technology', 2, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 2, 'C++', 'Programming', 3, '2026-10-23 19:06:19', '2026-10-23 19:06:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `email`, `email_verified_at`, `password`, `role`, `is_active`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Administrator', 'admin-user', 'admin@example.com', NULL, '$2y$12$WnlbQ3AUwthkbIXU4mz3ee/mKHZOJMzikRd1jLnsudAhFN9JWsjMy', 'admin', 1, NULL, '2026-10-23 19:06:18', '2026-10-23 19:06:18'),
(2, 'Nat Vannak', 'natvannak', 'natvannak@example.com', NULL, '$2y$12$9PxJLms6mTEhBVYHd5ZojeGN9y4SYqEXsqKYfgj2NwtXgwp2oNYwC', 'user', 1, NULL, '2026-10-23 19:06:19', '2026-10-23 19:06:19'),
(3, 'sophoan', 'sophoan', 'sophoan@gmail.com', NULL, '$2y$12$dgamfDz/9EdKl5pPV/wOCep2HsWrJRaMD.5wcoEu9ldNjZr0h1IG2', 'user', 1, NULL, '2026-10-23 19:07:43', '2026-10-23 19:07:43');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `experiences`
--
ALTER TABLE `experiences`
  ADD CONSTRAINT `experiences_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `highlights`
--
ALTER TABLE `highlights`
  ADD CONSTRAINT `highlights_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `profiles`
--
ALTER TABLE `profiles`
  ADD CONSTRAINT `profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `research_topics`
--
ALTER TABLE `research_topics`
  ADD CONSTRAINT `research_topics_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `skill_categories`
--
ALTER TABLE `skill_categories`
  ADD CONSTRAINT `skill_categories_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stats`
--
ALTER TABLE `stats`
  ADD CONSTRAINT `stats_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
