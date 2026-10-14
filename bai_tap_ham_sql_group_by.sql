-- BÀI TẬP: LUYỆN TẬP CÁC HÀM THÔNG DỤNG TRONG SQL
-- CSDL: QuanLySinhVien
-- Mục tiêu: luyện tập các hàm thông dụng và GROUP BY trong MySQL.
--
-- LƯU Ý:
-- 1. Chạy trên CSDL QuanLySinhVien đã tạo trong các bài thực hành trước.
-- 2. Script giả định cấu trúc thường gặp:
--      subject(subject_id, subject_name, credit)
--      mark(student_id, subject_id, mark)
--      student(student_id, student_name, ...)
--    Tên bảng/cột có thể khác trong CSDL của bạn; hãy điều chỉnh cho khớp.
-- 3. Nếu bảng điểm hoặc khóa ngoại của bạn có tên khác, sửa JOIN tương ứng.

USE QuanLySinhVien;

-- =========================================================
-- CÂU 1. Hiển thị tất cả thông tin môn học có credit lớn nhất
-- =========================================================
SELECT *
FROM subject
WHERE credit = (
    SELECT MAX(credit)
    FROM subject
);

-- =========================================================
-- CÂU 2. Hiển thị thông tin môn học có điểm thi lớn nhất
-- Giả định bảng mark lưu điểm theo student_id, subject_id, mark.
-- Truy vấn trả về tất cả môn học có ít nhất một điểm bằng điểm cao nhất.
-- =========================================================
SELECT DISTINCT s.*
FROM subject AS s
JOIN mark AS m ON m.subject_id = s.subject_id
WHERE m.mark = (
    SELECT MAX(mark)
    FROM mark
);

-- =========================================================
-- CÂU 3. Hiển thị thông tin sinh viên và điểm trung bình mỗi sinh viên,
-- xếp hạng theo điểm trung bình giảm dần
-- Giả định bảng student và mark liên kết qua student_id.
-- =========================================================
SELECT
    st.student_id,
    st.student_name,
    ROUND(AVG(m.mark), 2) AS average_mark
FROM student AS st
LEFT JOIN mark AS m ON m.student_id = st.student_id
GROUP BY st.student_id, st.student_name
ORDER BY average_mark DESC;

-- Nếu MySQL của bạn hỗ trợ hàm xếp hạng (MySQL 8.0+), có thể dùng:
-- WITH student_averages AS (
--     SELECT
--         st.student_id,
--         st.student_name,
--         ROUND(AVG(m.mark), 2) AS average_mark
--     FROM student AS st
--     LEFT JOIN mark AS m ON m.student_id = st.student_id
--     GROUP BY st.student_id, st.student_name
-- )
-- SELECT
--     student_id,
--     student_name,
--     average_mark,
--     DENSE_RANK() OVER (ORDER BY average_mark DESC) AS ranking
-- FROM student_averages
-- ORDER BY average_mark DESC;
