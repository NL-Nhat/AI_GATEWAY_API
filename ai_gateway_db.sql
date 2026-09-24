
--CREATE DATABASE ai_gateway;


-- =========================================================
-- 2. EXTENSIONS
-- =========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- =========================================================
-- 3. ENUM TYPES
-- =========================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type
        WHERE typname = 'user_role'
    ) THEN
        CREATE TYPE user_role AS ENUM (
            'USER',
            'ADMIN'
        );
    END IF;
END
$$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type
        WHERE typname = 'message_role'
    ) THEN
        CREATE TYPE message_role AS ENUM (
            'SYSTEM',
            'USER',
            'ASSISTANT'
        );
    END IF;
END
$$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type
        WHERE typname = 'request_status'
    ) THEN
        CREATE TYPE request_status AS ENUM (
            'SUCCESS',
            'FAILED',
            'TIMEOUT',
            'RATE_LIMITED'
        );
    END IF;
END
$$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type
        WHERE typname = 'provider_type'
    ) THEN
        CREATE TYPE provider_type AS ENUM (
            'OPENAI',
            'GEMINI',
            'CLAUDE'
        );
    END IF;
END
$$;


-- =========================================================
-- 4. USERS
-- =========================================================

CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,

    email           VARCHAR(255) NOT NULL UNIQUE,

    password_hash   VARCHAR(255) NOT NULL,

    role            user_role NOT NULL DEFAULT 'USER',

    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX IF NOT EXISTS idx_users_email
ON users(email);


-- =========================================================
-- 5. API KEYS
-- =========================================================

