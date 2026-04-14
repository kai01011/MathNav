# MathNav System - Level 1 Data Flow Diagram (DFD)

## 📊 LEVEL 1 DFD - COMPLETE SYSTEM

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                             │
│                                                                                             │
│      ┌──────────────┐                                              ┌──────────────┐        │
│      │              │                                              │              │        │
│      │   STUDENTS   │                                              │    ADMIN     │        │
│      │              │                                              │              │        │
│      └──────┬───────┘                                              └──────┬───────┘        │
│             │                                                             │                │
│             │ login credentials                                           │ login          │
│             │                                                             │ credentials    │
│             │                                                             │                │
│             ▼                                                             ▼                │
│      ┌──────────────────────────────────────────────────────────────────────────┐         │
│      │                                                                          │         │
│      │  ┌────────────────┐                                                     │         │
│      │  │  6.0           │◄────── edit information ──────────────────────┐     │         │
│      │  │  MANAGE        │                                               │     │         │
│      │  │  ACCOUNTS      │─────── updated information ──────────────┐    │     │         │
│      │  └────────────────┘                                          │    │     │         │
│      │         │                                                    │    │     │         │
│      │         │                                                    ▼    │     │         │
│      │  ┌──────▼──────────┐                                    ┌────────────┐ │         │
│      │  │  8.0            │                                    │  D1        │ │         │
│      │  │  LOGIN          │◄────── login status ───────────────│  STUDENT   │ │         │
│      │  │  AUTHENTICATION │                                    │  ACCOUNTS  │ │         │
│      │  └──────┬──────────┘                                    └────────────┘ │         │
│      │         │                                                    │          │         │
│      │         │ login status                                       │ menu     │         │
│      │         │                                                    │ selection│         │
│      │         ▼                                                    ▼          │         │
│      │  ┌────────────────┐                                    ┌────────────┐  │         │
│      │  │   STUDENTS     │                                    │  2.0       │  │         │
│      │  │                │───── menu selection ───────────────►  USER      │  │         │
│      │  │                │                                    │  LEARNING  │  │         │
│      │  │                │◄──── module content ───────────────│  MODULE    │  │         │
│      │  │                │                                    └─────┬──────┘  │         │
│      │  │                │                                          │          │         │
│      │  │                │                                          │ module   │         │
│      │  │                │                                          │ content  │         │
│      │  │                │                                          ▼          │         │
│      │  │                │                                    ┌────────────┐  │         │
│      │  │                │                                    │  D2        │  │         │
│      │  │                │                                    │  LEARNING  │  │         │
│      │  │                │                                    │  CONTENT   │  │         │
│      │  │                │                                    └─────┬──────┘  │         │
│      │  │                │                                          │          │         │
│      │  │                │                                          │ Quiz     │         │
│      │  │                │◄──── Quiz ─────────────────────────┐    │          │         │
│      │  │                │                                    │    │          │         │
│      │  │                │                                    │    ▼          │         │
│      │  │                │                              ┌─────┴──────────┐    │         │
│      │  │                │───── Quiz Answers ──────────►│  3.0           │    │         │
│      │  │                │                              │  QUIZ          │    │         │
│      │  │                │                              │  MANAGEMENT    │    │         │
│      │  │                │                              └─────┬──────────┘    │         │
│      │  │                │                                    │               │         │
│      │  │                │                                    │ Quiz Results  │         │
│      │  │                │                                    ▼               │         │
│      │  │                │                              ┌────────────┐        │         │
│      │  │                │                              │  D3        │        │         │
│      │  │                │                              │  QUIZ      │        │         │
│      │  │                │                              │  RECORDS   │        │         │
│      │  │                │                              └─────┬──────┘        │         │
│      │  │                │                                    │               │         │
│      │  │                │                                    │ overall       │         │
│      │  │                │                                    │ results       │         │
│      │  │                │                                    ▼               │         │
│      │  │                │◄──── score results ───────── ┌────────────┐       │         │
│      │  │                │                              │  5.0       │       │         │
│      │  │                │                              │  STUDENTS  │       │         │
│      │  │                │                              │  RESULTS   │       │         │
│      │  └────────────────┘                              └─────┬──────┘       │         │
│      │         ▲                                              │               │         │
│      │         │                                              │ view scores   │         │
│      │         │                                              │               │         │
│      │         │                                              ▼               │         │
│      │         │                                        ┌────────────┐        │         │
│      │         │                                        │  4.0       │        │         │
│      │         │                                        │  MONITOR   │        │         │
│      │         │                                        │  STUDENTS  │        │         │
│      │         │                                        │  PROGRESS  │        │         │
│      │         │                                        └─────┬──────┘        │         │
│      │         │                                              │               │         │
│      │         │                                              │ monitor       │         │
│      │         │                                              │ progress      │         │
│      │         │                                              ▼               │         │
│      │         │                                        ┌────────────┐        │         │
│      │         └──────────── view results ──────────────│   ADMIN    │        │         │
│      │                                                  │            │        │         │
│      └──────────────────────────────────────────────────────────────┘        │         │
│                                                                                │         │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 DETAILED DATA FLOW DESCRIPTION

