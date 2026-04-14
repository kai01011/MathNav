# MathNav System - Level 1 Data Flow Diagram (DFD)

## 📊 LEVEL 1 DFD - COMPLETE SYSTEM

```
┌───────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                       │
│                                                                                       │
│      ┌──────────────┐                                        ┌──────────────┐        │
│      │      a.      │                                        │      b.      │        │
│      │   STUDENT    │                                        │    ADMIN     │        │
│      └──────┬───────┘                                        └──────┬───────┘        │
│             │                                                       │                │
│             │ Login/Register                                        │ Login          │
│             │ Quarter Selection                                     │                │
│             │ Topic Selection                                       │                │
│             │ Quiz Answers                                          │                │
│             │                                                       │                │
│             ▼                                                       ▼                │
│      ┌──────────────────────────────────────────────────────────────────┐           │
│      │                                                                  │           │
│      │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐    │           │
│      │  │  1.0           │  │  2.0           │  │  3.0           │    │           │
│      │  │  AUTHENTICATE  │  │  MANAGE        │  │  MANAGE        │    │           │
│      │  │  USER          │  │  QUIZZES       │  │  USERS         │    │           │
│      │  └───┬────────────┘  └───┬────────────┘  └───┬────────────┘    │           │
│      │      │                   │                   │                 │           │
│      │      │                   │                   │                 │           │
│      │  ┌───▼───────────────────▼───────────────────▼────────────┐    │           │
│      │  │  4.0                                                   │    │           │
│      │  │  DELIVER QUIZ                                          │    │           │
│      │  └───┬────────────────────────────────────────────────────┘    │           │
│      │      │                                                          │           │
│      │  ┌───▼────────────────────────────────────────────────────┐    │           │
│      │  │  5.0                                                   │    │           │
│      │  │  TRACK PROGRESS & GENERATE REPORTS                     │    │           │
│      │  └────────────────────────────────────────────────────────┘    │           │
│      │                                                                  │           │
│      └──────┬───────────────────────────────────────────┬───────────────┘           │
│             │                                           │                           │
│             │ Quiz Results                              │ Reports                   │
│             │ Progress Data                             │ Analytics                 │
│             │ Feedback                                  │ User Statistics           │
│             │                                           │ Quiz Data                 │
│             ▼                                           ▼                           │
│      ┌──────────────┐                                  ┌──────────────┐            │
│      │      a.      │                                  │      b.      │            │
│      │   STUDENT    │                                  │    ADMIN     │            │
│      └──────────────┘                                  └──────────────┘            │
│                                                                                       │
│                                                                                       │
│      DATA STORES:                                                                    │
│      ═══════════                                                                     │
│                                                                                       │
│      ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│      │ D1: USERS    │  │ D2: ADMINS   │  │ D3: QUIZZES  │  │ D4: PROGRESS │        │
│      └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                                       │
│      ┌──────────────┐                                                                │
│      │D5:QUIZ_HISTORY│                                                               │
│      └──────────────┘                                                                │
│                                                                                       │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 DETAILED PROCESS BREAKDOWN

### **PROCESS 1.0: AUTHENTICATE USER**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 1.0: AUTHENTICATE USER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM STUDENT:                                                │
│      • Login credentials (username/email + password)           │
│      • Registration data (new account)                         │
│    FROM ADMIN:                                                  │
│      • Admin login credentials                                 │
│                                                                 │
│  PROCESSING:                                                    │
│    • Check if user has account (decision point)                │
│    • Validate login credentials                                │
│    • Create new user account (registration)                    │
│    • Verify admin credentials                                  │
│    • Generate authentication tokens                            │
│    • Update last login timestamp                               │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENT:                                                  │
│      • Authentication success/failure                          │
│      • Access to HomeScreen                                    │
│    TO ADMIN:                                                    │
│      • Authentication success/failure                          │
│      • Access to Dashboard                                     │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: USERS (read/write)                                    │
│    • D2: ADMINS (read/write)                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 2.0: MANAGE QUIZZES**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 2.0: MANAGE QUIZZES                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM ADMIN:                                                  │
│      • Create quiz request                                     │
│      • Edit quiz request                                       │
│      • Delete quiz request                                     │
│      • Seed/Sync quiz data                                     │
│      • Quiz difficulty adjustments                             │
│                                                                 │
│  PROCESSING:                                                    │
│    • Validate admin permissions                                │
│    • Create new quiz questions                                 │
│    • Update existing quiz content                              │
│    • Delete quiz questions                                     │
│    • Sync quizzes with database                                │
│    • Adjust difficulty levels                                  │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO ADMIN:                                                    │
│      • Quiz creation confirmation                              │
│      • Quiz update confirmation                                │
│      • Quiz deletion confirmation                              │
│      • Sync status                                             │
│                                                                 │
│  DATA STORES:                                                   │
│    • D3: QUIZZES (read/write)                                  │
│    • D2: ADMINS (read - for createdBy tracking)                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 3.0: MANAGE USERS**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 3.0: MANAGE USERS                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM ADMIN:                                                  │
│      • View users request                                      │
│      • Set/reset password request                              │
│      • Delete user request                                     │
│      • User search/filter criteria                             │
│                                                                 │
│  PROCESSING:                                                    │
│    • Retrieve user list                                        │
│    • Filter/search users                                       │
│    • Reset user passwords                                      │
│    • Delete user accounts                                      │
│    • Update user information                                   │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO ADMIN:                                                    │
│      • User list with details                                  │
│      • Password reset confirmation                             │
│      • User deletion confirmation                              │
│      • User statistics                                         │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: USERS (read/write)                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 4.0: DELIVER QUIZ**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 4.0: DELIVER QUIZ                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM STUDENT:                                                │
│      • Quarter selection (1-4)                                 │
│      • Topic selection                                         │
│      • Quiz answer submissions                                 │
│      • Retry/practice again request                            │
│                                                                 │
│  PROCESSING:                                                    │
│    • Navigate to HomeScreen                                    │
│    • Display SelectQuarters screen                             │
│    • Display SelectTopics screen                               │
│    • Fetch quiz questions by quarter/topic                     │
│    • Present quiz questions to student                         │
│    • Validate answer submissions                               │
│    • Calculate scores and percentages                          │
│    • Check if passed or failed                                 │
│    • Determine if practice/retry needed                        │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENT:                                                  │
│      • Quiz questions with options                             │
│      • Immediate feedback per question                         │
│      • Final score and results                                 │
│      • Pass/fail status                                        │
│      • Option to practice again or try again                   │
│      • Option to go back to topics                             │
│                                                                 │
│  DATA STORES:                                                   │
│    • D3: QUIZZES (read)                                        │
│    • D4: PROGRESS (write)                                      │
│    • D5: QUIZ_HISTORY (write)                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 5.0: TRACK PROGRESS & GENERATE REPORTS**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 5.0: TRACK PROGRESS & GENERATE REPORTS                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM PROCESS 4.0:                                            │
│      • Quiz completion data                                    │
│      • Student scores and answers                              │
│      • Timestamp data                                          │
│    FROM ADMIN:                                                  │
│      • Report requests                                         │
│      • Progress monitoring requests                            │
│      • Overview/analytics requests                             │
│                                                                 │
│  PROCESSING:                                                    │
│    • Record quiz attempts in history                           │
│    • Update student progress records                           │
│    • Calculate performance metrics                             │
│    • Update user statistics (total quizzes, correct answers)   │
│    • Generate progress reports                                 │
│    • Create analytics dashboards                               │
│    • Aggregate user performance data                           │
│    • Identify trends and patterns                              │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENT:                                                  │
│      • Personal progress summary                               │
│      • Topic mastery levels                                    │
│      • Historical performance                                  │
│    TO ADMIN:                                                    │
│      • Overview dashboard                                      │
│      • User progress reports                                   │
│      • Quiz statistics                                         │
│      • Performance analytics                                   │
│      • Topic difficulty analysis                               │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: USERS (read/write)                                    │
│    • D4: PROGRESS (read/write)                                 │
│    • D5: QUIZ_HISTORY (read/write)                             │
│    • D3: QUIZZES (read)                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 DATA STORES

```
┌──────────────────────────────────────────────────────────────────┐
│  D1: USERS                                                       │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Student profiles, credentials, aggregate statistics    │
│  Used by: Processes 1.0, 4.0, 5.0                               │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D2: ADMINS                                                      │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Admin profiles, credentials, roles, permissions        │
│  Used by: Processes 1.0, 3.0                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D3: QUIZZES                                                     │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Quiz questions, answers, explanations, difficulty      │
│  Used by: Processes 2.0, 3.0, 5.0                               │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D4: PROGRESS                                                    │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Student progress by quarter/topic, scores, completion  │
│  Used by: Processes 2.0, 4.0, 5.0                               │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D5: QUIZ_HISTORY                                                │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Historical quiz attempts, timestamps, scores           │
│  Used by: Processes 2.0, 4.0, 5.0                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 DATA FLOW DETAILS

