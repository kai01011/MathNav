import { collection, addDoc, getDocs, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

// Sample quizzes to seed the database
const sampleQuizzes = [
  {
    quarter: 1,
    topic: 'Adding Simple Fractions Without Regrouping',
    difficulty: 1,
    question: 'What is 1/2 + 1/2?',
    options: ['1/4', '2/4', '1', '2/2'],
    correctAnswerIndex: 2,
    explanation: '1/2 + 1/2 = 2/2 = 1 whole',
    audioFile: 'question_1.mp3'
  },
  {
    quarter: 1,
    topic: 'Adding Simple Fractions Without Regrouping',
    difficulty: 1,
    question: 'Which fraction is equivalent to 1/2?',
    options: ['2/3', '2/4', '1/3', '3/4'],
    correctAnswerIndex: 1,
    explanation: '1/2 = 2/4 (multiply numerator and denominator by 2)'
  },
  {
    quarter: 1,
    topic: 'Adding Simple Fractions With Regrouping in the Sum',
    difficulty: 1,
    question: 'What is 345 + 267?',
    options: ['512', '602', '612', '622'],
    correctAnswerIndex: 2,
    explanation: '345 + 267 = 612 (300+200=500, 40+60=100, 5+7=12, total 612)'
  },
  {
    quarter: 2,
    topic: 'Fractions',
    difficulty: 1,
    question: 'What fraction of the circle is shaded? (1 part out of 4)',
    options: ['1/2', '1/3', '1/4', '3/4'],
    correctAnswerIndex: 2,
    explanation: '1 part out of 4 equal parts is 1/4'
  },
  {
    quarter: 2,
    topic: 'Decimals',
    difficulty: 1,
    question: 'What is 0.3 as a fraction?',
    options: ['3/10', '3/100', '1/3', '3/5'],
    correctAnswerIndex: 0,
    explanation: '0.3 means 3 tenths = 3/10'
  },
  {
    quarter: 3,
    topic: 'Geometry',
    difficulty: 1,
    question: 'How many sides does a hexagon have?',
    options: ['4', '5', '6', '8'],
    correctAnswerIndex: 2,
    explanation: 'A hexagon has 6 sides (hexa means 6)'
  },
  {
    quarter: 3,
    topic: 'Perimeter and Area',
    difficulty: 1,
    question: 'What is the perimeter of a square with side length 5 cm?',
    options: ['10 cm', '15 cm', '20 cm', '25 cm'],
    correctAnswerIndex: 2,
    explanation: 'Perimeter = 4 × side = 4 × 5 = 20 cm'
  },
  {
    quarter: 4,
    topic: 'Ratios',
    difficulty: 2,
    question: 'There are 3 apples and 5 oranges. What is the ratio of apples to oranges?',
    options: ['3:5', '5:3', '3:8', '5:8'],
    correctAnswerIndex: 0,
    explanation: 'Apples:oranges = 3:5'
  },
  {
    quarter: 4,
    topic: 'Percentages',
    difficulty: 2,
    question: 'What is 25% of 80?',
    options: ['20', '25', '30', '40'],
    correctAnswerIndex: 0,
    explanation: '25% = 1/4, 80 ÷ 4 = 20'
  }
];

export const seedQuizzes = async () => {
  try {
    console.log('Starting to seed quizzes...');
    
    for (const quiz of sampleQuizzes) {
      await addDoc(collection(db, 'quizzes'), {
        ...quiz,
        createdAt: new Date(),
        updatedAt: new Date()
      });
      console.log(`Added quiz: ${quiz.question}`);
    }
    
    console.log('Successfully seeded all quizzes!');
    return { success: true, count: sampleQuizzes.length };
  } catch (error) {
    console.error('Error seeding quizzes:', error);
    return { success: false, error: error.message };
  }
};

// Function to clear all quizzes (use with caution!)
export const clearAllQuizzes = async () => {
  try {
    const querySnapshot = await getDocs(collection(db, 'quizzes'));
    const deletePromises = querySnapshot.docs.map(doc => deleteDoc(doc.ref));
    await Promise.all(deletePromises);
    console.log('All quizzes cleared!');
    return { success: true };
  } catch (error) {
    console.error('Error clearing quizzes:', error);
    return { success: false, error: error.message };
  }
};




