-- Thuc hanh: Tao CSDL QuanLySinhVien
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS QuanLySinhVien
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE QuanLySinhVien;

-- Xoa bang theo thu tu phu thuoc de co the chay lai script
DROP TABLE IF EXISTS Mark;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Subject;
DROP TABLE IF EXISTS Class;

CREATE TABLE Class (
    ClassID INT NOT NULL AUTO_INCREMENT,
    ClassName VARCHAR(60) NOT NULL,
    StartDate DATETIME NOT NULL,
    Status BIT,
    PRIMARY KEY (ClassID)
) ENGINE=InnoDB;

CREATE TABLE Student (
    StudentID INT NOT NULL AUTO_INCREMENT,
    StudentName VARCHAR(30) NOT NULL,
    Address VARCHAR(50),
    Phone VARCHAR(20),
    Status BIT,
    ClassID INT NOT NULL,
    PRIMARY KEY (StudentID),
    CONSTRAINT fk_student_class
        FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
) ENGINE=InnoDB;

CREATE TABLE Subject (
    SubID INT NOT NULL AUTO_INCREMENT,
    SubName VARCHAR(30) NOT NULL,
    Credit TINYINT NOT NULL DEFAULT 1,
    Status BIT DEFAULT 1,
    PRIMARY KEY (SubID),
    CONSTRAINT chk_subject_credit CHECK (Credit >= 1)
) ENGINE=InnoDB;

CREATE TABLE Mark (
    MarkID INT NOT NULL AUTO_INCREMENT,
    SubID INT NOT NULL,
    StudentID INT NOT NULL,
    Mark FLOAT DEFAULT 0,
    ExamTimes TINYINT DEFAULT 1,
    PRIMARY KEY (MarkID),
    CONSTRAINT uq_mark_subject_student UNIQUE (SubID, StudentID),
    CONSTRAINT chk_mark_range CHECK (Mark BETWEEN 0 AND 100),
    CONSTRAINT fk_mark_subject
        FOREIGN KEY (SubID) REFERENCES Subject(SubID),
    CONSTRAINT fk_mark_student
        FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
) ENGINE=InnoDB;

-- Kiem tra cac bang da tao
SHOW TABLES;
DESCRIBE Class;
DESCRIBE Student;
DESCRIBE Subject;
DESCRIBE Mark;
