# Agent Rules for AI Gateway Project

Dựa trên tài liệu hệ thống, Agent cần tuân thủ các quy tắc sau khi sinh code và thiết kế cho dự án Spring Boot này:

## 1. Phạm vi dự án (Scope & Tech Stack)
- **Công nghệ:** Java Spring Boot, PostgreSQL, Redis, JWT, Swagger/OpenAPI.
- **Tư duy thiết kế:** Làm "ít chức năng nhưng hoàn chỉnh". Không over-engineer (Không dùng microservices, Kafka, hay RAG phức tạp).
- **Trọng tâm:** Code chạy được thực tế, xử lý lỗi tốt, lưu metric, và kiến trúc sạch.

## 2. Kiến trúc & Design Patterns
- **LLM Provider:** BẮT BUỘC dùng Interface `LlmProvider` có hàm `chat(LlmRequest)` và `getProviderName()`. Không viết if-else lồng ghép (`if(model.equals("openai"))`) rải rác.
- **Multi-model Routing:** Dùng logic router (VD: `ModelRouter`) để tự động chọn provider dựa trên giá trị `model` ("auto", "gemini", "openai").
- **Reliability:**
  - **Retry:** Dùng exponential backoff (VD: Retry tối đa 2 lần, lần 1 cách 500ms, lần 2 cách 1000ms).
  - **Timeout:** Giới hạn thời gian gọi LLM, không để request treo vô thời hạn (VD: 30s timeout).
  - **Fallback:** Tự động chuyển qua provider dự phòng nếu provider chính lỗi.
- **Rate Limiting:** Sử dụng Redis để giới hạn tốc độ (VD: 100 requests/phút/user).

## 3. Quy chuẩn Log & Xử lý lỗi (Error Handling)
- Dùng `@RestControllerAdvice` trong `GlobalExceptionHandler`.
- Trả về JSON lỗi thống nhất theo format: `{"timestamp", "status", "error", "message", "requestId"}`.
- Khi log request/response/lỗi AI: Log `requestId`, `latency`, `inputTokens`, `outputTokens`, `status`. Tuyệt đối không log API Key/JWT.

## 4. Cấu trúc dữ liệu & API
- Bảng DB sử dụng chuẩn quy ước `snake_case` cho Postgres (users, conversations, messages, ai_requests).
- Tách biệt rõ DTO và Entity. Các class DTO nên được tổ chức cẩn thận.
- Endpoint API chuẩn RESTful, có tiền tố `/api/v1/`.
