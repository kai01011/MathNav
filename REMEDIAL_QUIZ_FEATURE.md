# Remedial Quiz Feature

## Overview
When a student scores below 75% on a quiz, they are offered a remedial practice quiz with 7 easier questions to help strengthen their understanding before retrying the main quiz.

## How It Works

### 1. Quiz Completion
- Student completes a quiz on any topic
- System calculates the percentage score

### 2. Score Evaluation
- **Score ≥ 75%**: Student passes, sees congratulations screen with options to:
  - Go back to topics
  - Try the quiz again

- **Score < 75%**: Student needs more practice, sees:
  - Current score and percentage
  - Orange info box with message: "Let's Practice More!"
  - Explanation: "Try 7 easier questions to strengthen your understanding."
  - Three buttons:
    - **"Start Practice Questions"** (orange, prominent)
    - "Back to Topics" (gray)
    - "Try Again" (blue)

### 3. Remedial Quiz
When student clicks "Start Practice Questions":
- System loads 7 questions with difficulty level 1 (easy)
- Questions are from the same topic
- Questions focus on basic concepts with same denominators
- Student completes the practice quiz

### 4. After Remedial Quiz
- Student sees their practice score
- Blue info box with message: "Great Practice!"
- Explanation: "You completed the practice questions. Ready to try the full quiz again?"
- Options:
  - "Back to Topics"
  - "Try Again" (returns to full quiz)

## Question Difficulty Levels

### Difficulty 1 (Easy - Remedial)
- Same denominators only
- Simple addition (e.g., 1/4 + 1/4, 2/5 + 1/5)
- Basic fractions (halves, thirds, fourths, fifths, sixths, eighths, tenths)
- 9 questions available

### Difficulty 2 (Medium - Main Quiz)
- Different denominators requiring common denominator
- More complex fractions
- 5 questions available

## Benefits

1. **Adaptive Learning**: Students get targeted practice based on their performance
2. **Confidence Building**: Easier questions help students understand basics before tackling harder problems
3. **Mastery-Based**: Encourages students to master fundamentals
4. **No Penalty**: Remedial quiz doesn't affect their main quiz score
5. **Optional**: Students can choose to skip practice and retry the main quiz directly

## Technical Implementation

### Files Modified
- `lib/screens/quiz_screen.dart`: Added remedial quiz logic and UI
- `lib/data/questions_data.dart`: Added 8 easy (difficulty 1) questions

### Key Functions
- `_loadRemedialQuestions()`: Filters and loads 7 easy questions
- `_buildQuizCompleted()`: Shows appropriate UI based on score and quiz type
- `_isRemedialQuiz`: Boolean flag to track if current quiz is remedial

### Question Filtering
```dart
final easyQuestions = allQuestions.where((q) => q.difficulty == 1).toList();
easyQuestions.shuffle();
_questions = easyQuestions.take(7).toList();
```

## Future Enhancements

1. Track remedial quiz attempts in Firebase
2. Show progress over time
3. Adaptive difficulty based on multiple attempts
4. Personalized question recommendations
5. Gamification (badges for completing remedial quizzes)
