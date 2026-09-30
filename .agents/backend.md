# AI Gateway --- Backend Development Guide

## 1. Mục tiêu

Backend là **AI Gateway API** trung tâm, đứng giữa frontend/client và
các LLM provider. Mục tiêu là cung cấp authentication, AI chat,
conversation storage, structured output, model routing, retry, timeout,
fallback, rate limiting, logging và usage metrics.

``` text
React / Postman / Client
          |
          v
   Spring Boot API
          |
  +-------+-------+
  | Auth          | Validation
  | Rate Limit    | Logging
  +-------+-------+
          |
     Model Router
      /    |    \\
 OpenAI Gemini Claude
          |
   PostgreSQL + Redis
```

## 2. Stack

-   Java 21
-   Spring Boot + Maven
-   Spring Web, Validation, Data JPA
-   PostgreSQL
-   Redis
-   Spring Security + JWT + BCrypt
-   OpenAPI/Swagger
-   JUnit/Mockito
-   Docker/Docker Compose
-   LLM providers: OpenAI/Gemini/Claude theo provider abstraction

## 3. Kiến trúc

Áp dụng layered architecture:

``` text
Controller -> Service -> Repository
                 |
                 +-> LlmProvider -> External LLM
                 +-> Redis
```

Controller chỉ nhận request, validate và gọi service. Business logic nằm
ở service. Persistence nằm ở repository. Không gọi repository trực tiếp
từ controller.

## 4. Cấu trúc thư mục

``` text
backend/
├── pom.xml
├── Dockerfile
├── .env.example
├── src/main/java/com/example/aigateway/
│   ├── AiGatewayApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── RedisConfig.java
│   │   ├── OpenApiConfig.java
│   │   └── WebConfig.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   ├── AiController.java
│   │   ├── ConversationController.java
│   │   └── UsageController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   ├── AiService.java
│   │   ├── ConversationService.java
│   │   ├── UsageService.java
│   │   ├── RateLimitService.java
│   │   └── ModelRouterService.java
│   ├── provider/
│   │   ├── LlmProvider.java
│   │   ├── OpenAiProvider.java
│   │   ├── GeminiProvider.java
│   │   └── ClaudeProvider.java
│   ├── repository/
│   ├── entity/
│   ├── dto/
│   │   ├── auth/
│   │   ├── ai/
│   │   ├── conversation/
│   │   └── usage/
│   ├── security/
│   │   ├── JwtService.java
│   │   ├── JwtAuthenticationFilter.java
│   │   └── CustomUserDetailsService.java
│   ├── exception/
│   ├── mapper/
│   └── util/
│
│   ├── resources/
│   │   ├── application.yml
│   │   └── db/migration/
│   │       └── V1__init.sql
│   └── test/
└── README.md
```

## 5. Database

Các bảng chính: - `users`: tài khoản, role, trạng thái. - `api_keys`:
API key cho client/app nếu sử dụng. - `conversations`: phiên hội thoại
của user. - `messages`: SYSTEM/USER/ASSISTANT messages. - `ai_requests`:
log từng lần gọi LLM: user, provider, model, tokens, latency, status,
retry, fallback. - `usage_daily`: dữ liệu tổng hợp theo ngày cho
dashboard.

Quan hệ:

``` text
users 1---N api_keys
users 1---N conversations
users 1---N ai_requests
users 1---N usage_daily
conversations 1---N messages
conversations 1---N ai_requests
```

Dùng Flyway cho migration. Production nên dùng
`spring.jpa.hibernate.ddl-auto=validate`, không dùng `create`/`update`.

## 6. API contract

### Auth

``` http
POST /api/v1/auth/register
POST /api/v1/auth/login
```

### AI

``` http
POST /api/v1/ai/chat
POST /api/v1/ai/analyze
```

### Conversations

``` http
GET    /api/v1/conversations
GET    /api/v1/conversations/{id}
DELETE /api/v1/conversations/{id}
```

### Usage

``` http
GET /api/v1/usage
```

## 7. DTO

Không trả Entity trực tiếp ra API. Dùng request/response DTO.

Ví dụ `ChatRequest`:

``` json
{
  "conversationId": 1,
  "message": "Explain Spring Boot",
  "provider": "GEMINI",
  "model": "..."
}
```

`ChatResponse` nên có:

``` json
{
  "requestId": "...",
  "conversationId": 1,
  "provider": "GEMINI",
  "model": "...",
  "message": "...",
  "usage": {"inputTokens": 100, "outputTokens": 200},
  "latencyMs": 1200
}
```

## 8. LLM Provider abstraction

Tạo interface:

``` java
public interface LlmProvider {
    String getProviderName();
    LlmResponse chat(LlmRequest request);
}
```

`AiService` không chứa code riêng của OpenAI/Gemini/Claude. Model router
chọn provider rồi provider tự tạo request, gọi API, parse response và
lấy usage.

## 9. Luồng Chat

``` text
Request
 -> JWT authentication
 -> validation
 -> ownership check
 -> Redis rate limit
 -> conversation load/create
 -> model router
 -> LLM provider
 -> retry/timeout
 -> fallback nếu cần
 -> save ai_request
 -> save messages
 -> update usage_daily
 -> response
```

Không giữ transaction DB mở trong toàn bộ thời gian chờ LLM nếu không
cần thiết.

