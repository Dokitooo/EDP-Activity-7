-- =============================================================================
-- FENIS_Act3_updated.sql
-- Host: localhost    Database: college_information_system
-- Original Activity 3 schema + users table for Activity 5 demo
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `college_information_system`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `college_information_system`;

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

-- -----------------------------------------------------------------------------
-- Table: departments
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments` (
  `department_id`   int NOT NULL AUTO_INCREMENT,
  `department_name` varchar(100) NOT NULL,
  `office_location` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `departments` WRITE;
INSERT INTO `departments` VALUES
  (1,'Computer Science','Building A'),
  (2,'Business Administration','Building B'),
  (3,'Engineering','Building C'),
  (4,'Education','Building D'),
  (5,'Nursing','Building E'),
  (6,'Architecture','Building F'),
  (7,'Psychology','Building G'),
  (8,'Hospitality Management','Building H'),
  (9,'Criminology','Building I'),
  (10,'Information Technology','Building J');
UNLOCK TABLES;

-- -----------------------------------------------------------------------------
-- Table: courses
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
  `course_id`     int NOT NULL AUTO_INCREMENT,
  `course_code`   varchar(20) DEFAULT NULL,
  `course_title`  varchar(100) DEFAULT NULL,
  `units`         int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `course_code` (`course_code`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `courses` WRITE;
INSERT INTO `courses` VALUES
  (1,'CS101','Introduction to Programming',3,1),
  (2,'IT201','Database Systems',3,10);
UNLOCK TABLES;

-- -----------------------------------------------------------------------------
-- Table: instructors
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `instructors`;
CREATE TABLE `instructors` (
  `instructor_id` int NOT NULL AUTO_INCREMENT,
  `first_name`    varchar(50) DEFAULT NULL,
  `last_name`     varchar(50) DEFAULT NULL,
  `email`         varchar(100) DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  PRIMARY KEY (`instructor_id`),
  UNIQUE KEY `email` (`email`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `instructors_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `instructors` WRITE;
INSERT INTO `instructors` VALUES
  (1,'John','Dela Cruz','john@college.com',1),
  (2,'Anna','Santos','anna@college.com',10);
UNLOCK TABLES;

-- -----------------------------------------------------------------------------
-- Table: students
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `student_id`    int NOT NULL AUTO_INCREMENT,
  `first_name`    varchar(50) DEFAULT NULL,
  `last_name`     varchar(50) DEFAULT NULL,
  `birthdate`     date DEFAULT NULL,
  `email`         varchar(100) DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `students` WRITE;
INSERT INTO `students` VALUES
  (1,'Austin','Fenis','2004-08-01','austinfenis@email.com',1),
  (2,'Maria','Santos','2002-03-21','maria2@email.com',2),
  (3,'Kevin','Lopez','2004-07-11','kevin3@email.com',1),
  (4,'Anne','Reyes','2003-01-30','anne4@email.com',3),
  (5,'Paul','Garcia','2002-09-15','paul5@email.com',4),
  (6,'Liza','Torres','2003-12-01','liza6@email.com',5),
  (7,'Mark','Flores','2004-06-18','mark7@email.com',6),
  (8,'Ella','Rivera','2002-11-22','ella8@email.com',7),
  (9,'James','Ramos','2003-04-09','james9@email.com',8),
  (10,'Nina','Castro','2004-08-25','nina10@email.com',9);
UNLOCK TABLES;

