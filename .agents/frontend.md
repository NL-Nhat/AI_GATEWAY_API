# AI Gateway --- Frontend Development Guide

## 1. Mục tiêu

Frontend là web client cho AI Gateway, dùng để đăng ký, đăng nhập, chat
AI, quản lý conversation, xem lịch sử, xem usage/metrics và phục vụ
demo. Backend vẫn là nơi chịu trách nhiệm authentication, authorization,
rate limit, AI provider, database và reliability.

## 2. Stack

-   React + Vite
-   JavaScript hoặc TypeScript; nếu project đã bắt đầu bằng JavaScript
    thì giữ JavaScript.
-   React Router
-   Axios
-   CSS Modules hoặc CSS convention thống nhất
-   Recharts hoặc thư viện chart tương đương cho dashboard nếu cần

## 3. Kiến trúc

``` text
Pages -> Components -> Hooks -> API Services -> Axios Client -> Spring Boot
```

Không viết Axios request rải rác trong component.

## 4. Cấu trúc thư mục

``` text
frontend/
├── package.json
├── vite.config.js
├── .env.example
├── index.html
├── public/
└── src/
    ├── main.jsx
    ├── App.jsx
    ├── api/
    │   ├── axiosClient.js
    │   ├── authApi.js
    │   ├── aiApi.js
    │   ├── conversationApi.js
    │   └── usageApi.js
    ├── assets/
    ├── components/
    │   ├── common/
    │   ├── layout/
    │   ├── chat/
    │   └── dashboard/
    ├── pages/
    │   ├── Login.jsx
    │   ├── Register.jsx
    │   ├── Chat.jsx
    │   ├── Conversations.jsx
    │   ├── Dashboard.jsx
    │   └── NotFound.jsx
    ├── layouts/
    │   ├── AuthLayout.jsx
    │   └── MainLayout.jsx
    ├── hooks/
    │   ├── useAuth.js
    │   └── useChat.js
    ├── context/
    │   └── AuthContext.jsx
    ├── routes/
    │   ├── AppRoutes.jsx
    │   └── ProtectedRoute.jsx
    ├── utils/
    │   ├── formatDate.js
    │   ├── formatNumber.js
    │   └── storage.js
    ├── constants/
    └── styles/
        ├── global.css
        └── variables.css
```

## 5. Các trang

### Login

Email/password, validation, loading, API error, lưu auth state và
redirect.

### Register

Email/password/confirm password, validation và thông báo kết quả.

### Chat

``` text
+----------------+------------------------------+
| Conversations  | Chat                         |
|                | messages                     |
| New chat       |                              |
| Chat 1         |                              |
| Chat 2         | input              [Send]    |
+----------------+------------------------------+
```

Có create/select conversation, gửi message, loading, error, retry và
chọn provider/model nếu backend hỗ trợ.

### Dashboard

Hiển thị requests, total tokens, average latency, error rate,
provider/model usage, charts và recent requests nếu API cung cấp.

## 6. API client

Tạo một Axios instance ở `src/api/axiosClient.js` để thống nhất: - base
URL - Authorization header - timeout - response/error handling - 401
handling

Environment:

``` env
VITE_API_BASE_URL=http://localhost:8080
```

Không hard-code API URL ở từng component.

## 7. Authentication flow

``` text
Login -> Backend -> JWT -> AuthContext -> ProtectedRoute
```

Request:

``` http
Authorization: Bearer <JWT>
```

Public: `/login`, `/register`. Protected: `/chat`, `/conversations`,
`/dashboard`.

Khi backend trả 401: clear auth state và chuyển về login. Không tin
trạng thái authorization chỉ từ frontend.

## 8. State management

MVP có thể dùng Context + `useState`/`useReducer`. Chỉ thêm
Zustand/Redux Toolkit khi state thực sự cần. Auth state nên tập trung ở
`AuthContext`.

## 9. Chat state

Nên quản lý:

``` text
messages
conversationId
input
loading
error
selectedProvider
selectedModel
```

Flow:

``` text
input -> validate -> send -> loading -> response/error -> update messages
```

Không retry vô hạn ở frontend; retry provider là trách nhiệm chính của
backend.

## 10. Conversation

API:

``` http
GET    /api/v1/conversations
GET    /api/v1/conversations/{id}
DELETE /api/v1/conversations/{id}
```

Sidebar có New Conversation, danh sách conversation và delete. Không tải
toàn bộ message của mọi conversation nếu dữ liệu lớn.

## 11. Dashboard

Metric cards:

``` text
Requests | Tokens | Avg Latency | Error Rate
```

Charts có thể gồm requests/day, tokens/day, latency, success/error,
provider/model usage. Nếu backend đã trả metric chuẩn thì frontend không
tự tính lại theo cách khác.

## 12. Loading/Error/Empty states

Mọi API quan trọng phải có: - loading - success - error - empty

Các lỗi cần xử lý: 400, 401, 403, 404, 429, 500, 502, 504, network
error, timeout. Message phải thân thiện; không hiển thị stack trace.

Nếu backend trả `requestId`, có thể hiển thị mã này khi lỗi để hỗ trợ
tra log.

## 13. Structured output UI

Nếu `/api/v1/ai/analyze` trả JSON có schema cố định, frontend render
theo field, ví dụ Summary, Score, Strengths, Weaknesses,
Recommendations. Không phụ thuộc vào text format tự do của AI.

## 14. Component design

Ví dụ Chat:

``` text
ChatPage
 ├── ConversationSidebar
 │    ├── NewConversationButton
 │    └── ConversationItem
 └── ChatWindow
      ├── MessageList
      │    └── MessageBubble
      ├── TypingIndicator
      └── ChatInput
```