## 10. Authentication/Security

-   Register: hash password bằng BCrypt trước khi lưu.
-   Login: kiểm tra password và phát JWT.
-   Request dùng `Authorization: Bearer <JWT>`.
-   User chỉ truy cập conversation/request của chính mình.
-   Admin chỉ được endpoint admin nếu được cấp quyền.
-   Không commit JWT secret, LLM API key, database password.
-   Secret lấy từ environment variables.

Ví dụ:

``` text
DATABASE_URL
DATABASE_USERNAME
DATABASE_PASSWORD
JWT_SECRET
OPENAI_API_KEY
GEMINI_API_KEY
CLAUDE_API_KEY
REDIS_URL
```

## 11. Validation

Dùng Bean Validation như `@NotBlank`, `@Size`. Kiểm tra provider/model
hợp lệ và conversation thuộc user hiện tại. Không tin authorization hoặc
dữ liệu do frontend gửi.

## 12. Retry / Timeout / Fallback

Timeout phải có giới hạn, ví dụ 30 giây tùy provider. Retry tối đa
khoảng 2 lần cho lỗi tạm thời như timeout, 429 và một số 5xx. Không
retry validation/auth lỗi.

``` text
Provider A -> retry -> failure -> Provider B
```

Ghi `retry_count` và `fallback_used` vào `ai_requests`.

## 13. Rate limiting

Dùng Redis. MVP có thể giới hạn khoảng 100 requests/phút/user. Khi vượt
giới hạn trả `429 Too Many Requests`. Rate limit phải được enforce ở
backend.

## 14. Error handling

Dùng `GlobalExceptionHandler`. Response thống nhất:

``` json
{
  "timestamp": "...",
  "status": 400,
  "code": "VALIDATION_ERROR",
  "message": "Invalid request",
  "path": "/api/v1/ai/chat",
  "requestId": "..."
}
```

Các nhóm chính: `400`, `401`, `403`, `404`, `409`, `429`, `500`, `502`,
`504`. Không trả stack trace cho client.

## 15. Logging/Observability

Mỗi AI request nên có requestId, userId, provider, model, latency,
status, retryCount, fallbackUsed. Không log password, JWT, API key hoặc
secret. Log phải đủ để truy vết lỗi.

## 16. Usage metrics

``` text
total_tokens = input_tokens + output_tokens
average_latency = total_latency_ms / total_requests
error_rate = failed_requests / total_requests * 100
```

`usage_daily` dùng để phục vụ dashboard nhanh hơn thay vì tính toàn bộ
lịch sử mỗi lần.

## 17. Structured output

`POST /api/v1/ai/analyze` phải trả JSON có schema ổn định khi nghiệp vụ
yêu cầu. Ví dụ:

``` json
{
  "summary": "...",
  "score": 85,
  "strengths": [],
  "weaknesses": [],
  "recommendations": []
}
```

## 18. Swagger/Postman

Swagger phải mô tả request, response, authentication và status code.
Postman collection nên có Auth, AI, Conversations, Usage; environment có
`baseUrl`, `token`, `conversationId`.

## 19. Testing

Unit test tối thiểu cho AuthService, AiService, ModelRouterService,
UsageService, RateLimitService. Integration test cho authentication,
chat, conversations, usage. Test cả timeout, 429, 5xx, retry, fallback
và rate limit.

## 20. Coding standards

-   Class/interface: PascalCase.
-   Method/variable: camelCase.
-   Constant: UPPER_SNAKE_CASE.
-   Controller mỏng.
-   Service chứa business logic.
-   Repository chỉ persistence/query.
-   Entity không dùng làm API DTO.
-   Class có một trách nhiệm chính.
-   Không hard-code secret.
-   Không catch `Exception` rồi bỏ qua.
-   Không copy logic provider vào nhiều service.
-   Ưu tiên readable, maintainable, testable, low coupling.

## 21. Git workflow

Branch:

``` text
main
feature/auth
feature/ai-chat
feature/usage
feature/rate-limit
feature/fallback
feature/swagger
refactor/project-structure
fix/provider-timeout
```

Commit:

``` text
feat: add JWT authentication
feat: add AI chat endpoint
fix: handle provider timeout
refactor: restructure backend
test: add AI service tests
docs: update API documentation
```

Không commit trực tiếp feature vào `main` nếu workflow nhóm yêu cầu
review.

## 22. Docker/Deployment

Local có thể dùng:

``` text
docker compose
├── backend
├── postgres
└── redis
```

Backend phải đọc environment variables. Commit `.env.example`, không
commit `.env` có secret.

## 23. Definition of Done

-   [ ] Spring Boot chạy ổn định
-   [ ] PostgreSQL/Redis kết nối
-   [ ] Register/Login/JWT/Authorization
-   [ ] AI Chat
-   [ ] Conversation/Message storage
-   [ ] `ai_requests` lưu từng AI call
-   [ ] Token/latency/status được ghi nhận
-   [ ] Retry/timeout
-   [ ] Fallback nếu triển khai
-   [ ] Rate limit
-   [ ] Structured output
-   [ ] Usage API
-   [ ] Global error handling
-   [ ] Swagger
-   [ ] Postman
-   [ ] Docker
-   [ ] Tests
-   [ ] README + AI_WORKLOG
-   [ ] Không có secret trong Git