### **STUDENT WORKFLOW (Based on Flowchart):**

| Step | From | To | Data Flow |
|------|------|-----|-----------|
| 1 | Student | Process 1.0 | Login credentials OR Registration data |
| 2 | Process 1.0 | Student | Authentication success → HomeScreen access |
| 3 | Student | Process 4.0 | Quarter selection (SelectQuarters) |
| 4 | Student | Process 4.0 | Topic selection (SelectTopics) |
| 5 | Process 4.0 | Student | Quiz questions with options |
| 6 | Student | Process 4.0 | Quiz answer submissions |
| 7 | Process 4.0 | Student | Score results (passed/failed) |
| 8a | Student | Process 4.0 | If failed → Practice quiz/Try again |
| 8b | Student | Process 4.0 | If passed → Back to topics/Try again option |
| 9 | Student | Process 4.0 | Play again? (Yes → back to topics, No → logout) |
| 10 | Process 4.0 | Process 5.0 | Quiz completion data for tracking |
| 11 | Process 5.0 | Student | Progress reports and feedback |

### **ADMIN WORKFLOW (Based on Flowchart):**

| Step | From | To | Data Flow |
|------|------|-----|-----------|
| 1 | Admin | Process 1.0 | Admin login credentials |
| 2 | Process 1.0 | Admin | Authentication success → Dashboard access |
| 3 | Admin | Process 5.0 | Overview request |
| 4 | Process 5.0 | Admin | System overview and statistics |
| 5 | Admin | Process 3.0 | User management requests (view users) |
| 6 | Process 3.0 | Admin | User list and details |
| 7 | Admin | Process 3.0 | Set password/Delete user requests |
| 8 | Admin | Process 2.0 | Quiz management requests |
| 9 | Process 2.0 | Admin | Quiz list |
| 10 | Admin | Process 2.0 | Create/Edit/Delete quiz operations |
| 11 | Admin | Process 5.0 | Progress monitor request |
| 12 | Process 5.0 | Admin | User progress reports |
| 13 | Admin | Process 2.0 | Seed/Sync quiz data |
| 14 | Process 2.0 | Admin | Sync confirmation |
| 15 | Admin | Process 1.0 | Logout request |

