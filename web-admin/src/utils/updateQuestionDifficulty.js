import { collection, getDocs, updateDoc, doc } from 'firebase/firestore';
import { db } from '../firebase';

/**
 * Script to add difficulty field to existing questions in Firebase
 * This is needed for the remedial quiz feature to work
 */
export const updateQuestionDifficulty = async () => {
  try {
    console.log('🔄 Starting to update question difficulties...');
    
    const querySnapshot = await getDocs(collection(db, 'quizzes'));
    let updatedCount = 0;
    let skippedCount = 0;

    for (const docSnapshot of querySnapshot.docs) {
      const data = docSnapshot.data();
      
      // Skip if difficulty already exists
      if (data.difficulty !== undefined) {
        console.log(`⏭️ Skipping "${data.question}" - already has difficulty: ${data.difficulty}`);
        skippedCount++;
        continue;
      }

      // Determine difficulty based on question complexity
      let difficulty = 2; // Default to medium

      // Simple patterns for easy questions (same denominator, small numbers)
      const question = data.question || '';
      
      // Check for easy patterns
      if (
        question.includes('1/2 + 1/2') ||
        question.includes('1/4 + 1/4') ||
        question.includes('1/3 + 1/3') ||
        question.includes('1/5 + 2/5') ||
        question.includes('2/6 + 1/6') ||
        question.includes('3/8 + 2/8') ||
        question.includes('1/10 + 3/10') ||
        question.includes('2/7 + 3/7') ||
        question.includes('1/6 + 2/6')
      ) {
        difficulty = 1; // Easy
      }

      // Update the document
      await updateDoc(doc(db, 'quizzes', docSnapshot.id), {
        difficulty: difficulty
      });

      console.log(`✅ Updated "${data.question}" - Set difficulty to ${difficulty}`);
      updatedCount++;
    }

    console.log('='.repeat(50));
    console.log(`✅ Update complete!`);
    console.log(`   Updated: ${updatedCount} questions`);
    console.log(`   Skipped: ${skippedCount} questions (already had difficulty)`);
    console.log('='.repeat(50));

    return {
      success: true,
      updated: updatedCount,
      skipped: skippedCount,
      message: `Successfully updated ${updatedCount} questions`
    };
  } catch (error) {
    console.error('❌ Error updating difficulties:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

/**
 * Set all questions to a specific difficulty
 * Useful for testing
 */
export const setAllQuestionsDifficulty = async (difficulty) => {
  try {
    console.log(`🔄 Setting all questions to difficulty ${difficulty}...`);
    
    const querySnapshot = await getDocs(collection(db, 'quizzes'));
    let updatedCount = 0;

    for (const docSnapshot of querySnapshot.docs) {
      await updateDoc(doc(db, 'quizzes', docSnapshot.id), {
        difficulty: difficulty
      });
      updatedCount++;
    }

    console.log(`✅ Updated ${updatedCount} questions to difficulty ${difficulty}`);
    return {
      success: true,
      updated: updatedCount
    };
  } catch (error) {
    console.error('❌ Error:', error);
    return {
      success: false,
      error: error.message
    };
  }
};
