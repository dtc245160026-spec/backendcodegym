-- =====================================================
-- BÀI TẬP: THAO TÁC VỚI CSDL QUẢN LÝ BÁN HÀNG
-- =====================================================
CREATE DATABASE IF NOT EXISTS QuanLyBanHang;
USE QuanLyBanHang;

-- (Phần tạo bảng: bỏ qua nếu đã có từ bài thực hành trước)
-- Lưu ý: Order là từ khóa của MySQL nên phải đặt trong dấu backtick `Order`
CREATE TABLE IF NOT EXISTS Customer (
    cID   INT PRIMARY KEY,
    Name  VARCHAR(25),
    cAge  TINYINT
);

CREATE TABLE IF NOT EXISTS `Order` (
    oID         INT PRIMARY KEY,
    cID         INT,
    oDate       DATETIME,
    oTotalPrice INT,
    FOREIGN KEY (cID) REFERENCES Customer(cID)
);

CREATE TABLE IF NOT EXISTS Product (
    pID    INT PRIMARY KEY,
    pName  VARCHAR(25),
    pPrice INT
);

CREATE TABLE IF NOT EXISTS OrderDetail (
    oID   INT,
    pID   INT,
    odQTY INT,
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order`(oID),
    FOREIGN KEY (pID) REFERENCES Product(pID)
);

-- =====================================================
-- PHẦN 1: THÊM DỮ LIỆU
-- =====================================================
INSERT INTO Customer (cID, Name, cAge) VALUES
 (1, 'Minh Quan', 10),
 (2, 'Ngoc Oanh', 20),
 (3, 'Hong Ha', 50);

INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
 (1, 1, '2006-03-21', NULL),
 (2, 2, '2006-03-23', NULL),
 (3, 1, '2006-03-16', NULL);

INSERT INTO Product (pID, pName, pPrice) VALUES
 (1, 'May Giat', 3),
 (2, 'Tu Lanh',  5),
 (3, 'Dieu Hoa', 7),
 (4, 'Quat',     1),
 (5, 'Bep Dien', 2);

INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
 (1, 1, 3),
 (1, 3, 7),
 (1, 4, 2),
 (2, 1, 1),
 (3, 1, 8),
 (2, 5, 4),
 (2, 3, 3);

-- =====================================================
-- PHẦN 2: TRUY VẤN
-- =====================================================

-- 1. Hiển thị oID, oDate, oPrice của tất cả các hóa đơn trong bảng Order
SELECT oID, oDate, oTotalPrice AS oPrice
FROM `Order`;

-- 2. Danh sách khách hàng đã mua hàng và các sản phẩm họ đã mua
SELECT c.cID, c.Name, p.pName
FROM Customer c
JOIN `Order` o       ON c.cID = o.cID
JOIN OrderDetail od  ON o.oID = od.oID
JOIN Product p       ON od.pID = p.pID
ORDER BY c.cID, p.pName;

-- 3. Tên những khách hàng không mua bất kỳ sản phẩm nào
SELECT c.cID, c.Name
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;

-- 4. Mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
--    (giá hóa đơn = tổng odQTY * pPrice của các mặt hàng trong hóa đơn)
SELECT o.oID, o.oDate, SUM(od.odQTY * p.pPrice) AS oTotalPrice
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p      ON od.pID = p.pID
GROUP BY o.oID, o.oDate;
