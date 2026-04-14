# MathNav Database - Entity Relationship Diagram (ERD)
## XAMPP/phpMyAdmin Style

```
┌────────────────────────────────────────────────────────────────────────┐
│                        DATABASE: mathnav_db                            │
└────────────────────────────────────────────────────────────────────────┘


╔═══════════════════════════════════════════════════════════════════════╗
║                              ADMINS                                   ║
╠═══════════════════════════════════════════════════════════════════════╣
║ 🔑 id                      VARCHAR(255)    PRIMARY KEY                ║
║ ═══════════════════════════════════════════════════════════════════   ║
║    username                VARCHAR(100)    UNIQUE, NOT NULL           ║
║    email                   VARCHAR(255)    UNIQUE, NOT NULL           ║
║    passwordHash            VARCHAR(255)    NOT NULL                   ║
║    name                    VARCHAR(255)    NOT NULL                   ║
║    role                    VARCHAR(50)     DEFAULT 'admin'            ║
║    createdAt               DATETIME        NOT NULL                   ║
║    lastLogin               DATETIME        NULL                       ║
║    isActive                BOOLEAN         DEFAULT true               ║
╚═══════════════════════════════════════════════════════════════════════╝


╔═══════════════════════════════════════════════════════════════════════╗
║                              USERS                                    ║
╠═══════════════════════════════════════════════════════════════════════╣
║ 🔑 uid                     VARCHAR(255)    PRIMARY KEY                ║
║ ═══════════════════════════════════════════════════════════════════   ║
║    username                VARCHAR(100)    UNIQUE, NOT NULL           ║
║    email                   VARCHAR(255)    UNIQUE, NOT NULL           ║
║    name                    VARCHAR(255)    NOT NULL                   ║
║    grade                   INT             NOT NULL                   ║
║    registrationDate        DATETIME        NOT NULL                   ║
║    lastLogin               DATETIME        NULL                       ║
║    totalQuizzesTaken       INT             DEFAULT 0                  ║
║    totalCorrectAnswers     INT             DEFAULT 0                  ║
║    totalQuestionsAttempted INT             DEFAULT 0                  ║
╚═══════════════════════════════════════════════════════════════════════╝
                                    │
                                    │ 1
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    │               │               │
                    ▼               ▼               ▼
        ╔═══════════════════╗  ╔═══════════════════╗  ╔═══════════════════╗
        ║  QUIZ_HISTORY     ║  ║    PROGRESS       ║  ║   (Other tables)  ║
        ╠═══════════════════╣  ╠═══════════════════╣  ╚═══════════════════╝
        ║ 🔑 id             ║  ║ 🔑 id             ║
        ║ ═════════════════ ║  ║ ═════════════════ ║
        ║ 🔗 userId         ║  ║ 🔗 userId         ║
        ║    quarter        ║  ║    studentEmail   ║
        ║    topic          ║  ║    quarter        ║
        ║    score          ║  ║    topic          ║
        ║    totalQuestions ║  ║    score          ║
        ║    percentage     ║  ║    correctAnswers ║
        ║    timestamp      ║  ║    totalQuestions ║
        ╚═══════════════════╝  ║    completedAt    ║
                 *              ╚═══════════════════╝
                                          *


╔═══════════════════════════════════════════════════════════════════════╗
║                             QUIZZES                                   ║
╠═══════════════════════════════════════════════════════════════════════╣
║ 🔑 id                      VARCHAR(255)    PRIMARY KEY                ║
║ ═══════════════════════════════════════════════════════════════════   ║
║    quarter                 INT             NOT NULL (1-4)             ║
║    topic                   VARCHAR(255)    NOT NULL                   ║
║    question                TEXT            NOT NULL                   ║
║    options                 JSON            NOT NULL (Array of 4)      ║
║    correctAnswerIndex      INT             NOT NULL (0-3)             ║
║    explanation             TEXT            NOT NULL                   ║
║    difficulty              INT             NOT NULL (1-3)             ║
║    audioFile               VARCHAR(255)    NULL                       ║
║ 🔗 createdBy               VARCHAR(255)    NULL (FK → ADMINS.id)      ║
║    createdAt               DATETIME        NOT NULL                   ║
║    updatedAt               DATETIME        NULL                       ║
╚═══════════════════════════════════════════════════════════════════════╝
                                    │
                                    │ *
                                    │
                                    │ referenced by
                                    │
                                    │ *
                                    ▼
                          ╔═══════════════════╗
                          ║    PROGRESS       ║
                          ║ (via quarter +    ║
                          ║      topic)       ║
                          ╚═══════════════════╝
```


