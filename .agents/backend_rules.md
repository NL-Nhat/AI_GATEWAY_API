---
name: Backend Development Rules
description: Guidelines for developing the AI Gateway backend in Spring Boot
---

# Quy tắc Phát triển Backend (Spring Boot)

1. **Cấu trúc dự án:**
   - Mã nguồn Java phải được đặt trong `src/main/java/com/example/aigateway`.
   - Phân chia rõ ràng thành các package: `controller`, `service`, `repository`, `entity`, `dto`, `config`, `security`, `exception`.

2. **Tiêu chuẩn Code (Coding Standards):**
   - Viết code rõ ràng, có chú thích đầy đủ cho các hàm và logic phức tạp.
   - Luôn sử dụng DTO (Data Transfer Object) khi giao tiếp với Controller. Không trả trực tiếp Entity ra ngoài API.
   - Bắt và xử lý lỗi đồng nhất thông qua `@ControllerAdvice` trong package `exception`.

3. **Cơ sở dữ liệu (Database):**
   - Tên bảng và cột trong PostgreSQL phải dùng `snake_case`.
   - Entity phải map đúng với schema cung cấp trong `ai_gateway_db.sql`.

4. **Tích hợp API ngoài:**
   - Các logic gọi đến API của OpenAI, Gemini, Claude phải được đặt trong package `provider` và thiết kế linh hoạt (dùng Interface/Strategy) để dễ dàng thêm nhà cung cấp mới.
