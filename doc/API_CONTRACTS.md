# Các API chính & Ràng buộc kiểu dữ liệu

## 1. Authentication (`POST /api/v1/auth/login`)
Response chuẩn:
```json
{
  "accessToken": "...",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

## 2. AI Chat (`POST /api/v1/ai/chat`)
Request mẫu:
```json
{
  "message": "Explain microservices in simple terms",
  "model": "auto",
  "conversationId": null
}
```
Response mẫu:
```json
{
  "conversationId": 12,
  "model": "gemini-2.5-flash",
  "content": "Microservices are...",
  "usage": {
    "inputTokens": 25,
    "outputTokens": 80
  },
  "latencyMs": 1230,
  "fallbackUsed": false
}
```

## 3. Usage Data (`GET /api/v1/usage`)
Hỗ trợ tham số (Query Params): `?from=2026-09-01&to=2026-09-30`
Response mẫu:
```json
{
  "requests": 124,
  "successfulRequests": 121,
  "failedRequests": 3,
  "totalInputTokens": 18320,
  "totalOutputTokens": 30000,
  "totalTokens": 48320,
  "averageLatencyMs": 1230,
  "errorRate": 0.024
}
```
**Công thức:**
- `totalTokens = inputTokens + outputTokens`
- `averageLatency = tổng latency / số request`
- `errorRate = failedRequests / totalRequests`

## 4. AI Structured Output (`POST /api/v1/ai/analyze`)
Request mẫu:
```json
{
  "text": "Java Spring Boot developer with 2 years experience..."
}
```
Response mẫu (Trả về JSON có cấu trúc):
```json
{
  "summary": "Java backend developer",
  "skills": [
    "Java",
    "Spring Boot",
    "PostgreSQL"
  ],
  "experienceYears": 2,
  "seniority": "Junior"
}
```

## 5. Ràng buộc xử lý lỗi (Error Response Format)
Bất kể lỗi gì (400, 401, 404, 429, 500, ...), API luôn phải trả về cấu trúc thống nhất:
```json
{
  "timestamp": "2026-09-24T12:00:00",
  "status": 429,
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests",
  "requestId": "abc123"
}
```
