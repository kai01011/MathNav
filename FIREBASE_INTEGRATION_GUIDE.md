# Firebase Integration Guide - MathNav

## Overview
The MathNav app now fetches quizzes from Firebase Firestore in real-time, allowing admins to create and manage quizzes through the web admin panel.

## Changes Made

### 1. New Quiz Service (`lib/services/quiz_service.dart`)
- Fetches quizzes from Firestore collection `quizzes`
- Supports filtering by quarter and topic
- Real-time streaming of quiz updates
- Saves student progress to `progress` collection

### 2. Updated Questions Data (`lib/data/questions_data.dart`)
- Added `fetchQuestionsByQuarter()` - Fetches from Firebase with fallback
- Added `fetchQuestionsByTopic()` - Fetches specific topic questions
- Added `streamQuestionsByTopic()` - Real-time quiz updates
- Added `saveQuizProgress()` - Saves completion data
- Keeps hardcoded questions as fallback if Firebase fails

### 3. Updated Quiz Screen (`lib/screens/quiz_screen.dart`)
- Loads questions asynchronously from Firebase
- Shows loading indicator while fetching
- Automatically saves progress when quiz completes
- Tracks user email and score in Firestore

### 4. Updated User Model (`lib/models/user.dart`)
- Added `id` field for tracking progress

## Firestore Collections

### Collection: `quizzes`
```json
{
  "quarter": 1,
  "topic": "Numbers and Number Sense",
  "difficulty": 1,
  "question": "What is 1/2 + 1/2?",
  "options": ["1/4", "2/4", "1", "2/2"],
  "correctAnswerIndex": 2,
  "explanation": "1/2 + 1/2 = 2/2 = 1 whole",
  "audioFile": "question_1.mp3",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Collection: `progress`
```json
{
  "userId": "user123",
  "studentEmail": "student@example.com",
  "quarter": 1,
  "topic": "Numbers and Number Sense",
  "score": 80,
  "correctAnswers": 8,
  "totalQuestions": 10,
  "completedAt": "2024-01-01T00:00:00Z"
}
```

## How It Works

1. **Admin Creates Quiz** (Web Admin Panel)
   - Admin logs into web-admin panel
   - Creates quiz with quarter, topic, questions
   - Quiz is saved to Firestore `quizzes` collection

2. **Student Takes Quiz** (Flutter App)
   - Student selects quarter and topic
   - App fetches questions from Firestore
   - If Firebase fails, uses hardcoded fallback questions
   - Student completes quiz

3. **Progress Tracking**
   - Quiz completion automatically saves to `progress` collection
   - Admin can view progress in Progress Monitor tab
   - Shows scores, completion dates, and performance analytics

## Testing

### Test Firebase Connection:
1. Run the Flutter app
2. Select any quarter and topic
3. Check console logs for "Loading questions from Firebase..."
4. If successful, you'll see "Loaded X questions from Firebase"

### Test Admin Panel:
1. Create a quiz in web-admin
2. Refresh Flutter app
3. Select the same quarter/topic
4. New quiz should appear

### Test Progress Tracking:
1. Complete a quiz in Flutter app
2. Check web-admin Progress Monitor tab
3. Your score should appear in the table

## Fallback Mechanism

The app includes a smart fallback system:
- If Firebase is unreachable → Uses hardcoded questions
- If Firebase returns empty → Uses hardcoded questions
- If Firebase has questions → Uses Firebase questions

This ensures the app always works, even offline!

## Firebase Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Quizzes - Read by anyone, write by admins only
    match /quizzes/{quizId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Progress - Write by authenticated users, read by admins
    match /progress/{progressId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // Users - Read/write by authenticated users
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Next Steps

1. Set up Firebase Security Rules (see above)
2. Create admin user in Firebase Console
3. Start creating quizzes in web-admin panel
4. Test quiz fetching in Flutter app
5. Monitor student progress in admin panel
