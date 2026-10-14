-- =====================================================
-- THỰC HÀNH: THÊM DỮ LIỆU VÀO CƠ SỞ DỮ LIỆU QUẢN LÝ SINH VIÊN
-- =====================================================

-- (Phần dưới chỉ tạo lại cấu trúc nếu bạn chưa có CSDL từ bài thực hành trước)
CREATE DATABASE IF NOT EXISTS QuanLySinhVien;
USE QuanLySinhVien;

CREATE TABLE IF NOT EXISTS Class (
    ClassID   INT AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(60) NOT NULL,
    StartDate DATETIME NOT NULL,
    Status    BIT
);

CREATE TABLE IF NOT EXISTS Student (
    StudentId   INT AUTO_INCREMENT PRIMARY KEY,
    StudentName VARCHAR(30) NOT NULL,
    Address     VARCHAR(50),
    Phone       VARCHAR(20),
    Status      BIT,
    ClassId     INT NOT NULL,
    FOREIGN KEY (ClassId) REFERENCES Class(ClassID)
);

CREATE TABLE IF NOT EXISTS Subject (
    SubId   INT AUTO_INCREMENT PRIMARY KEY,
    SubName VARCHAR(30) NOT NULL,
    Credit  TINYINT NOT NULL DEFAULT 1 CHECK (Credit >= 1),
    Status  BIT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Mark (
    MarkId    INT AUTO_INCREMENT PRIMARY KEY,
    SubId     INT NOT NULL,
    StudentId INT NOT NULL,
    Mark      FLOAT DEFAULT 0,
    ExamTimes TINYINT DEFAULT 1,
    UNIQUE (SubId, StudentId),
    FOREIGN KEY (SubId) REFERENCES Subject(SubId),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
);

-- ---------- BƯỚC 1: Sử dụng cơ sở dữ liệu ----------
USE QuanLySinhVien;

-- ---------- BƯỚC 2: Bảng Class ----------
INSERT INTO Class
VALUES (1, 'A1', '2008-12-20', 1);
INSERT INTO Class
VALUES (2, 'A2', '2008-12-22', 1);
INSERT INTO Class
VALUES (3, 'B3', current_date, 0);

-- ---------- BƯỚC 3: Bảng Student ----------
INSERT INTO Student (StudentName, Address, Phone, Status, ClassId)
VALUES ('Hung', 'Ha Noi', '0912113113', 1, 1);
INSERT INTO Student (StudentName, Address, Status, ClassId)
VALUES ('Hoa', 'Hai phong', 1, 1);
INSERT INTO Student (StudentName, Address, Phone, Status, ClassId)
VALUES ('Manh', 'HCM', '0123123123', 0, 2);

-- ---------- BƯỚC 4: Bảng Subject ----------
INSERT INTO Subject
VALUES (1, 'CF', 5, 1),
       (2, 'C', 6, 1),
       (3, 'HDJ', 5, 1),
       (4, 'RDBMS', 10, 1);

-- ---------- BƯỚC 5: Bảng Mark ----------
INSERT INTO Mark (SubId, StudentId, Mark, ExamTimes)
VALUES (1, 1, 8, 1),
       (1, 2, 10, 2),
       (2, 1, 12, 1);

-- ---------- KIỂM TRA ----------
SELECT * FROM Class;
SELECT * FROM Student;
SELECT * FROM Subject;
SELECT * FROM Mark;
