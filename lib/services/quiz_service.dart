import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all quizzes from Firestore
  Future<List<Question>> fetchAllQuizzes() async {
    try {
      final querySnapshot = await _firestore.collection('quizzes').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
          explanation: data['explanation'] ?? '',
          quarter: data['quarter'] ?? 1,
          topic: data['topic'] ?? '',
          difficulty: data['difficulty'] ?? 1,
          audioFile: data['audioFile'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  // Fetch quizzes by quarter
  Future<List<Question>> fetchQuizzesByQuarter(int quarter) async {
    try {
      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('quarter', isEqualTo: quarter)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
          explanation: data['explanation'] ?? '',
          quarter: data['quarter'] ?? 1,
          topic: data['topic'] ?? '',
          difficulty: data['difficulty'] ?? 1,
          audioFile: data['audioFile'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching quizzes by quarter: $e');
      return [];
    }
  }

  // Fetch quizzes by quarter and topic
  Future<List<Question>> fetchQuizzesByTopic(int quarter, String topic) async {
    try {
      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('quarter', isEqualTo: quarter)
          .where('topic', isEqualTo: topic)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
          explanation: data['explanation'] ?? '',
          quarter: data['quarter'] ?? 1,
          topic: data['topic'] ?? '',
          difficulty: data['difficulty'] ?? 1,
          audioFile: data['audioFile'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching quizzes by topic: $e');
      return [];
    }
  }

  // Save quiz progress to Firestore
  Future<void> saveProgress({
    required String userId,
    required String studentEmail,
    required int quarter,
    required String topic,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      await _firestore.collection('progress').add({
        'userId': userId,
        'studentEmail': studentEmail,
        'quarter': quarter,
        'topic': topic,
        'score': ((score / totalQuestions) * 100).round(),
        'correctAnswers': score,
        'totalQuestions': totalQuestions,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  // Stream quizzes in real-time
  Stream<List<Question>> streamQuizzesByTopic(int quarter, String topic) {
    return _firestore
        .collection('quizzes')
        .where('quarter', isEqualTo: quarter)
        .where('topic', isEqualTo: topic)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          question: data['question'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
          explanation: data['explanation'] ?? '',
          quarter: data['quarter'] ?? 1,
          topic: data['topic'] ?? '',
          difficulty: data['difficulty'] ?? 1,
          audioFile: data['audioFile'],
        );
      }).toList();
    });
  }
}