---

## 🔗 RELATIONSHIP DIAGRAM (Crow's Foot Notation)

```
    ┌─────────────────────┐                    ┌─────────────────────┐
    │       ADMINS        │                    │      QUIZZES        │
    │─────────────────────│                    │─────────────────────│
    │ 🔑 id              │                    │ 🔑 id              │
    │ ─────────────────  │                    │ ─────────────────  │
    │   username         │                    │   quarter          │
    │   email            │                    │   topic            │
    │   passwordHash     │                    │   question         │
    │   name             │                    │   options[]        │
    │   role             │                    │   correctAnswerIdx │
    │   createdAt        │                    │   explanation      │
    │   lastLogin        │                    │   difficulty       │
    │   isActive         │                    │   audioFile        │
    └──────────┬──────────┘                    │ 🔗 createdBy       │
               │                               │   createdAt        │
               │ 1                             │   updatedAt        │
               │                               └──────────┬──────────┘
               │ *                                        │
               └──────────────────────────────────────────┘
                         (creates/manages)


    ┌─────────────────────┐                    ┌─────────────────────┐
    │       USERS         │                    │   QUIZ_HISTORY      │
    │─────────────────────│                    │─────────────────────│
    │ 🔑 uid             │                    │ 🔑 id              │
    │ ─────────────────  │                    │ ─────────────────  │
    │   username         │                    │ 🔗 userId          │
    │   email            │                    │   quarter          │
    │   name             │                    │   topic            │
    │   grade            │                    │   score            │
    │   registrationDate │                    │   totalQuestions   │
    │   lastLogin        │                    │   percentage       │
    │   totalQuizzesTaken│                    │   timestamp        │
    └──────────┬──────────┘                    └─────────────────────┘
               │
               │ 1
               ├──────────────────────────────────────────────────────┐
               │                                                      │
               │ *                                                    │ *
               ▼                                                      ▼
    ┌─────────────────────┐                    ┌─────────────────────┐
    │   QUIZ_HISTORY      │                    │     PROGRESS        │
    │─────────────────────│                    │─────────────────────│
    │ 🔑 id              │                    │ 🔑 id              │
    │ ─────────────────  │                    │ ─────────────────  │
    │ 🔗 userId          │                    │ 🔗 userId          │
    │   quarter          │                    │   studentEmail     │
    │   topic            │                    │   quarter          │
    │   score            │                    │   topic            │
    │   totalQuestions   │                    │   score            │
    │   percentage       │                    │   correctAnswers   │
    │   timestamp        │                    │   totalQuestions   │
    └─────────────────────┘                    │   completedAt      │
                                               └──────────┬──────────┘
                                                          │
                                                          │ *
                                                          │
                                                          │ references
                                                          │
                                                          │ *
                                                          ▼
                                               ┌─────────────────────┐
                                               │      QUIZZES        │
                                               │─────────────────────│
                                               │ 🔑 id              │
                                               │ ─────────────────  │
                                               │   quarter          │
                                               │   topic            │
                                               │   question         │
                                               │   options[]        │
                                               │   correctAnswerIdx │
                                               │   explanation      │
                                               │   difficulty       │
                                               │   audioFile        │
                                               │ 🔗 createdBy       │
                                               │   createdAt        │
                                               │   updatedAt        │
                                               └─────────────────────┘
```

---

## 📐 COMPLETE ERD WITH ALL RELATIONSHIPS

