# Consistency Report – HealthSync

Ba điểm vênh nghiêm trọng nhất giữa Activity Diagram và thiết kế cũ:

**1. Vòng đời lịch hẹn bị gói vào một cột Boolean.** Quy trình có 5 trạng thái (PENDING → CONFIRMED → CHECKED_IN → COMPLETED / CANCELLED), nhưng `is_active` chỉ biểu diễn được 2 giá trị. Hệ thống không phân biệt được lịch đã cọc, bệnh nhân đã đến, đã khám xong hay đã hủy. Khắc phục: thay bằng cột `status` kiểu ENUM, chặn giá trị sai ngay tại tầng dữ liệu.

**2. Thiếu hoàn toàn dữ liệu tài chính và lý do hủy.** Nghiệp vụ yêu cầu thu tiền cọc, ghi lý do hủy và trừ phí phạt vào cọc, nhưng bảng cũ không có `deposit_amount`, `penalty_fee`, `cancel_reason`. Kế toán không thể đối soát doanh thu cuối tháng và không có căn cứ khi bệnh nhân khiếu nại. Khắc phục: thêm các cột kiểu DECIMAL(12,2) (tránh sai số làm tròn của FLOAT/DOUBLE) cùng CHECK `penalty_fee <= deposit_amount`.

**3. Không có nơi lưu Đơn thuốc.** Activity Diagram quy định bác sĩ kê đơn sau khi COMPLETED, nhưng schema cũ không có bảng tương ứng. Khắc phục: tạo bảng `Prescriptions` với khóa ngoại về `Appointments` (UNIQUE cho quan hệ 1-1, ON DELETE RESTRICT) và trigger chỉ cho phép kê đơn khi lịch hẹn đã COMPLETED.

**Kết luận:** ERD phải phản ánh đầy đủ trạng thái, dữ liệu và quan hệ của Activity Diagram thì BA và Dev mới có chung một "hợp đồng" khi bàn giao.
