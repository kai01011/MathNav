# MathNav Admin Panel

React.js web application for managing MathNav quizzes with Firebase authentication.

## Setup Instructions

1. Install dependencies:
```bash
cd web-admin
npm install
```

2. Start the development server:
```bash
npm start
```

The app will open at http://localhost:3000

## Firebase Configuration

The app is configured with your Firebase project:
- Project ID: mathnav-69d41
- API Key: AIzaSyDqh5lPPnd7JozJnVRAmPdYQPB-o30lWSc

## Creating Admin User

To create an admin user, use Firebase Console:

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: mathnav-69d41
3. Navigate to Authentication > Users
4. Click "Add user"
5. Enter email and password
6. Use these credentials to login to the admin panel

## Features

### Overview Tab
- User statistics
- Total users count
- User management table

### Quiz Management Tab
- Create, edit, and delete quizzes
- Organize quizzes by quarters (Q1-Q4)
- Set difficulty levels (Easy, Medium, Hard)
- Manage topics and questions
- Multiple choice options with correct answer selection
- Add explanations for each question

### Progress Monitor Tab
- Track student quiz attempts
- View performance by quarter
- Monitor topic-specific performance
- Average score analytics
- Filter progress by quarter
- Detailed progress table with scores and dates

## Quiz Structure

The app supports 4 quarters:
- Quarter 1: Numbers and Operations
- Quarter 2: Fractions and Decimals
- Quarter 3: Geometry and Measurement
- Quarter 4: Ratios, Percentages, Data

Each quiz includes:
- Question text
- 4 multiple choice options
- Correct answer index
- Difficulty level (1-3 stars)
- Topic categorization
- Explanation for the answer

## Firestore Collections

The app uses these Firestore collections:
- `users` - User accounts
- `quizzes` - Quiz questions and answers
- `progress` - Student quiz completion records

## Build for Production

```bash
npm run build
```

This creates an optimized production build in the `build` folder.