```
                    ┌─────────────────────────────────┐
                    │          ADMINS                 │
                    │─────────────────────────────────│
                    │ 🔑 id               VARCHAR(255)│
                    │ ═══════════════════════════════ │
                    │    username         VARCHAR(100)│
                    │    email            VARCHAR(255)│
                    │    passwordHash     VARCHAR(255)│
                    │    name             VARCHAR(255)│
                    │    role             VARCHAR(50) │
                    │    createdAt        DATETIME    │
                    │    lastLogin        DATETIME    │
                    │    isActive         BOOLEAN     │
                    └────────────┬────────────────────┘
                                 │
                                 │ 1:* (creates/manages)
                                 │
                                 ▼
                    ┌─────────────────────────────────┐
                    │      QUIZZES                    │
                    │─────────────────────────────────│
                    │ 🔑 id               VARCHAR(255)│
                    │ ═══════════════════════════════ │
                    │    quarter          INT         │
                    │    topic            VARCHAR     │
                    │    question         TEXT        │
                    │    options          JSON        │
                    │    correctAnswerIndex INT       │
                    │    explanation      TEXT        │
                    │    difficulty       INT         │
                    │    audioFile        VARCHAR     │
                    │ 🔗 createdBy        VARCHAR(255)│
                    │    createdAt        DATETIME    │
                    │    updatedAt        DATETIME    │
                    └────────────┬────────────────────┘
                                 │
                                 │ *:* (referenced by)
                                 │
                                 ▼
                ┌─────────────────────────────────┐
                │          USERS                  │
                │─────────────────────────────────│
                │ 🔑 uid              VARCHAR(255)│
                │ ═══════════════════════════════ │
                │    username         VARCHAR(100)│
                │    email            VARCHAR(255)│
                │    name             VARCHAR(255)│
                │    grade            INT         │
                │    registrationDate DATETIME    │
                │    lastLogin        DATETIME    │
                │    totalQuizzesTaken INT        │
                │    totalCorrectAnswers INT      │
                │    totalQuestionsAttempted INT  │
                └────────────┬────────────────────┘
                             │
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        │ 1:*                │ 1:*                │
        │                    │                    │
        ▼                    ▼                    │
┌───────────────────────┐  ┌───────────────────────┐
│   QUIZ_HISTORY        │  │      PROGRESS         │
│───────────────────────│  │───────────────────────│
│ 🔑 id    VARCHAR(255) │  │ 🔑 id    VARCHAR(255) │
│ ═════════════════════ │  │ ═════════════════════ │
│ 🔗 userId VARCHAR(255)│  │ 🔗 userId VARCHAR(255)│
│    quarter       INT  │  │    studentEmail       │
│    topic    VARCHAR   │  │        VARCHAR(255)   │
│    score         INT  │  │    quarter       INT  │
│    totalQuestions INT │  │    topic    VARCHAR   │
│    percentage VARCHAR │  │    score         INT  │
│    timestamp DATETIME │  │    correctAnswers INT │
└───────────────────────┘  │    totalQuestions INT │
                          │    completedAt TIMESTAMP│
                          └───────────────────────┘
```


---

## 🔑 KEYS AND CONSTRAINTS

```
┌──────────────────────────────────────────────────────────────────┐
│                       PRIMARY KEYS                               │
├──────────────────────────────────────────────────────────────────┤
│ ADMINS.id              - Unique admin identifier                 │
│ USERS.uid              - Unique user identifier (Firebase Auth)  │
│ QUIZZES.id             - Unique quiz identifier                  │
│ QUIZ_HISTORY.id        - Unique history record identifier        │
│ PROGRESS.id            - Unique progress record identifier       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                       FOREIGN KEYS                               │
├──────────────────────────────────────────────────────────────────┤
│ QUIZZES.createdBy      → ADMINS.id                               │
│ QUIZ_HISTORY.userId    → USERS.uid                               │
│ PROGRESS.userId        → USERS.uid                               │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    UNIQUE CONSTRAINTS                            │
├──────────────────────────────────────────────────────────────────┤
│ ADMINS.username        - No duplicate admin usernames allowed    │
│ ADMINS.email           - No duplicate admin emails allowed       │
│ USERS.username         - No duplicate usernames allowed          │
│ USERS.email            - No duplicate emails allowed             │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📊 TABLE INDEXES

```sql
-- ============================================
-- ADMINS TABLE INDEXES
-- ============================================
CREATE INDEX idx_admins_username ON ADMINS(username);
CREATE INDEX idx_admins_email ON ADMINS(email);
CREATE INDEX idx_admins_isActive ON ADMINS(isActive);

-- ============================================
-- USERS TABLE INDEXES
-- ============================================
CREATE INDEX idx_users_username ON USERS(username);
CREATE INDEX idx_users_email ON USERS(email);
CREATE INDEX idx_users_grade ON USERS(grade);

-- ============================================
-- QUIZZES TABLE INDEXES
-- ============================================
CREATE INDEX idx_quizzes_quarter ON QUIZZES(quarter);
CREATE INDEX idx_quizzes_topic ON QUIZZES(topic);
CREATE INDEX idx_quizzes_quarter_topic ON QUIZZES(quarter, topic);
CREATE INDEX idx_quizzes_difficulty ON QUIZZES(difficulty);
CREATE INDEX idx_quizzes_createdBy ON QUIZZES(createdBy);
CREATE INDEX idx_quizzes_createdAt ON QUIZZES(createdAt);