### **AUTHENTICATION FLOW (Circular Pattern):**

```
STUDENTS ──(login credentials)──► PROCESS 8.0 (Login Authentication)
                                          │
                                          │ (validates & fetches data)
                                          ▼
                                    D1: STUDENT ACCOUNTS
                                          │
                                          │ (login status)
                                          ▼
STUDENTS ◄──(login status)────── PROCESS 8.0 (Login Authentication)
```

**Explanation:**
1. Student sends login credentials to Process 8.0
2. Process 8.0 authenticates against D1 (Student Accounts)
3. D1 returns login status to Process 8.0
4. Process 8.0 sends login status back to Student
5. If successful, student can proceed with menu selection

---

## 📋 PROCESS DESCRIPTIONS

### **PROCESS 1.0: MANAGE ACCOUNTS**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 1.0: MANAGE ACCOUNTS                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM ADMIN/STUDENTS:                                         │
│      • Edit information requests                               │
│      • Account update data                                     │
│                                                                 │
│  PROCESSING:                                                    │
│    • Validate account changes                                  │
│    • Update account information                                │
│    • Modify user profiles                                      │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO D1 (STUDENT ACCOUNTS):                                    │
│      • Updated information                                     │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: STUDENT ACCOUNTS (write)                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 2.0: USER LEARNING MODULE**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 2.0: USER LEARNING MODULE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM STUDENTS:                                               │
│      • Menu selection (quarter/topic choice)                   │
│                                                                 │
│  PROCESSING:                                                    │
│    • Retrieve learning content based on selection              │
│    • Prepare module materials                                  │
│    • Format content for delivery                               │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENTS:                                                 │
│      • Module content                                          │
│    TO D2 (LEARNING CONTENT):                                    │
│      • Content access requests                                 │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: STUDENT ACCOUNTS (read - for menu selection)          │
│    • D2: LEARNING CONTENT (read)                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 3.0: QUIZ MANAGEMENT**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 3.0: QUIZ MANAGEMENT                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM D2 (LEARNING CONTENT):                                  │
│      • Quiz questions                                          │
│    FROM STUDENTS:                                               │
│      • Quiz answers                                            │
│                                                                 │
│  PROCESSING:                                                    │
│    • Deliver quiz to students                                  │
│    • Validate submitted answers                                │
│    • Calculate scores                                          │
│    • Generate quiz results                                     │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENTS:                                                 │
│      • Quiz questions                                          │
│    TO D3 (QUIZ RECORDS):                                        │
│      • Quiz results                                            │
│                                                                 │
│  DATA STORES:                                                   │
│    • D2: LEARNING CONTENT (read)                               │
│    • D3: QUIZ RECORDS (write)                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 4.0: MONITOR STUDENTS PROGRESS**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 4.0: MONITOR STUDENTS PROGRESS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM ADMIN:                                                  │
│      • Monitor progress requests                               │
│    FROM PROCESS 5.0:                                            │
│      • View scores data                                        │
│                                                                 │
│  PROCESSING:                                                    │
│    • Aggregate student performance data                        │
│    • Track progress over time                                  │
│    • Generate progress reports                                 │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO ADMIN:                                                    │
│      • View results (progress reports)                         │
│                                                                 │
│  DATA STORES:                                                   │
│    • D3: QUIZ RECORDS (read)                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 5.0: STUDENTS RESULTS**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 5.0: STUDENTS RESULTS                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM D3 (QUIZ RECORDS):                                      │
│      • Overall results                                         │
│                                                                 │
│  PROCESSING:                                                    │
│    • Retrieve student quiz results                             │
│    • Format results for display                                │
│    • Calculate statistics                                      │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENTS:                                                 │
│      • Score results                                           │
│    TO PROCESS 4.0:                                              │
│      • View scores (for monitoring)                            │
│                                                                 │
│  DATA STORES:                                                   │
│    • D3: QUIZ RECORDS (read)                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### **PROCESS 8.0: LOGIN AUTHENTICATION**

