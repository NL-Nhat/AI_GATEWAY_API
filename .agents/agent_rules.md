# AI AGENT PROJECT RULES --- AI GATEWAY

## 0. Mục đích

Đây là file quy tắc vận hành bắt buộc dành cho AI Agent khi làm việc
trong repository AI Gateway.

AI Agent phải đọc file này trước mỗi yêu cầu thay đổi code.

Mục tiêu:

-   hiểu yêu cầu trước khi sửa code
-   suy nghĩ và phân tích trước khi hành động
-   tạo kế hoạch cụ thể trước khi code
-   không tự ý thay đổi kiến trúc
-   không phá vỡ code đang hoạt động
-   tuân thủ chuẩn Backend/Frontend
-   kiểm tra ảnh hưởng liên quan
-   test sau khi thay đổi
-   cập nhật tài liệu
-   tự động ghi tóm tắt công việc vào `AI_WORKLOG.md`

------------------------------------------------------------------------

# 1. Quy tắc ưu tiên

Khi có nhiều nguồn yêu cầu, ưu tiên theo thứ tự:

``` text
1. Yêu cầu trực tiếp của người dùng
2. File AI_AGENT_RULES.md này
3. backend.md / frontend.md
4. README.md và tài liệu dự án
5. Kiến trúc/code hiện tại
6. Suy luận của AI Agent
```

Nếu có mâu thuẫn giữa yêu cầu người dùng và tài liệu cũ:

-   ưu tiên yêu cầu mới của người dùng
-   không âm thầm thay đổi phạm vi
-   ghi nhận thay đổi vào `AI_WORKLOG.md`

Không tự ý mở rộng scope.

------------------------------------------------------------------------

# 2. BẮT BUỘC ĐỌC FILE TRƯỚC KHI LÀM

Trước mỗi yêu cầu code, phải kiểm tra:

``` text
AI_AGENT_RULES.md
backend.md nếu liên quan Backend
frontend.md nếu liên quan Frontend
README.md nếu cần hiểu project
AI_WORKLOG.md nếu cần biết lịch sử công việc
```

Nếu yêu cầu liên quan cả FE và BE:

``` text
Đọc AI_AGENT_RULES.md
        ↓
Đọc backend.md
        ↓
Đọc frontend.md
        ↓
Kiểm tra API contract
        ↓
Lập kế hoạch
```

Không bắt đầu sửa code trước khi hoàn thành bước phân tích.

------------------------------------------------------------------------

# 3. QUY TRÌNH BẮT BUỘC CHO MỌI YÊU CẦU

Mọi task phải đi qua quy trình:

``` text
RECEIVE
   ↓
UNDERSTAND
   ↓
INSPECT
   ↓
ANALYZE
   ↓
PLAN
   ↓
IMPLEMENT
   ↓
VERIFY
   ↓
DOCUMENT
   ↓
WORKLOG
   ↓
REPORT
```

------------------------------------------------------------------------

# 4. BƯỚC 1 --- HIỂU YÊU CẦU

Trước khi code, xác định:

``` text
Task là gì?
Tại sao cần làm?
Phần nào bị ảnh hưởng?
Input là gì?
Output mong muốn là gì?
Có API/database/UI nào liên quan?
Có requirement nào không được thay đổi?
```

Nếu yêu cầu chưa đủ rõ để triển khai an toàn:

-   hỏi người dùng
-   không tự đoán những phần quan trọng

Nếu có thể suy luận an toàn từ code hiện tại:

-   tiếp tục
-   ghi rõ assumption trong kế hoạch

------------------------------------------------------------------------

# 5. BƯỚC 2 --- KIỂM TRA CODE HIỆN TẠI

Không sửa ngay file được nhắc đến.

Phải kiểm tra dependency và code liên quan.

Ví dụ Backend:

``` text
Controller
→ Service
→ Repository
→ Entity
→ DTO
→ Security
→ Database
```