-- ============================================
-- PROGRESS TABLE INDEXES
-- ============================================
CREATE INDEX idx_progress_userId ON PROGRESS(userId);
CREATE INDEX idx_progress_quarter ON PROGRESS(quarter);
CREATE INDEX idx_progress_topic ON PROGRESS(topic);
CREATE INDEX idx_progress_completedAt ON PROGRESS(completedAt);
CREATE INDEX idx_progress_userId_completedAt ON PROGRESS(userId, completedAt);

-- ============================================
-- QUIZ_HISTORY TABLE INDEXES
-- ============================================
CREATE INDEX idx_quiz_history_userId ON QUIZ_HISTORY(userId);
CREATE INDEX idx_quiz_history_quarter ON QUIZ_HISTORY(quarter);
CREATE INDEX idx_quiz_history_timestamp ON QUIZ_HISTORY(timestamp);
```

---

## 💾 CREATE TABLE STATEMENTS

```sql
-- ============================================
-- CREATE ADMINS TABLE
-- ============================================
CREATE TABLE ADMINS (
    id VARCHAR(255) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    passwordHash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    createdAt DATETIME NOT NULL,
    lastLogin DATETIME NULL,
    isActive BOOLEAN DEFAULT true
);

-- ============================================
-- CREATE USERS TABLE
-- ============================================
CREATE TABLE USERS (
    uid VARCHAR(255) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    grade INT NOT NULL,
    registrationDate DATETIME NOT NULL,
    lastLogin DATETIME NULL,
    totalQuizzesTaken INT DEFAULT 0,
    totalCorrectAnswers INT DEFAULT 0,
    totalQuestionsAttempted INT DEFAULT 0
);


-- ============================================
-- CREATE QUIZZES TABLE
-- ============================================
CREATE TABLE QUIZZES (
    id VARCHAR(255) PRIMARY KEY,
    quarter INT NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    topic VARCHAR(255) NOT NULL,
    question TEXT NOT NULL,
    options JSON NOT NULL,
    correctAnswerIndex INT NOT NULL CHECK (correctAnswerIndex BETWEEN 0 AND 3),
    explanation TEXT NOT NULL,
    difficulty INT NOT NULL CHECK (difficulty BETWEEN 1 AND 3),
    audioFile VARCHAR(255) NULL,
    createdBy VARCHAR(255) NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NULL,
    FOREIGN KEY (createdBy) REFERENCES ADMINS(id) ON DELETE SET NULL
);

-- ============================================
-- CREATE QUIZ_HISTORY TABLE
-- ============================================
CREATE TABLE QUIZ_HISTORY (
    id VARCHAR(255) PRIMARY KEY,
    userId VARCHAR(255) NOT NULL,
    quarter INT NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    topic VARCHAR(255) NOT NULL,
    score INT NOT NULL,
    totalQuestions INT NOT NULL,
    percentage VARCHAR(10) NOT NULL,
    timestamp DATETIME NOT NULL,
    FOREIGN KEY (userId) REFERENCES USERS(uid) ON DELETE CASCADE
);

-- ============================================
-- CREATE PROGRESS TABLE
-- ============================================
CREATE TABLE PROGRESS (
    id VARCHAR(255) PRIMARY KEY,
    userId VARCHAR(255) NOT NULL,
    studentEmail VARCHAR(255) NOT NULL,
    quarter INT NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    topic VARCHAR(255) NOT NULL,
    score INT NOT NULL,
    correctAnswers INT NOT NULL,
    totalQuestions INT NOT NULL,
    completedAt TIMESTAMP NOT NULL,
    FOREIGN KEY (userId) REFERENCES USERS(uid) ON DELETE CASCADE
);
```

---

## 📝 SAMPLE DATA

```sql
-- ============================================
-- INSERT SAMPLE ADMIN
-- ============================================
INSERT INTO ADMINS (id, username, email, passwordHash, name, role, 
                    createdAt, lastLogin, isActive)
VALUES (
    'admin_001',
    'admin',
    'admin@mathnav.com',
    '$2b$10$hashedPasswordExample',
    'System Administrator',
    'admin',
    '2024-01-01 00:00:00',
    '2024-03-24 10:00:00',
    true
);

-- ============================================
-- INSERT SAMPLE USER
-- ============================================
INSERT INTO USERS (uid, username, email, name, grade, registrationDate, 
                   lastLogin, totalQuizzesTaken, totalCorrectAnswers, 
                   totalQuestionsAttempted)