```
┌─────────────────────────────────────────────────────────────────┐
│  PROCESS 8.0: LOGIN AUTHENTICATION                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUTS:                                                        │
│    FROM STUDENTS:                                               │
│      • Login credentials (username/password)                   │
│    FROM ADMIN:                                                  │
│      • Login credentials                                       │
│                                                                 │
│  PROCESSING:                                                    │
│    • Validate credentials against database                     │
│    • Fetch user account data                                   │
│    • Generate authentication token                             │
│    • Determine login success/failure                           │
│                                                                 │
│  OUTPUTS:                                                       │
│    TO STUDENTS:                                                 │
│      • Login status (success/failure)                          │
│    TO D1 (STUDENT ACCOUNTS):                                    │
│      • Login status query                                      │
│    FROM D1 (STUDENT ACCOUNTS):                                  │
│      • Login status response                                   │
│                                                                 │
│  DATA STORES:                                                   │
│    • D1: STUDENT ACCOUNTS (read/write)                         │
│                                                                 │
│  CIRCULAR FLOW:                                                 │
│    1. Student → Process 8.0 (credentials)                      │
│    2. Process 8.0 → D1 (validate)                              │
│    3. D1 → Process 8.0 (status)                                │
│    4. Process 8.0 → Student (login status)                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 DATA STORES

```
┌──────────────────────────────────────────────────────────────────┐
│  D1: STUDENT ACCOUNTS                                            │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Student profiles, credentials, login status            │
│  Used by: Processes 1.0, 2.0, 8.0                               │
│  Operations: Read (authentication), Write (updates)             │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D2: LEARNING CONTENT                                            │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Quiz questions, learning materials, module content     │
│  Used by: Processes 2.0, 3.0                                    │
│  Operations: Read (content delivery)                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  D3: QUIZ RECORDS                                                │
│  ─────────────────────────────────────────────────────────────   │
│  Stores: Quiz results, scores, completion history              │
│  Used by: Processes 3.0, 4.0, 5.0                               │
│  Operations: Write (results), Read (monitoring/reporting)       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 COMPLETE DATA FLOW TABLE

| Flow # | From | To | Data | Description |
|--------|------|-----|------|-------------|
| 1 | Students | Process 8.0 | login credentials | Student submits username/password |
| 2 | Process 8.0 | D1 | authentication request | System validates credentials |
| 3 | D1 | Process 8.0 | login status | Database returns validation result |
| 4 | Process 8.0 | Students | login status | System informs student of success/failure |
| 5 | D1 | Process 2.0 | menu selection | Authenticated user's menu choice |
| 6 | Students | Process 2.0 | menu selection | Student selects quarter/topic |
| 7 | Process 2.0 | Students | module content | System delivers learning materials |
| 8 | D2 | Process 2.0 | module content | Content retrieved from database |
| 9 | D2 | Process 3.0 | Quiz | Quiz questions delivered |
| 10 | Process 3.0 | Students | Quiz | Quiz presented to student |
| 11 | Students | Process 3.0 | Quiz Answers | Student submits answers |
| 12 | Process 3.0 | D3 | Quiz Results | Results stored in database |
| 13 | D3 | Process 5.0 | overall results | Results retrieved for display |
| 14 | Process 5.0 | Students | score results | Student views their scores |
| 15 | Process 5.0 | Process 4.0 | view scores | Scores sent for monitoring |
| 16 | Process 4.0 | Admin | view results | Admin views progress reports |
| 17 | Admin | Process 4.0 | monitor progress | Admin requests progress data |
| 18 | Admin | Process 1.0 | edit information | Admin updates account info |
| 19 | Process 1.0 | D1 | updated information | Changes saved to database |

---

## 🎯 KEY CIRCULAR FLOWS

### **1. AUTHENTICATION CIRCULAR FLOW:**
```
┌─────────────┐
│  STUDENTS   │
└──────┬──────┘
       │ (1) login credentials
       ▼
┌──────────────────┐
│  PROCESS 8.0     │
│  LOGIN AUTH      │
└──────┬───────────┘
       │ (2) validate
       ▼
┌──────────────────┐
│  D1: STUDENT     │
│  ACCOUNTS        │
└──────┬───────────┘
       │ (3) login status
       ▼
┌──────────────────┐
│  PROCESS 8.0     │
│  LOGIN AUTH      │
└──────┬───────────┘
       │ (4) login status
       ▼
┌─────────────┐
│  STUDENTS   │
└─────────────┘
```

### **2. QUIZ TAKING FLOW:**
```
STUDENTS → (menu selection) → PROCESS 2.0 → (module content) → STUDENTS
                                    ↓
                              D2: LEARNING CONTENT
                                    ↓
                              PROCESS 3.0 (Quiz)
                                    ↓
STUDENTS ← (Quiz) ← PROCESS 3.0
STUDENTS → (Quiz Answers) → PROCESS 3.0 → D3: QUIZ RECORDS
```

### **3. RESULTS & MONITORING FLOW:**
```
D3: QUIZ RECORDS → PROCESS 5.0 → STUDENTS (score results)
                       ↓
                  PROCESS 4.0 → ADMIN (view results)
```

---

## 📋 LEGEND

```
┌─────────────────────────────────────────────────────────────────┐
│  SYMBOL LEGEND                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐                                                    │
│  │STUDENTS │  = External Entity (rectangle)                    │
│  └─────────┘                                                    │
│                                                                 │
│  ┌─────────┐                                                    │
│  │  X.0    │  = Process (rounded rectangle with number)        │
│  │ PROCESS │                                                    │
│  └─────────┘                                                    │
│                                                                 │
│  ┌─────────┐                                                    │
│  │ DX:NAME │  = Data Store (open rectangle)                    │
│  └─────────┘                                                    │
│                                                                 │
│      ───►     = Data Flow (arrow shows direction)              │
│                                                                 │
│      ◄───►    = Bidirectional Flow (data goes both ways)       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
