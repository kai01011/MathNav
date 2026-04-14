import '../models/question.dart';
import '../services/quiz_service.dart';

class QuestionsData {
  static final QuizService _quizService = QuizService();

  static List<Question> allQuestions = [
    Question(
      quarter: 1,
      topic: 'Adding Simple Fractions Without Regrouping',
      difficulty: 1,
      question: 'What is 1/2 + 1/2?',
      options: ['1/4', '2/4', '1', '2/2'],
      correctAnswerIndex: 2,
      explanation: '1/2 + 1/2 = 2/2 = 1 whole',
    ),
  ];

  static List<Question> getQuestionsByQuarter(int quarter) {
    return allQuestions.where((q) => q.quarter == quarter).toList();
  }

  static List<Question> getQuestionsByTopic(int quarter, String topic) {
    return allQuestions.where((q) => q.quarter == quarter && q.topic == topic).toList();
  }

  static List<Question> getRandomQuestions(int quarter, int count) {
    List<Question> quarterQuestions = getQuestionsByQuarter(quarter);
    quarterQuestions.shuffle();
    return quarterQuestions.take(count).toList();
  }

  static Future<List<Question>> fetchQuestionsByQuarter(int quarter) async {
    try {
      final questions = await _quizService.fetchQuizzesByQuarter(quarter);
      if (questions.isNotEmpty) {
        return questions;
      }
      return getQuestionsByQuarter(quarter);
    } catch (e) {
      return getQuestionsByQuarter(quarter);
    }
  }

  static Future<List<Question>> fetchQuestionsByTopic(int quarter, String topic) async {
    try {
      final questions = await _quizService.fetchQuizzesByTopic(quarter, topic);
      if (questions.isNotEmpty) {
        return questions;
      }
      return getQuestionsByTopic(quarter, topic);
    } catch (e) {
      return getQuestionsByTopic(quarter, topic);
    }
  }

  static Stream<List<Question>> streamQuestionsByTopic(int quarter, String topic) {
    return _quizService.streamQuizzesByTopic(quarter, topic);
  }

  static Future<void> saveQuizProgress({
    required String userId,
    required String studentEmail,
    required int quarter,
    required String topic,
    required int score,
    required int totalQuestions,
  }) async {
    await _quizService.saveProgress(
      userId: userId,
      studentEmail: studentEmail,
      quarter: quarter,
      topic: topic,
      score: score,
      totalQuestions: totalQuestions,
    );
  }
}





