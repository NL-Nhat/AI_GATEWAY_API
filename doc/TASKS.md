# Danh sách Công việc (AI Gateway Challenge)

Dưới đây là danh sách các tính năng cốt lõi cần thực hiện, chia theo từng danh mục của đề bài.

## 1. Authentication (Xác thực)
- [ ] Thiết lập hệ thống xác thực người dùng (JWT hoặc API Key).
- [ ] Bảo vệ các endpoint API chỉ cho phép người dùng hoặc client hợp lệ truy cập.

## 2. Database Integration (Tích hợp Cơ sở dữ liệu)
- [ ] Cấu hình kết nối PostgreSQL.
- [ ] Xây dựng các Entity JPA dựa trên `ai_gateway_db.sql`.
- [ ] Lưu trữ lịch sử trò chuyện.
- [ ] Lưu log các hoạt động và metric (latency, token usage).

## 3. LLM Provider Integration & Routing (Tích hợp & Định tuyến LLM)
- [ ] Xây dựng Router để điều phối request đến các nhà cung cấp khác nhau (OpenAI, Gemini, Claude).
- [ ] Chuẩn hóa dữ liệu đầu vào và đầu ra giữa các nhà cung cấp thành 1 định dạng API Gateway chung.

## 4. Structured Output (Dữ liệu đầu ra có cấu trúc)
- [ ] Đảm bảo gateway có khả năng trả về kết quả dưới định dạng JSON có cấu trúc (ví dụ: bọc câu trả lời trong các trường tiêu chuẩn).

## 5. Reliability Features (Tính ổn định & Đảm bảo)
- [ ] Triển khai cơ chế Retry (thử lại) khi gọi API bên thứ ba bị lỗi.
- [ ] Cấu hình Timeout (giới hạn thời gian) cho các request.
- [ ] Hỗ trợ cơ chế dự phòng (Fallback Models): tự động chuyển sang mô hình khác nếu mô hình hiện tại gặp sự cố.

## 6. Observability & Rate Limiting (Giám sát & Giới hạn tốc độ)
- [ ] Ghi nhận và theo dõi các metric: user, model, độ trễ, số lượng token, v.v.
- [ ] Triển khai tính năng Rate Limiting (giới hạn tốc độ gọi API).
- [ ] Tạo endpoint `/usage` để cung cấp thống kê sử dụng của người dùng.