VALUES (
    'user_abc123',
    'john_doe',
    'john.doe@example.com',
    'John Doe',
    6,
    '2024-01-15 10:30:00',
    '2024-03-24 08:15:00',
    15,
    120,
    150
);

-- ============================================
-- INSERT SAMPLE QUIZ
-- ============================================
INSERT INTO QUIZZES (id, quarter, topic, question, options, 
                     correctAnswerIndex, explanation, difficulty, 
                     audioFile, createdBy, createdAt, updatedAt)
VALUES (
    'quiz_001',
    1,
    'Numbers and Number Sense',
    'What is 1/2 + 1/2?',
    '["1/4", "2/4", "1", "2/2"]',
    2,
    '1/2 + 1/2 = 2/2 = 1 whole',
    1,
    NULL,
    'admin_001',
    '2024-03-20 14:00:00',
    NULL
);

-- ============================================
-- INSERT SAMPLE PROGRESS
-- ============================================
INSERT INTO PROGRESS (id, userId, studentEmail, quarter, topic, 
                      score, correctAnswers, totalQuestions, completedAt)
VALUES (
    'progress_001',
    'user_abc123',
    'john.doe@example.com',
    1,
    'Numbers and Number Sense',
    80,
    8,
    10,
    '2024-03-24 09:30:00'
);

-- ============================================
-- INSERT SAMPLE QUIZ_HISTORY
-- ============================================
INSERT INTO QUIZ_HISTORY (id, userId, quarter, topic, score, 
                          totalQuestions, percentage, timestamp)
VALUES (
    'history_001',
    'user_abc123',
    1,
    'Numbers and Number Sense',
    8,
    10,
    '80.0',
    '2024-03-24 09:30:00'
);
```

---

## 🔍 COMMON QUERIES

```sql
-- ============================================
-- ADMIN QUERIES
-- ============================================
-- Get all active admins
SELECT * FROM ADMINS WHERE isActive = true;

-- Get admin by username
SELECT * FROM ADMINS WHERE username = 'admin';

-- Update admin last login
UPDATE ADMINS SET lastLogin = NOW() WHERE id = 'admin_001';

-- Get quizzes created by specific admin
SELECT q.*, a.name as admin_name 
FROM QUIZZES q
LEFT JOIN ADMINS a ON q.createdBy = a.id
WHERE q.createdBy = 'admin_001';

-- ============================================
-- QUIZ QUERIES
-- ============================================
-- Get all quizzes for Quarter 1
SELECT * FROM QUIZZES WHERE quarter = 1;

-- Get all quizzes for a specific topic
SELECT * FROM QUIZZES 
WHERE quarter = 1 AND topic = 'Numbers and Number Sense';

-- Get user's quiz history
SELECT * FROM QUIZ_HISTORY 
WHERE userId = 'user_abc123' 
ORDER BY timestamp DESC;

-- Get user's progress for all quarters
SELECT * FROM PROGRESS 
WHERE userId = 'user_abc123' 
ORDER BY completedAt DESC;

-- Get average score by topic
SELECT topic, AVG(score) as avg_score, COUNT(*) as attempts
FROM PROGRESS
GROUP BY topic;

-- Get top performing students
SELECT u.name, u.username, u.totalCorrectAnswers, u.totalQuestionsAttempted,
       (u.totalCorrectAnswers * 100.0 / u.totalQuestionsAttempted) as accuracy
FROM USERS u
WHERE u.totalQuestionsAttempted > 0
ORDER BY accuracy DESC
LIMIT 10;

-- Get quiz completion rate by quarter
SELECT quarter, COUNT(*) as total_completions, 
       AVG(score) as avg_score
FROM PROGRESS
GROUP BY quarter
ORDER BY quarter;
```

---

## 📌 RELATIONSHIP SUMMARY

| Relationship | Type | Description |
|-------------|------|-------------|
| ADMINS → QUIZZES | 1:* | One admin creates/manages many quizzes |
| USERS → QUIZ_HISTORY | 1:* | One user has many quiz history records |
| USERS → PROGRESS | 1:* | One user has many progress records |
| QUIZZES ↔ PROGRESS | *:* | Many-to-many through PROGRESS table |

**Legend:**
- 🔑 = Primary Key
- 🔗 = Foreign Key
- 1:* = One-to-Many relationship
- *:* = Many-to-Many relationship