---

## 🎯 PROCESS SUMMARY TABLE

| Process | Name | Input Sources | Output Destinations | Data Stores Used |
|---------|------|---------------|---------------------|------------------|
| 1.0 | Authenticate User | Student (login/register), Admin (login) | Student (HomeScreen), Admin (Dashboard) | D1 (USERS), D2 (ADMINS) |
| 2.0 | Manage Quizzes | Admin (CRUD operations, sync) | Admin (confirmations) | D3 (QUIZZES), D2 (ADMINS) |
| 3.0 | Manage Users | Admin (user operations) | Admin (user data, confirmations) | D1 (USERS) |
| 4.0 | Deliver Quiz | Student (selections, answers) | Student (questions, results, feedback) | D3 (QUIZZES), D4 (PROGRESS), D5 (QUIZ_HISTORY) |
| 5.0 | Track Progress & Generate Reports | Process 4.0 (quiz data), Admin (requests) | Student (progress), Admin (reports, analytics) | D1 (USERS), D3 (QUIZZES), D4 (PROGRESS), D5 (QUIZ_HISTORY) |

---

## 🌐 SYSTEM BOUNDARIES

```
┌────────────────────────────────────────────────────────────────┐
│                      SYSTEM BOUNDARY                           │
│                                                                │
│  EXTERNAL ENTITIES (2):                                        │
│    a. STUDENT                                                  │
│       - Registers/Logs in                                      │
│       - Selects quarters and topics                            │
│       - Takes quizzes                                          │
│       - Views results and progress                             │
│       - Practices/retries quizzes                              │
│       - Logs out                                               │
│                                                                │
│    b. ADMIN                                                    │
│       - Logs in to dashboard                                   │
│       - Views system overview                                  │
│       - Manages users (view, set password, delete)             │
│       - Manages quizzes (create, edit, delete)                 │
│       - Seeds/syncs quiz data                                  │
│       - Monitors student progress                              │
│       - Views reports and analytics                            │
│       - Logs out                                               │
│                                                                │
│  INSIDE THE SYSTEM (5 PROCESSES):                              │
│    1.0 - Authenticate User                                     │
│    2.0 - Manage Quizzes                                        │
│    3.0 - Manage Users                                          │
│    4.0 - Deliver Quiz                                          │
│    5.0 - Track Progress & Generate Reports                     │
│                                                                │
│  DATA STORES (5):                                              │
│    D1: USERS - Student profiles and statistics                 │
│    D2: ADMINS - Admin accounts and credentials                 │
│    D3: QUIZZES - Quiz questions and content                    │
│    D4: PROGRESS - Student progress by topic                    │
│    D5: QUIZ_HISTORY - Historical quiz attempts                 │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 📋 LEGEND

```
┌─────────────────────────────────────────────────────────────────┐
│  SYMBOL LEGEND                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│      ┌─────────┐                                                │
│      │    a.   │                                                │
│      │ STUDENT │  = External Entity (oval shape)               │
│      └─────────┘                                                │
│                                                                 │
│  ┌──────────────┐                                               │
│  │   MATHNAV    │  = Process/System (rectangle)                │
│  │    SYSTEM    │                                               │
│  └──────────────┘                                               │
│                                                                 │
│  ┌──────────────┐                                               │
│  │ D1: USERS    │  = Data Store (open rectangle)               │
│  └──────────────┘                                               │
│                                                                 │
│      ───►         = Data Flow (arrow shows direction)          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 SECURITY & ACCESS CONTROL