-- -----------------------------------------------------------------------------
-- Table: enrollments
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `enrollments`;
CREATE TABLE `enrollments` (
  `enrollment_id`   int NOT NULL AUTO_INCREMENT,
  `student_id`      int DEFAULT NULL,
  `course_id`       int DEFAULT NULL,
  `instructor_id`   int DEFAULT NULL,
  `enrollment_date` date DEFAULT NULL,
  `grade`           decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  KEY `student_id` (`student_id`),
  KEY `course_id` (`course_id`),
  KEY `instructor_id` (`instructor_id`),
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`)    REFERENCES `students`    (`student_id`),
  CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`)     REFERENCES `courses`     (`course_id`),
  CONSTRAINT `enrollments_ibfk_3` FOREIGN KEY (`instructor_id`) REFERENCES `instructors` (`instructor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- Table: enrollment_logs  (+ triggers)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `enrollment_logs`;
CREATE TABLE `enrollment_logs` (
  `log_id`      int NOT NULL AUTO_INCREMENT,
  `action_type` varchar(20) DEFAULT NULL,
  `student_id`  int DEFAULT NULL,
  `course_id`   int DEFAULT NULL,
  `action_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `enrollment_logs` WRITE;
INSERT INTO `enrollment_logs` VALUES
  (1,'INSERT',1,1,'2026-03-11 03:03:07','New student enrollment added'),
  (2,'UPDATE',1,1,'2026-03-11 03:04:11','Enrollment record updated'),
  (3,'DELETE',1,1,'2026-03-11 03:05:05','Enrollment record deleted');
UNLOCK TABLES;

DELIMITER ;;
CREATE TRIGGER `trg_enrollment_insert` AFTER INSERT ON `enrollments` FOR EACH ROW BEGIN
  INSERT INTO enrollment_logs (action_type, student_id, course_id, description)
  VALUES ('INSERT', NEW.student_id, NEW.course_id, 'New student enrollment added');
END;;
CREATE TRIGGER `trg_enrollment_update` AFTER UPDATE ON `enrollments` FOR EACH ROW BEGIN
  INSERT INTO enrollment_logs (action_type, student_id, course_id, description)
  VALUES ('UPDATE', NEW.student_id, NEW.course_id, 'Enrollment record updated');
END;;
CREATE TRIGGER `trg_enrollment_delete` AFTER DELETE ON `enrollments` FOR EACH ROW BEGIN
  INSERT INTO enrollment_logs (action_type, student_id, course_id, description)
  VALUES ('DELETE', OLD.student_id, OLD.course_id, 'Enrollment record deleted');
END;;
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Views (Activity 3 originals)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `view_department_courses` AS
  SELECT d.department_name, c.course_code, c.course_title, c.units
  FROM courses c
  JOIN departments d ON c.department_id = d.department_id;

CREATE OR REPLACE VIEW `view_instructor_load` AS
  SELECT i.instructor_id,
         CONCAT(i.first_name,' ',i.last_name) AS instructor_name,
         COUNT(e.course_id) AS total_courses
  FROM instructors i
  LEFT JOIN enrollments e ON i.instructor_id = e.instructor_id
  GROUP BY i.instructor_id;

CREATE OR REPLACE VIEW `view_student_enrollments` AS
  SELECT s.student_id,
         CONCAT(s.first_name,' ',s.last_name) AS student_name,
         c.course_title,
         e.grade
  FROM enrollments e
  JOIN students s ON e.student_id = s.student_id
  JOIN courses  c ON e.course_id  = c.course_id;

-- -----------------------------------------------------------------------------
-- Table: users  (NEW - Activity 5 User Management)
-- -----------------------------------------------------------------------------
-- Default admin seeded by backend.php on first run (password: admin123)
-- To add more accounts, use the system UI or run:
--   php -r "echo password_hash('yourpassword', PASSWORD_DEFAULT);"
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id`       int NOT NULL AUTO_INCREMENT,
  `username`      varchar(50)  NOT NULL,
  `full_name`     varchar(100) NOT NULL,
  `email`         varchar(100) NOT NULL,
  `password`      varchar(255) NOT NULL,
  `status`        enum('active','inactive') NOT NULL DEFAULT 'active',
  `reset_token`   varchar(64)  DEFAULT NULL,
  `reset_expires` datetime     DEFAULT NULL,
  `created_at`    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email`    (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Note: The default admin account (username: admin / password: admin123)
-- is auto-created by backend.php when the table is empty on first run.

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
