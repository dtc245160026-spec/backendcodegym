-- =====================================================
-- THỰC HÀNH: TRUY VẤN DỮ LIỆU VỚI CSDL QUẢN LÝ SINH VIÊN
-- =====================================================

-- Bước 1: Sử dụng cơ sở dữ liệu
USE QuanLySinhVien;

-- Bước 2: Hiển thị danh sách tất cả các học viên
SELECT *
FROM Student;

-- Bước 3: Hiển thị danh sách các học viên đang theo học
SELECT *
FROM Student
WHERE Status = true;

-- Bước 4: Hiển thị danh sách các môn học có thời gian học nhỏ hơn 10 giờ
SELECT *
FROM Subject
WHERE Credit < 10;

-- Bước 5: Hiển thị danh sách học viên lớp A1
SELECT S.StudentId, S.StudentName, C.ClassName
FROM Student S
JOIN Class C ON S.ClassId = C.ClassID
WHERE C.ClassName = 'A1';

-- Bước 6: Hiển thị điểm môn CF của các học viên
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark
FROM Student S
JOIN Mark M ON S.StudentId = M.StudentId
JOIN Subject Sub ON M.SubId = Sub.SubId
WHERE Sub.SubName = 'CF';
