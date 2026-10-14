-- =====================================================
-- PAYFLOW - TỐI ƯU TRUY VẤN BÁO CÁO DÒNG TIỀN NẠP (MySQL 8.0+)
-- =====================================================
CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    transaction_type VARCHAR(20), -- 'DEPOSIT', 'WITHDRAW', 'TRANSFER'
    created_at DATETIME
);

-- -----------------------------------------------------
-- (TÙY CHỌN) Sinh dữ liệu giả lập để EXPLAIN có ý nghĩa.
-- Mặc định 300.000 dòng; tăng giá trị 300000 nếu muốn nhiều hơn.
-- Chỉ chạy khi bảng đang trống.
-- -----------------------------------------------------
SET SESSION cte_max_recursion_depth = 1000000;
INSERT INTO Transactions (user_id, amount, transaction_type, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 300000
)
SELECT FLOOR(1 + RAND() * 10000),
       ROUND(10000 + RAND() * 5000000, 2),
       ELT(1 + FLOOR(RAND() * 3), 'DEPOSIT', 'WITHDRAW', 'TRANSFER'),
       TIMESTAMP('2025-01-01') + INTERVAL FLOOR(RAND() * 730 * 86400) SECOND
FROM seq;

-- =====================================================
-- A. TRUY VẤN CŨ (Non-SARGable) - bọc hàm quanh cột created_at
--    Kỳ vọng: type = ALL, key = NULL, rows ~ toàn bộ bảng
-- =====================================================
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND YEAR(created_at) = 2026
  AND MONTH(created_at) = 6;

-- =====================================================
-- B. TẠO COMPOSITE INDEX
--    transaction_type đứng trước (điều kiện = ), created_at đứng sau (điều kiện range)
-- =====================================================
CREATE INDEX idx_type_date ON Transactions (transaction_type, created_at);

-- =====================================================
-- C. TRUY VẤN MỚI (SARGable) - dùng khoảng thời gian [đầu tháng, đầu tháng sau)
--    Kỳ vọng: type = range, key = idx_type_date, rows giảm mạnh
-- =====================================================
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- Chạy thật để lấy kết quả (kết quả phải trùng với truy vấn cũ)
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- =====================================================
-- D. (THAM KHẢO) Đo thời gian thực thi
-- =====================================================
-- SET profiling = 1;
-- (chạy câu SELECT ở trên)
-- SHOW PROFILES;

-- =====================================================
-- E. (THAM KHẢO) Covering Index: thêm amount để cột Extra hiện "Using index"
--    (không cần quay lại bảng đọc amount). Đánh đổi: index lớn hơn, ghi chậm hơn.
-- =====================================================
-- CREATE INDEX idx_type_date_amount ON Transactions (transaction_type, created_at, amount);