CREATE TABLE IF NOT EXISTS api_keys (
    id              BIGSERIAL PRIMARY KEY,

    user_id         BIGINT NOT NULL,

    name            VARCHAR(100) NOT NULL,

    key_hash        VARCHAR(255) NOT NULL UNIQUE,

    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    expires_at      TIMESTAMPTZ,

    last_used_at    TIMESTAMPTZ,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_api_keys_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_api_keys_user_id
ON api_keys(user_id);

CREATE INDEX IF NOT EXISTS idx_api_keys_active
ON api_keys(is_active);


-- =========================================================
-- 6. CONVERSATIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS conversations (
    id              BIGSERIAL PRIMARY KEY,

    user_id         BIGINT NOT NULL,

    title           VARCHAR(255),

    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversations_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_conversations_user_id
ON conversations(user_id);

CREATE INDEX IF NOT EXISTS idx_conversations_updated_at
ON conversations(updated_at DESC);


-- =========================================================
-- 7. MESSAGES
-- =========================================================

CREATE TABLE IF NOT EXISTS messages (
    id                  BIGSERIAL PRIMARY KEY,

    conversation_id     BIGINT NOT NULL,

    role                message_role NOT NULL,

    content             TEXT NOT NULL,

    provider            provider_type,

    model               VARCHAR(100),

    input_tokens        INTEGER NOT NULL DEFAULT 0,

    output_tokens       INTEGER NOT NULL DEFAULT 0,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_messages_input_tokens
        CHECK (input_tokens >= 0),

    CONSTRAINT chk_messages_output_tokens
        CHECK (output_tokens >= 0)
);


CREATE INDEX IF NOT EXISTS idx_messages_conversation_id
ON messages(conversation_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at
ON messages(created_at);


-- =========================================================
-- 8. AI REQUESTS
-- =========================================================

CREATE TABLE IF NOT EXISTS ai_requests (
    id                  BIGSERIAL PRIMARY KEY,

    request_id          UUID NOT NULL DEFAULT gen_random_uuid(),

    user_id             BIGINT NOT NULL,

    conversation_id     BIGINT,

    provider            provider_type NOT NULL,

    model               VARCHAR(100) NOT NULL,

    input_tokens        INTEGER NOT NULL DEFAULT 0,

    output_tokens       INTEGER NOT NULL DEFAULT 0,

    latency_ms          BIGINT,

    status              request_status NOT NULL,

    error_message       TEXT,

    retry_count         INTEGER NOT NULL DEFAULT 0,

    fallback_used       BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_ai_requests_request_id
        UNIQUE (request_id),

    CONSTRAINT fk_ai_requests_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_ai_requests_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_ai_requests_input_tokens
        CHECK (input_tokens >= 0),

    CONSTRAINT chk_ai_requests_output_tokens
        CHECK (output_tokens >= 0),

    CONSTRAINT chk_ai_requests_latency
        CHECK (latency_ms IS NULL OR latency_ms >= 0),

    CONSTRAINT chk_ai_requests_retry_count
        CHECK (retry_count >= 0)
);


CREATE INDEX IF NOT EXISTS idx_ai_requests_user_id
ON ai_requests(user_id);

CREATE INDEX IF NOT EXISTS idx_ai_requests_conversation_id
ON ai_requests(conversation_id);

CREATE INDEX IF NOT EXISTS idx_ai_requests_created_at
ON ai_requests(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_requests_model
ON ai_requests(model);

CREATE INDEX IF NOT EXISTS idx_ai_requests_provider
ON ai_requests(provider);

CREATE INDEX IF NOT EXISTS idx_ai_requests_status
ON ai_requests(status);


-- =========================================================
-- 9. USAGE DAILY
-- =========================================================

CREATE TABLE IF NOT EXISTS usage_daily (
    id                  BIGSERIAL PRIMARY KEY,

    user_id             BIGINT NOT NULL,

    usage_date          DATE NOT NULL,

    total_requests      INTEGER NOT NULL DEFAULT 0,

    successful_requests INTEGER NOT NULL DEFAULT 0,

    failed_requests     INTEGER NOT NULL DEFAULT 0,

    total_input_tokens  BIGINT NOT NULL DEFAULT 0,

    total_output_tokens BIGINT NOT NULL DEFAULT 0,

    total_tokens        BIGINT NOT NULL DEFAULT 0,

    total_latency_ms    BIGINT NOT NULL DEFAULT 0,

    average_latency_ms  NUMERIC(12, 2) NOT NULL DEFAULT 0,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usage_daily_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_usage_daily_user_date
        UNIQUE (user_id, usage_date),

    CONSTRAINT chk_usage_requests
        CHECK (total_requests >= 0),

    CONSTRAINT chk_usage_successful_requests
        CHECK (successful_requests >= 0),

    CONSTRAINT chk_usage_failed_requests
        CHECK (failed_requests >= 0),

    CONSTRAINT chk_usage_input_tokens
        CHECK (total_input_tokens >= 0),

    CONSTRAINT chk_usage_output_tokens
        CHECK (total_output_tokens >= 0),

    CONSTRAINT chk_usage_total_tokens
        CHECK (total_tokens >= 0),

    CONSTRAINT chk_usage_latency
        CHECK (total_latency_ms >= 0),

    CONSTRAINT chk_usage_average_latency
        CHECK (average_latency_ms >= 0)
);


CREATE INDEX IF NOT EXISTS idx_usage_daily_user_id
ON usage_daily(user_id);

CREATE INDEX IF NOT EXISTS idx_usage_daily_date
ON usage_daily(usage_date DESC);


-- =========================================================
-- 10. UPDATED_AT TRIGGER
-- =========================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_users_updated_at
ON users;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


DROP TRIGGER IF EXISTS trg_conversations_updated_at
ON conversations;

CREATE TRIGGER trg_conversations_updated_at
BEFORE UPDATE ON conversations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


DROP TRIGGER IF EXISTS trg_usage_daily_updated_at
ON usage_daily;

CREATE TRIGGER trg_usage_daily_updated_at
BEFORE UPDATE ON usage_daily
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- =========================================================
-- 11. VIEW: USAGE SUMMARY
-- =========================================================

CREATE OR REPLACE VIEW v_usage_summary AS
SELECT
    COUNT(*) AS requests,

    COUNT(*) FILTER (
        WHERE status = 'SUCCESS'
    ) AS successful_requests,

    COUNT(*) FILTER (
        WHERE status IN ('FAILED', 'TIMEOUT')
    ) AS failed_requests,

    COALESCE(SUM(input_tokens), 0) AS total_input_tokens,

    COALESCE(SUM(output_tokens), 0) AS total_output_tokens,

    COALESCE(
        SUM(input_tokens + output_tokens),
        0
    ) AS total_tokens,

    COALESCE(
        ROUND(AVG(latency_ms), 2),
        0
    ) AS average_latency_ms,

    COALESCE(
        ROUND(
            (
                COUNT(*) FILTER (
                    WHERE status IN ('FAILED', 'TIMEOUT')
                )::NUMERIC
                / NULLIF(COUNT(*), 0)
            ),
            4
        ),
        0
    ) AS error_rate

FROM ai_requests;


-- =========================================================
-- 12. VIEW: USER USAGE SUMMARY
-- =========================================================

CREATE OR REPLACE VIEW v_user_usage_summary AS
SELECT
    user_id,

    COUNT(*) AS requests,

    COUNT(*) FILTER (
        WHERE status = 'SUCCESS'
    ) AS successful_requests,

    COUNT(*) FILTER (
        WHERE status IN ('FAILED', 'TIMEOUT')
    ) AS failed_requests,

    COALESCE(SUM(input_tokens), 0) AS total_input_tokens,

    COALESCE(SUM(output_tokens), 0) AS total_output_tokens,

    COALESCE(
        SUM(input_tokens + output_tokens),
        0
    ) AS total_tokens,

    COALESCE(
        ROUND(AVG(latency_ms), 2),
        0
    ) AS average_latency_ms,

    COALESCE(
        ROUND(
            (
                COUNT(*) FILTER (
                    WHERE status IN ('FAILED', 'TIMEOUT')
                )::NUMERIC
                / NULLIF(COUNT(*), 0)
            ),
            4
        ),
        0
    ) AS error_rate

FROM ai_requests

GROUP BY user_id;


-- =========================================================
-- 13. SAMPLE DATA
-- =========================================================

-- Password hash dưới đây chỉ là dữ liệu demo.
-- Khi chạy project thật, password phải được hash bằng BCrypt
-- ở Spring Boot, không insert password plaintext vào DB.

INSERT INTO users (
    email,
    password_hash,
    role
)
VALUES (
    'admin@aigateway.local',
    '$2a$10$DUMMY_HASH_REPLACE_IN_APPLICATION',
    'ADMIN'
)
ON CONFLICT (email) DO NOTHING;


INSERT INTO users (
    email,
    password_hash,
    role
)
VALUES (
    'user@aigateway.local',
    '$2a$10$DUMMY_HASH_REPLACE_IN_APPLICATION',
    'USER'
)
ON CONFLICT (email) DO NOTHING;


-- =========================================================
-- 14. TEST QUERIES
-- =========================================================

-- Xem users
-- SELECT * FROM users;

-- Xem conversations
-- SELECT * FROM conversations;

-- Xem messages
-- SELECT * FROM messages;

-- Xem AI requests
-- SELECT * FROM ai_requests;

-- Xem usage tổng
-- SELECT * FROM v_usage_summary;

-- Xem usage theo user
-- SELECT * FROM v_user_usage_summary;