Frontend:

``` text
Page
→ Component
→ Hook
→ API service
→ Axios
→ Backend endpoint
```

Kiểm tra:

-   file hiện tại
-   class/function liên quan
-   API contract
-   database schema
-   dependency
-   configuration
-   test hiện tại
-   code gọi vào phần sắp sửa
-   code được phần sắp sửa gọi

Mục tiêu là tránh sửa một file rồi làm hỏng nơi khác.

------------------------------------------------------------------------

# 6. BƯỚC 3 --- PHÂN TÍCH ẢNH HƯỞNG

Trước khi implementation, xác định:

``` text
Files cần sửa
Files cần tạo
Files có thể bị ảnh hưởng
Database có thay đổi không?
API contract có thay đổi không?
Frontend có thay đổi không?
Backend có thay đổi không?
Test nào cần thêm/sửa?
Documentation nào cần cập nhật?
```

Phải ưu tiên thay đổi nhỏ nhất đáp ứng yêu cầu.

Không refactor diện rộng nếu task không yêu cầu.

------------------------------------------------------------------------

# 7. BƯỚC 4 --- LẬP KẾ HOẠCH TRƯỚC KHI CODE

Mỗi task phải có kế hoạch.

Format:

``` text
PLAN

1. Mục tiêu:
   ...

2. Phân tích hiện trạng:
   ...

3. Files sẽ tạo:
   - ...

4. Files sẽ sửa:
   - ...

5. Database/API thay đổi:
   - ...

6. Implementation:
   - Step 1
   - Step 2
   - Step 3

7. Testing:
   - ...

8. Documentation:
   - ...

9. Rủi ro:
   - ...
```

Nếu task lớn, chia thành các phase:

``` text
Phase 1 — Backend
Phase 2 — Database
Phase 3 — Frontend
Phase 4 — Integration
Phase 5 — Testing
```

Không bắt đầu implementation khi chưa xác định được phạm vi.

------------------------------------------------------------------------

# 8. KHÔNG OVERENGINEERING

Ưu tiên:

``` text
Simple
Clear
Maintainable
Testable
Extensible
```

Không tự ý thêm:

-   microservices
-   Kafka
-   Kubernetes
-   event sourcing
-   CQRS
-   RAG
-   vector database
-   design pattern phức tạp

nếu task không yêu cầu.

AI Gateway hiện tại ưu tiên prototype hoàn chỉnh, dễ giải thích và chạy
được.

------------------------------------------------------------------------

# 9. QUY TẮC BACKEND

Backend phải tuân thủ `backend.md`.

Kiến trúc:

``` text
Controller
    ↓
Service
    ↓
Repository
    ↓
Database
```

AI integration:

``` text
AiService
    ↓
ModelRouter
    ↓
LlmProvider
    ↓
Provider implementation
```

Không:

-   business logic trong Controller
-   gọi Repository trực tiếp từ Controller
-   gọi LLM trực tiếp trong Controller
-   trả Entity trực tiếp cho API
-   hard-code API key
-   hard-code JWT secret
-   log password/token/API key
-   bỏ qua exception
-   dùng `ddl-auto=update` cho production

------------------------------------------------------------------------

# 10. QUY TẮC FRONTEND

Frontend phải tuân thủ `frontend.md`.

Kiến trúc:

``` text
Page
 ↓
Component
 ↓
Hook
 ↓
API Service
 ↓
Axios Client
 ↓
Backend
```

Không:

-   gọi Axios rải rác trong component
-   hard-code API URL trong nhiều file
-   đưa secret vào VITE environment
-   tạo component quá lớn
-   để một page xử lý toàn bộ business logic
-   tự suy đoán API response

------------------------------------------------------------------------

# 11. API CONTRACT

Frontend và Backend phải thống nhất contract.

Trước khi thay đổi endpoint:

``` text
Check backend endpoint
        ↓
Check DTO request
        ↓
Check DTO response
        ↓
Check frontend API service
        ↓
Check component đang sử dụng
```

Nếu thay đổi breaking change:

-   xác định toàn bộ consumer
-   cập nhật Backend
-   cập nhật Frontend
-   cập nhật Swagger
-   cập nhật Postman
-   test integration
-   ghi vào worklog

Không thay đổi API response chỉ để code frontend dễ hơn nếu không có lý
do.

------------------------------------------------------------------------

# 12. DATABASE RULES

PostgreSQL là database chính.

Database thay đổi phải được xem xét:

``` text
Schema
→ Entity
→ Repository
→ Service
→ API
→ Frontend
```

Nếu dùng Flyway:

``` text
V1__init.sql
V2__...
V3__...
```

Không sửa migration đã chạy trên môi trường dùng chung.

Không xóa dữ liệu thật để giải quyết lỗi nếu chưa có yêu cầu rõ ràng.

------------------------------------------------------------------------

# 13. SECURITY RULES

Tuyệt đối không commit:

``` text
API keys
JWT secret
database password
Redis password
private credentials
.env thật
```

Chỉ commit:

``` text
.env.example
```

Không log:

``` text
Authorization header
JWT
password
API key
secret
```

Mọi dữ liệu thuộc user phải kiểm tra ownership ở backend.

Ví dụ:

``` text
GET /conversations/{id}
```

phải kiểm tra conversation thuộc authenticated user.

Frontend không được xem là lớp bảo mật.

------------------------------------------------------------------------

# 14. ERROR HANDLING

Mọi API phải có error handling rõ ràng.

Backend dùng GlobalExceptionHandler.

Frontend phải xử lý:

``` text
400
401
403
404
409
429
500
502
504
network error
timeout
```

Không che giấu lỗi.

Không trả stack trace cho user.

Nếu backend có `requestId`, frontend nên giữ requestId trong thông tin
lỗi để hỗ trợ debugging.

------------------------------------------------------------------------

# 15. AI PROVIDER RULES

AI Gateway phải giữ abstraction:

``` text
LlmProvider
```

Không để business logic phụ thuộc trực tiếp vào:

``` text
OpenAI SDK
Gemini SDK
Claude SDK
```

Provider implementation chịu trách nhiệm:

-   request
-   response parsing
-   token usage
-   provider-specific error

Service chịu trách nhiệm:

-   business flow
-   routing
-   retry
-   fallback
-   persistence

------------------------------------------------------------------------

# 16. RELIABILITY RULES

AI request phải có:

``` text
timeout
retry
error handling
logging
metrics
```

Retry không được vô hạn.

Không retry lỗi validation.

Fallback chỉ thực hiện khi phù hợp.

Mỗi request phải ghi nhận:

``` text
requestId
userId
provider
model
latency
tokens
status
retryCount
fallbackUsed
```

------------------------------------------------------------------------

# 17. RATE LIMITING

Rate limit được enforce ở Backend.

Redis là nơi lưu state nếu sử dụng distributed rate limiting.

Frontend không được xem việc disable nút Send là rate limiting.

HTTP:

``` text
429 Too Many Requests
```

phải được xử lý đúng ở frontend.

------------------------------------------------------------------------

# 18. TEST RULES

Sau mỗi thay đổi phải xác định test cần chạy.

### Backend

``` text
Unit test
Integration test
API test
```

### Frontend

``` text
Component behavior
API integration
Loading
Error
Authentication
Responsive
```

Không tuyên bố task hoàn thành nếu chưa kiểm tra phần bị ảnh hưởng.

Nếu không thể chạy test:

-   ghi rõ lý do
-   không giả vờ test thành công
-   ghi vào `AI_WORKLOG.md`

------------------------------------------------------------------------

# 19. VERIFICATION CHECKLIST

Sau implementation:

``` text
[ ] Code compile/build
[ ] Test liên quan pass
[ ] API hoạt động
[ ] Database hoạt động
[ ] Frontend hoạt động nếu liên quan
[ ] Không có secret
[ ] Không có lỗi rõ ràng
[ ] Không phá API hiện tại
[ ] Documentation cập nhật
[ ] AI_WORKLOG cập nhật
```

------------------------------------------------------------------------

# 20. KHÔNG ĐƯỢC GIẢ VỜ THÀNH CÔNG

AI Agent phải trung thực.

Không nói:

``` text
Đã test thành công
```

nếu chưa thực sự chạy test.

Không nói:

``` text
API hoạt động
```

nếu chưa kiểm tra.

Không nói:

``` text
Deploy thành công
```

nếu chưa xác minh.

Nếu có giới hạn:

``` text
Chưa kiểm tra vì ...
```

------------------------------------------------------------------------

# 21. QUẢN LÝ FILE

Trước khi tạo file mới, kiểm tra:

``` text
File tương tự đã tồn tại chưa?
Có thể sửa file hiện tại không?
File mới có thực sự cần không?
```

Không tạo duplicate:

``` text
UserService2
ChatServiceNew
ApiClientFinal
```

Tên file phải phản ánh trách nhiệm.

------------------------------------------------------------------------

# 22. REFACTOR

Chỉ refactor khi:

-   task yêu cầu
-   code hiện tại cản trở implementation
-   refactor cần thiết để sửa bug
-   refactor giúp giảm coupling rõ ràng

Khi refactor:

``` text
Before
→ Change
→ Tests
→ Verify
```

Không kết hợp một feature lớn với một đợt refactor không liên quan nếu
không cần thiết.

------------------------------------------------------------------------

# 23. GIT RULES

Branch:

``` text
feature/...
fix/...
refactor/...
docs/...
test/...
```

Ví dụ:

``` text
feature/ai-chat
feature/frontend-chat
fix/jwt-validation
refactor/project-structure
docs/update-readme
```

Commit:

``` text
feat: ...
fix: ...
refactor: ...
docs: ...
test: ...
style: ...
chore: ...
```

Không commit:

``` text
update
fix
abc
test
final
final2
```

Không force push vào branch chung nếu không có yêu cầu.

------------------------------------------------------------------------

# 24. KHÔNG TỰ Ý XÓA / RESET

Không tự ý chạy:

``` bash
git reset --hard
git clean -fd
git push --force
```

Không xóa database/table/data để "fix" lỗi nếu chưa được yêu cầu.

Nếu thao tác có nguy cơ mất dữ liệu:

-   dừng
-   thông báo
-   yêu cầu xác nhận

------------------------------------------------------------------------

# 25. DOCUMENTATION RULES

Khi thay đổi behavior đáng kể, cập nhật tài liệu liên quan:

``` text
README.md
Swagger
Postman
database.md
architecture.md
AI_WORKLOG.md
```

Không để tài liệu mô tả khác với code thực tế.

------------------------------------------------------------------------

# 26. AI_WORKLOG.md --- BẮT BUỘC CẬP NHẬT

Sau mỗi task đã hoàn thành, AI Agent phải tự động cập nhật:

``` text
AI_WORKLOG.md
```

Không cần chờ người dùng yêu cầu.

Mục đích:

-   ghi lại AI đã làm gì
-   ghi lại cách AI hỗ trợ
-   ghi lại vấn đề
-   ghi lại lỗi AI từng tạo ra
-   ghi lại cách đã sửa
-   giúp chứng minh quá trình sử dụng AI trong challenge

------------------------------------------------------------------------

# 27. FORMAT AI_WORKLOG.md

Nếu chưa tồn tại, tạo file:

``` text
AI_WORKLOG.md
```

Format:

``` markdown
# AI WORKLOG

## [YYYY-MM-DD] — [Task name]

### 1. Mục tiêu
- ...

### 2. Công việc đã thực hiện
- ...
- ...

### 3. Files đã tạo
- `...`

### 4. Files đã sửa
- `...`

### 5. Thay đổi chính
- ...

### 6. AI đã hỗ trợ
- Phân tích yêu cầu
- Đề xuất kiến trúc
- Sinh code
- Debug
- Refactor
- Viết test
- Documentation

### 7. Vấn đề / lỗi phát sinh
- ...

### 8. AI output chưa chính xác
- ...

### 9. Cách kiểm tra và sửa
- ...

### 10. Verification
- Build: PASS/FAIL/NOT RUN
- Tests: PASS/FAIL/NOT RUN
- API test: PASS/FAIL/NOT RUN
- Frontend test: PASS/FAIL/NOT RUN

### 11. Kết quả
- ...

### 12. Việc còn lại
- ...
```

------------------------------------------------------------------------

# 28. CÁCH GHI WORKLOG

Worklog phải ngắn gọn nhưng đủ thông tin.

Không copy toàn bộ conversation.

Không ghi:

``` text
AI đã làm rất nhiều thứ...
```

Phải ghi cụ thể:

``` text
- Added JWT authentication.
- Added JwtAuthenticationFilter.
- Added login/register endpoints.
- Added authentication tests.
- Fixed token expiration validation.
```

Nếu AI tạo code sai:

``` text
AI output:
Repository query used an incorrect field name.

Problem:
Application failed during startup.

Fix:
Changed repository method to match entity property.
```

Điều này rất quan trọng cho phần AI usage của challenge.

------------------------------------------------------------------------

# 29. WORKLOG KHÔNG ĐƯỢC BỊ GHI SAI

Chỉ ghi những gì thực sự đã làm.

Không ghi:

``` text
Tests passed
```

nếu chưa chạy.

Không ghi:

``` text
Deployment successful
```

nếu chưa kiểm tra.

Không ghi lỗi AI nếu thực tế không có.

------------------------------------------------------------------------

# 30. KHI NÀO CẬP NHẬT WORKLOG

Cập nhật sau:

``` text
Feature hoàn thành
Bug được sửa
Refactor hoàn thành
Database migration
API thay đổi
Frontend integration
Deployment
Testing milestone
Documentation milestone
```

Nếu task nhỏ, có thể gộp nhiều thay đổi liên quan trong một entry.

------------------------------------------------------------------------

# 31. AI AGENT RESPONSE FORMAT

Trước khi thực hiện task lớn, trình bày ngắn:

``` text
PLAN

Mục tiêu:
...

Phạm vi:
...

Files dự kiến:
...

Các bước:
1. ...
2. ...
3. ...

Verification:
...
```

Sau khi hoàn thành:

``` text
RESULT

Đã thực hiện:
- ...

Files:
- ...

Verification:
- ...

Worklog:
- Đã cập nhật AI_WORKLOG.md

Còn lại:
- ...
```

Không cần in toàn bộ chain-of-thought.

Chỉ cung cấp summary và kế hoạch có thể kiểm tra.

------------------------------------------------------------------------

# 32. KHI TASK NHỎ

Không cần tạo kế hoạch dài cho các thay đổi rất nhỏ.

Ví dụ:

``` text
Đổi tên biến
Sửa typo
Sửa một CSS property
```

Có thể:

``` text
Mục tiêu → sửa → kiểm tra → worklog
```

Nhưng vẫn phải tuân thủ các rule an toàn.

------------------------------------------------------------------------

# 33. KHI TASK LỚN

Nếu task lớn:

``` text
1. Phân tích
2. Chia phase
3. Lập dependency
4. Implementation từng phase
5. Test từng phase
6. Integration test
7. Documentation
8. Worklog
```

Không sửa 20 file cùng lúc mà không kiểm tra kết quả trung gian.

------------------------------------------------------------------------

# 34. KHI GẶP LỖI

Quy trình:

``` text
Read error
    ↓
Identify root cause
    ↓
Inspect related code
    ↓
Form hypothesis
    ↓
Make smallest safe fix
    ↓
Run verification
    ↓
Record result
```

Không sửa ngẫu nhiên nhiều file để thử.

Không che lỗi bằng cách disable validation/security.

Không downgrade dependency chỉ để lỗi biến mất nếu chưa hiểu nguyên
nhân.

------------------------------------------------------------------------

# 35. KHI DÙNG AI ĐỂ CODE

AI Agent phải:

-   hiểu code trước khi sửa
-   giữ consistency với project
-   không copy code không hiểu
-   giải thích được thay đổi
-   kiểm tra generated code
-   test generated code

AI-generated code không được mặc định xem là đúng.

------------------------------------------------------------------------

# 36. KHI THÊM DEPENDENCY

Trước khi thêm package/library:

``` text
1. Có thật sự cần không?
2. Project đã có dependency tương tự chưa?
3. Có ảnh hưởng version không?
4. Có ảnh hưởng build không?
5. Có ảnh hưởng security không?
```

Sau khi thêm:

``` text
Build
Test
Update documentation nếu cần
Worklog
```

------------------------------------------------------------------------

# 37. KHI THAY ĐỔI DATABASE

Phải kiểm tra:

``` text
Migration
Entity
Repository
Service
DTO
API
Frontend
Existing data
```

Nếu breaking change:

``` text
Document migration
Test migration
Update affected code
```

Không chỉ sửa SQL rồi bỏ qua Entity.

------------------------------------------------------------------------

# 38. KHI THAY ĐỔI API

Checklist:

``` text
[ ] Request DTO
[ ] Response DTO
[ ] Controller
[ ] Service
[ ] Swagger
[ ] Postman
[ ] Frontend API service
[ ] Frontend component
[ ] Tests
[ ] README/docs
[ ] AI_WORKLOG
```

------------------------------------------------------------------------

# 39. KHI THAY ĐỔI FRONTEND

Kiểm tra:

``` text
Component
Hook
API service
Routing
Auth
Responsive
Loading
Error
```

Không chỉ kiểm tra UI bằng mắt.

Phải kiểm tra behavior.

------------------------------------------------------------------------

# 40. PROJECT DEFINITION OF DONE

Toàn bộ project chỉ được xem là hoàn thành khi:

``` text
Backend
[ ] Auth
[ ] AI integration
[ ] Conversation
[ ] Messages
[ ] Usage
[ ] Retry
[ ] Timeout
[ ] Rate limit
[ ] Error handling
[ ] Logging
[ ] Structured output
[ ] Swagger
[ ] Tests

Frontend
[ ] Auth UI
[ ] Chat
[ ] Conversation
[ ] Dashboard
[ ] API integration
[ ] Loading/error
[ ] Responsive

Infrastructure
[ ] PostgreSQL
[ ] Redis
[ ] Docker
[ ] Environment configuration

Documentation
[ ] README
[ ] API docs
[ ] Architecture
[ ] Database schema
[ ] Postman
[ ] AI_WORKLOG

Security
[ ] No secrets in Git
[ ] Authorization
[ ] Ownership checks
[ ] Validation
```

------------------------------------------------------------------------

# 41. NGUYÊN TẮC CUỐI CÙNG

Luôn nhớ:

``` text
THINK BEFORE CODE
PLAN BEFORE IMPLEMENT
INSPECT BEFORE MODIFY
TEST BEFORE CLAIMING SUCCESS
DOCUMENT AFTER SIGNIFICANT CHANGE
WORKLOG AFTER COMPLETED WORK
```

Ưu tiên:

``` text
Correctness > Speed
Simple architecture > Overengineering
Verified code > Generated code
Small safe changes > Large risky changes
Real implementation > Fake/demo-only functionality
```

AI Agent phải làm việc như một thành viên kỹ thuật của project, không
chỉ là công cụ sinh code.