Dashboard:

``` text
DashboardPage
 ├── MetricCard
 ├── UsageChart
 ├── ProviderChart
 └── RecentRequests
```

Một component không nên trở thành file hàng trăm/hàng nghìn dòng.

## 15. CSS architecture

Không tạo hàng chục file CSS nhỏ không cần thiết. Có thể dùng:

``` text
styles/global.css
styles/variables.css
```

và CSS Modules hoặc naming convention cho component. Dùng CSS variables
cho màu, spacing, radius, typography. Không lặp lại cùng một giá trị ở
nhiều nơi.

## 16. Responsive

Tối thiểu hỗ trợ desktop/tablet/mobile. Desktop có sidebar + chat;
mobile có thể ẩn sidebar bằng button. Dashboard chuyển từ nhiều cột sang
một cột trên màn hình nhỏ.

## 17. Accessibility

-   Dùng semantic HTML.
-   Input có label.
-   Image có alt.
-   Có focus state.
-   Keyboard navigation cơ bản.
-   Contrast phù hợp.
-   Không chỉ dùng màu để biểu thị trạng thái.

## 18. Security

Không commit API key/JWT secret/provider secret. Không đặt secret trong
`VITE_*` vì biến Vite có thể xuất hiện trong frontend bundle. Frontend
chỉ là client; backend luôn kiểm tra authorization.

## 19. Environment

`.env.example`:

``` env
VITE_API_BASE_URL=http://localhost:8080
```

Local dùng `.env`, production dùng domain API thật. Không commit `.env`
chứa secret.

## 20. Coding standards

-   Component: PascalCase (`ChatWindow.jsx`).
-   Function/variable: camelCase.
-   Constant: UPPER_SNAKE_CASE.
-   Component một trách nhiệm chính.
-   API nằm trong service.
-   Logic dùng lại đưa vào hooks/utils.
-   Không trộn auth, API, formatting và toàn bộ UI vào một component.

## 21. API service rules

`authApi.js`: register/login. `aiApi.js`: chat/analyze.
`conversationApi.js`: list/detail/delete. `usageApi.js`: usage/metrics.

Component gọi service, không tự viết Axios request nếu service đã tồn
tại.

## 22. Routing

Ví dụ:

``` text
/
/login
/register
/chat
/chat/:conversationId
/conversations
/dashboard
```

Có thể redirect `/` về `/chat` nếu đã đăng nhập.

## 23. Backend contract

Frontend không đoán response. Ví dụ response chat:

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

Khi backend thay đổi contract: cập nhật API service -\> component -\>
test integration. Không dùng workaround để đoán response.

## 24. CORS

Development có thể là frontend `http://localhost:5173` và backend
`http://localhost:8080`. Backend phải cho phép origin phù hợp.
Production không nên mở CORS `*` tùy tiện; chỉ cho domain frontend thực
tế.

## 25. Performance

Không tối ưu quá sớm. Ưu tiên tránh request trùng, pagination khi cần,
debounce search, lazy loading khi cần và tránh render danh sách lớn
không cần thiết. Chat cần scroll tốt nhưng không cần kỹ thuật phức tạp
cho MVP.

## 26. Testing

Kiểm tra login success/fail, logout, expired token, chat
success/error/retry, empty message, conversation selection/delete,
dashboard data/error và responsive desktop/tablet/mobile.

## 27. Build

``` bash
npm run build
npm run preview
```

Không để warning/error quan trọng trước demo.

## 28. Docker

Nếu deploy frontend bằng Docker:

``` text
React build -> Nginx -> static files
```

Kiến trúc production:

``` text
Browser -> Nginx/Frontend -> Spring Boot -> PostgreSQL/Redis/LLM
```

## 29. Git workflow

Branch:

``` text
feature/frontend-auth
feature/frontend-chat
feature/frontend-dashboard
feature/frontend-responsive
fix/frontend-api-error
refactor/frontend-components
```

Commit:

``` text
feat: add login page
feat: add chat interface
feat: add conversation sidebar
feat: add usage dashboard
fix: handle 401 response
refactor: split chat components
style: improve dashboard layout
```

## 30. Quy trình phát triển

``` text
1. Setup React/Vite + env
2. Authentication
3. Chat UI + API integration
4. Conversation management
5. Dashboard
6. Loading/error/empty states
7. Responsive/accessibility
8. Integration test với backend
9. Production build
```

Mỗi feature nên đi theo:

``` text
Backend contract -> API service -> hook/state -> component -> page -> UI test
```

## 31. Definition of Done

-   [ ] React/Vite chạy ổn định
-   [ ] Environment config
-   [ ] Register/Login
-   [ ] Protected routes
-   [ ] JWT được gửi đúng
-   [ ] Chat
-   [ ] Conversation list/detail/delete
-   [ ] Loading/error/empty state
-   [ ] Retry action
-   [ ] Dashboard
-   [ ] Requests/tokens/latency/error rate
-   [ ] Provider/model usage nếu backend cung cấp
-   [ ] Responsive
-   [ ] API calls tập trung trong services
-   [ ] Không có secret
-   [ ] Production build thành công
-   [ ] Integration với backend thực tế thành công

## 32. Repository cuối cùng

``` text
ai-gateway/
├── backend/
├── frontend/
├── database/
├── docs/
├── docker-compose.yml
├── README.md
└── AI_WORKLOG.md
```

Backend và frontend dùng chung API contract, environment convention, Git
workflow và tài liệu README.