```
┌────────────────────────────────────────────────────────────────┐
│  ACCESS CONTROL MATRIX                                         │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  STUDENT ACCESS:                                               │
│    ✓ Process 1.0 - Login/Registration                          │
│    ✓ Process 2.0 - Take quizzes                                │
│    ✓ Process 4.0 - View own progress (read-only)              │
│    ✗ Process 3.0 - Quiz management (NO ACCESS)                 │
│    ✗ Process 5.0 - System reports (NO ACCESS)                  │
│                                                                │
│  ADMIN ACCESS:                                                 │
│    ✓ Process 1.0 - Admin login                                 │
│    ✓ Process 3.0 - Full quiz management                        │
│    ✓ Process 5.0 - All reports & analytics                     │
│    ✓ User management (via Process 1.0)                         │
│    ✗ Process 2.0 - Taking quizzes (not applicable)             │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 📱 SYSTEM COMPONENTS

```
┌────────────────────────────────────────────────────────────────┐
│  IMPLEMENTATION COMPONENTS                                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  MOBILE APP (Flutter):                                         │
│    • Student interface                                         │
│    • Processes: 1.0 (student), 2.0, 4.0 (view only)            │
│                                                                │
│  WEB ADMIN PANEL (React):                                      │
│    • Admin interface                                           │
│    • Processes: 1.0 (admin), 3.0, 5.0                          │
│                                                                │
│  BACKEND API (Node.js/Express):                                │
│    • All process logic                                         │
│    • Database operations                                       │
│    • Firebase integration                                      │
│                                                                │
│  DATABASE (Firebase/MySQL):                                    │
│    • All data stores (D1-D5)                                   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```
