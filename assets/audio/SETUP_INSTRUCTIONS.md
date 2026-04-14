# Audio Setup Instructions - Question-Specific Audio Files

## How to Assign MP3 Files to Specific Questions

You can now assign specific MP3 audio files to individual questions! Each audio file should contain the complete answer for that question.

### Example Setup

For the question "What is 1/2 + 1/2?":
- Your MP3 file should say: "Awesome! You got it right! One half plus one half equals one"
- Name it: `question_1.mp3`

For the question "Which fraction is equivalent to 1/2?":
- Your MP3 file should say: "Fantastic! That's correct! Two fourths"
- Name it: `question_2.mp3`

### Step 1: Record Your Audio Files

Record a child's voice saying the complete answer for each question:
- Include an encouraging phrase (e.g., "Awesome! You got it right!")
- Include the math expression and answer
- Keep it natural and enthusiastic!

### Step 2: Name Your Files

Currently, the first 2 questions have audio files assigned:
- Question 1 ("What is 1/2 + 1/2?") → `question_1.mp3`
- Question 2 ("Which fraction is equivalent to 1/2?") → `question_2.mp3`

### Step 3: Place Files in This Folder

Put your MP3 files in: `assets/audio/`

Your folder structure:
```
mathnav/
  assets/
    audio/
      question_1.mp3  ← Audio for "What is 1/2 + 1/2?"
      question_2.mp3  ← Audio for "Which fraction is equivalent to 1/2?"
      SETUP_INSTRUCTIONS.md
```

### Step 4: Assign Audio to More Questions (Optional)

To add audio to more questions, edit `lib/data/questions_data.dart`:

```dart
Question(
  quarter: 1,
  topic: 'Numbers and Number Sense',
  difficulty: 1,
  question: 'What is 3/4 - 1/4?',
  options: ['2/4', '1/2', '2/8', 'Both A and B'],
  correctAnswerIndex: 3,
  explanation: '3/4 - 1/4 = 2/4, which simplifies to 1/2. Both answers are correct!',
  audioFile: 'question_3.mp3', // Add this line!
),
```

Then create `question_3.mp3` with the answer for that question.

## How It Works

**When student answers CORRECTLY:**
- If the question has an `audioFile` assigned:
  - ✅ Plays the specific MP3 file for that question
  - ✅ Audio contains the complete answer (praise + math expression + answer)
  - ✅ No TTS needed!

- If the question has NO audio file:
  - 🔊 Uses TTS to speak an encouraging phrase + the answer

**When student answers WRONG:**
- Always uses TTS to say encouraging phrase + correct answer

## Audio File Requirements

- **Format**: MP3
- **Duration**: 2-5 seconds recommended
- **Quality**: 128kbps or higher
- **Content**: Complete answer including:
  1. Encouraging phrase ("Awesome! You got it right!")
  2. Math expression ("one half plus one half")
  3. Answer ("equals one")

## Example Audio Scripts

**For "What is 1/2 + 1/2?"**
> "Awesome! You got it right! One half plus one half equals one!"

**For "Which fraction is equivalent to 1/2?"**
> "Fantastic! That's correct! Two fourths is equivalent to one half!"

**For "What is 3/4 - 1/4?"**
> "Excellent work! Three fourths minus one fourth equals two fourths, or one half!"

## Testing

After placing your files:
1. Run: `flutter pub get`
2. Run: `flutter run`
3. Go to Quarter 1 → Numbers and Number Sense
4. Answer question 1 or 2 correctly
5. You should hear your recorded audio!

## Troubleshooting

**No audio playing?**
- Check file names match exactly (e.g., `question_1.mp3`)
- Make sure files are in `assets/audio/` folder
- Run `flutter pub get` after adding files
- Restart the app completely
- Check the debug console for error messages

**Audio plays but cuts off?**
- Make sure your audio file is complete
- Check the file isn't corrupted
- Try playing it in a media player first

**Want to remove audio from a question?**
- Remove the `audioFile: 'question_X.mp3',` line from the question
- Or set it to `audioFile: null,`
- The app will use TTS instead

## Adding Audio to All 10 Questions

The first quarter has 10 fraction questions. To add audio to all:

1. Create 10 MP3 files: `question_1.mp3` through `question_10.mp3`
2. Edit `lib/data/questions_data.dart`
3. Add `audioFile: 'question_X.mp3',` to each question
4. Place all files in `assets/audio/`

Questions without audio files will automatically use TTS!
