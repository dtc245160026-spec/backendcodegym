# Phân tích EXPLAIN trước và sau tối ưu

| Chỉ số | Trước (Non-SARGable) | Sau (SARGable + Index) |
|---|---|---|
| `type` | `ALL` (quét toàn bảng) | `range` |
| `possible_keys` / `key` | `NULL` / `NULL` | `idx_type_date` |
| `rows` | ≈ toàn bộ bảng (~5.000.000) | chỉ các dòng DEPOSIT trong tháng 6/2026 |
| `Extra` | `Using where` | `Using index condition` |

*(Số liệu cụ thể lấy từ ảnh chụp EXPLAIN thực tế của bạn.)*

**Nguyên nhân:** `YEAR(created_at)` và `MONTH(created_at)` bọc hàm quanh cột nên MySQL phải tính hàm cho từng dòng, không thể dùng B-Tree Index để tìm kiếm. Kết quả là quét toàn bộ 5 triệu dòng.

**Giải pháp:** viết lại thành `created_at >= '2026-06-01' AND created_at < '2026-07-01'` và tạo Composite Index `(transaction_type, created_at)`. Cột `transaction_type` đứng trước vì là điều kiện `=`, cột `created_at` đứng sau vì là điều kiện range. MySQL nhảy thẳng tới vùng dữ liệu cần đọc, nên `rows` giảm từ hàng triệu xuống còn rất ít.
