-- =====================================================
-- HEALTHSYNC - TÁI CẤU TRÚC CƠ SỞ DỮ LIỆU (MySQL 8.0.16+)
-- =====================================================
CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- ---------- 1. LEGACY ----------
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- ---------- 2. ALTER: SỬA BẢNG APPOINTMENTS ----------
ALTER TABLE Appointments
    DROP COLUMN is_active,
    MODIFY patient_id INT NOT NULL,
    MODIFY doctor_id INT NOT NULL,
    ADD COLUMN status ENUM('PENDING','CONFIRMED','CHECKED_IN','COMPLETED','CANCELLED')
        NOT NULL DEFAULT 'PENDING' AFTER appointment_date,
    ADD COLUMN deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER status,
    ADD COLUMN penalty_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER deposit_amount,
    ADD COLUMN cancel_reason VARCHAR(255) NULL AFTER penalty_fee,
    ADD CONSTRAINT chk_deposit_nonneg CHECK (deposit_amount >= 0),
    ADD CONSTRAINT chk_penalty_range  CHECK (penalty_fee >= 0 AND penalty_fee <= deposit_amount),
    ADD CONSTRAINT chk_cancel_reason  CHECK (status <> 'CANCELLED' OR cancel_reason IS NOT NULL);

-- ---------- 3. BẢNG PRESCRIPTIONS ----------
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- UNIQUE => quan hệ 1-1. Bỏ UNIQUE nếu muốn mở rộng 1-N.
    CONSTRAINT uq_prescription_appt UNIQUE (appointment_id),
    CONSTRAINT fk_prescription_appt FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ---------- 4. TRIGGER: chỉ kê đơn khi lịch hẹn COMPLETED ----------
DELIMITER //
CREATE TRIGGER trg_prescription_only_completed
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status FROM Appointments WHERE appointment_id = NEW.appointment_id;
    IF v_status IS NULL OR v_status <> 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Chi duoc ke don thuoc cho lich hen da COMPLETED';
    END IF;
END//
DELIMITER ;

-- ---------- 5. DỮ LIỆU MẪU ----------
INSERT INTO Patients (full_name, phone) VALUES
 ('Nguyen Van A', '0901234567'),
 ('Tran Thi B',   '0912345678');
INSERT INTO Doctors (full_name, specialty) VALUES
 ('BS. Le Minh C', 'Noi tong quat');

-- Kịch bản 1: thành công
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-10-20 09:00:00', 'PENDING', 500000);
SET @appt1 = LAST_INSERT_ID();

UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = @appt1;
UPDATE Appointments SET status = 'COMPLETED'  WHERE appointment_id = @appt1;

INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (@appt1, 'Paracetamol 500mg x 2 vien/ngay, 5 ngay; Vitamin C 1 vien/ngay');

-- Kịch bản 2: hủy và phạt
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 1, '2026-10-21 14:00:00', 'CONFIRMED', 300000);
SET @appt2 = LAST_INSERT_ID();

UPDATE Appointments
SET status = 'CANCELLED',
    cancel_reason = 'Ban viec dot xuat',
    penalty_fee = 150000
WHERE appointment_id = @appt2;

-- Kiểm tra trigger (bỏ comment để thử - phải báo lỗi vì lịch hẹn chưa COMPLETED):
-- INSERT INTO Prescriptions (appointment_id, medication_details) VALUES (@appt2, 'Thu nghiem');

-- ---------- 6. TRUY VẤN KIỂM CHỨNG ----------
-- Dòng tiền và trạng thái
SELECT a.appointment_id, p.full_name AS patient, a.status,
       a.deposit_amount, a.penalty_fee,
       (a.deposit_amount - a.penalty_fee) AS refund_amount,
       a.cancel_reason
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id;

-- Bệnh nhân đã khám xong + đơn thuốc
SELECT p.full_name AS patient, d.full_name AS doctor,
       a.appointment_date, pr.medication_details, pr.issued_date
FROM Appointments a
JOIN Patients p       ON p.patient_id = a.patient_id
JOIN Doctors d        ON d.doctor_id = a.doctor_id
JOIN Prescriptions pr ON pr.appointment_id = a.appointment_id
WHERE a.status = 'COMPLETED';
