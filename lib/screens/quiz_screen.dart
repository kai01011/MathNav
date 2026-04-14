import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../data/questions_data.dart';

class QuizScreen extends StatefulWidget {
  final int quarter;
  final String topic;

  const QuizScreen({
    super.key,
    required this.quarter,
    required this.topic,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _score = 0;
  bool _quizCompleted = false;
  bool _isRemedialQuiz = false; // Track if this is a remedial quiz
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
    debugPrint(
        'QuizScreen initialized with quarter: ${widget.quarter}, topic: ${widget.topic}');
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    debugPrint('Loading questions from Firebase...');
    final questions =
        await QuestionsData.fetchQuestionsByTopic(widget.quarter, widget.topic);

    setState(() {
      _questions = questions;
      if (_questions.isNotEmpty) {
        _questions.shuffle();
      }
    });

    debugPrint('Loaded ${_questions.length} questions from Firebase');
  }

  Future<void> _loadRemedialQuestions() async {
    debugPrint('🔄 Loading remedial questions (difficulty 1 only)...');
    final allQuestions =
        await QuestionsData.fetchQuestionsByTopic(widget.quarter, widget.topic);

    debugPrint('📚 Total questions fetched: ${allQuestions.length}');

    // Debug: Print difficulty of each question
    for (var q in allQuestions) {
      debugPrint('Question: "${q.question}" - Difficulty: ${q.difficulty}');
    }

    // Filter for easy questions (difficulty 1) and take 7
    final easyQuestions = allQuestions.where((q) => q.difficulty == 1).toList();
    debugPrint('✅ Easy questions found: ${easyQuestions.length}');

    if (easyQuestions.isEmpty) {
      debugPrint('⚠️ No easy questions found! Using all questions instead.');
      easyQuestions.addAll(allQuestions);
    }

    easyQuestions.shuffle();

    setState(() {
      _questions = easyQuestions.take(7).toList();
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _score = 0;
      _quizCompleted = false;
      _isRemedialQuiz = true;
    });

    debugPrint('🎯 Loaded ${_questions.length} remedial questions');
  }

  Future<void> _initTts() async {
    try {
      // Get available voices
      var voices = await _flutterTts.getVoices;
      debugPrint('📢 Available voices: $voices');

      // Try to find a child or female voice for more natural sound
      if (voices != null && voices is List) {
        // Look for child voices or high-quality female voices
        var childVoice = voices.firstWhere(
          (voice) =>
              voice.toString().toLowerCase().contains('child') ||
              voice.toString().toLowerCase().contains('kid') ||
              voice.toString().toLowerCase().contains('young'),
          orElse: () => null,
        );

        // Try to find a female voice as fallback
        childVoice ??= voices.firstWhere(
          (voice) =>
              voice.toString().toLowerCase().contains('female') ||
              voice.toString().toLowerCase().contains('woman') ||
              voice.toString().toLowerCase().contains('girl'),
          orElse: () => null,
        );

        if (childVoice != null) {
          debugPrint('✅ Using voice: $childVoice');
          await _flutterTts
              .setVoice({"name": childVoice.toString(), "locale": "en-US"});
        }
      }

      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.48); // Natural speaking pace for kids
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.4); // Higher pitch for child-like voice

      // Platform-specific settings for better quality
      if (Platform.isAndroid) {
        await _flutterTts.setEngine("com.google.android.tts");
      }

      debugPrint('✅ TTS initialized with child-friendly settings');
    } catch (e) {
      debugPrint('❌ TTS init error: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      debugPrint('🔊 Speaking: $text');
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS error: $e');
    }
  }

  void _checkAnswer(int index) {
    bool isCorrect =
        index == _questions[_currentQuestionIndex].correctAnswerIndex;

    String question = _questions[_currentQuestionIndex].question;
    String correctAnswerText = _questions[_currentQuestionIndex]
        .options[_questions[_currentQuestionIndex].correctAnswerIndex];

    setState(() {
      _selectedAnswer = index;
      _showExplanation = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Extract the math expression from the question if it starts with "What is"
    String voiceText = "";
    if (question.toLowerCase().startsWith("what is")) {
      // Extract the expression (e.g., "1/2 + 1/2" from "What is 1/2 + 1/2?")
      String expression = question
          .replaceFirst(RegExp(r'what is ', caseSensitive: false), '')
          .replaceAll('?', '')
          .trim();

      if (isCorrect) {
        // Varied encouraging responses for correct answers
        List<String> correctPhrases = [
          "Awesome! You got it right!",
          "Fantastic! That's correct!",
          "Excellent work!",
          "You're a math star!",
          "Amazing! Well done!",
          "Super job!",
          "Brilliant!",
        ];
        String praise = (correctPhrases..shuffle()).first;
        voiceText = "$praise $expression equals $correctAnswerText";
      } else {
        // Encouraging responses for wrong answers
        List<String> wrongPhrases = [
          "Oops! Not quite.",
          "Nice try!",
          "Almost there!",
          "Good effort!",
        ];
        String encouragement = (wrongPhrases..shuffle()).first;
        voiceText =
            "$encouragement The correct answer is, $expression equals $correctAnswerText";
      }
    } else {
      // For other question types, just say the answer
      if (isCorrect) {
        List<String> correctPhrases = [
          "Yay! You're right!",
          "Perfect! That's correct!",
          "Wonderful!",
          "You nailed it!",
          "Great job!",
        ];
        String praise = (correctPhrases..shuffle()).first;
        voiceText = "$praise The answer is $correctAnswerText";
      } else {
        voiceText = "Good try! The correct answer is $correctAnswerText";
      }
    }

    // Convert fraction notation for better speech
    voiceText = _formatForSpeech(voiceText);

    // Use TTS to speak
    _speak(voiceText);
  }

  String _formatForSpeech(String text) {
    // Replace fractions like "1/2" with "one half", "3/4" with "three fourths", etc.
    text = text.replaceAllMapped(RegExp(r'(\d+)/(\d+)'), (match) {
      String numerator = match.group(1)!;
      String denominator = match.group(2)!;

      // Convert numbers to words
      Map<String, String> numbers = {
        '1': 'one',
        '2': 'two',
        '3': 'three',
        '4': 'four',
        '5': 'five',
        '6': 'six',
        '7': 'seven',
        '8': 'eight',
        '9': 'nine',
        '10': 'ten'
      };

      Map<String, String> denominators = {
        '2': 'half',
        '3': 'third',
        '4': 'fourth',
        '5': 'fifth',
        '6': 'sixth',
        '7': 'seventh',
        '8': 'eighth',
        '9': 'ninth',
        '10': 'tenth'
      };

      String numWord = numbers[numerator] ?? numerator;
      String denomWord = denominators[denominator] ?? denominator;

      // Handle plural denominators
      if (numerator != '1' && denominators.containsKey(denominator)) {
        denomWord = '${denomWord}s';
      }

      return '$numWord $denomWord';
    });

    return text;
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      // Save progress before completing
      _saveProgress();
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  Future<void> _saveProgress() async {
    try {
      // Get user info from SharedPreferences or auth
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson != null) {
        final userData = json.decode(userJson);
        await QuestionsData.saveQuizProgress(
          userId: userData['id'] ?? 'anonymous',
          studentEmail: userData['email'] ?? 'anonymous@example.com',
          quarter: widget.quarter,
          topic: widget.topic,
          score: _score,
          totalQuestions: _questions.length,
        );
        debugPrint('Progress saved successfully');
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _restartQuiz() {
    setState(() {
      _questions.shuffle();
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _score = 0;
      _quizCompleted = false;
      _isRemedialQuiz = false; // Reset remedial flag
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildQuizCompleted();
    }

    // Show loading if questions are not loaded yet
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.topic} Quiz'),
          backgroundColor: _getQuarterColor(widget.quarter),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading questions...'),
            ],
          ),
        ),
      );
    }

    Question currentQuestion = _questions[_currentQuestionIndex];
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Quiz'),
        backgroundColor: _getQuarterColor(widget.quarter),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getQuarterColor(widget.quarter).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getQuarterColor(widget.quarter),
              ),
            ),

            // Score and question counter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getQuarterColor(widget.quarter),
                    ),
                  ),
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Question card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Difficulty indicator
                        Row(
                          children: List.generate(3, (index) {
                            return Icon(
                              Icons.star,
                              size: 20,
                              color: index < currentQuestion.difficulty
                                  ? Colors.amber
                                  : Colors.grey[300],
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Question text
                        Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Options
                        ...List.generate(
                          currentQuestion.options.length,
                          (index) => _buildOption(index, currentQuestion),
                        ),

                        const Spacer(),

                        // Explanation (if answered)
                        if (_showExplanation) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Explanation:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(currentQuestion.explanation),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],

                        // Next button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _selectedAnswer != null ? _nextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getQuarterColor(widget.quarter),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _currentQuestionIndex < _questions.length - 1
                                  ? 'Next Question'
                                  : 'Finish Quiz',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, Question question) {
    bool isSelected = _selectedAnswer == index;
    bool isCorrect = index == question.correctAnswerIndex;

    Color? backgroundColor;
    if (_showExplanation) {
      if (isCorrect) {
        backgroundColor = Colors.green[100];
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[100];
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue[100];
    }

    return GestureDetector(
      onTap: _showExplanation ? null : () => _checkAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected && !_showExplanation
                ? Colors.blue
                : Colors.grey[300]!,
            width: isSelected && !_showExplanation ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected && !_showExplanation
                    ? Colors.blue
                    : Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: isSelected && !_showExplanation
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                question.options[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_showExplanation && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (_showExplanation && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCompleted() {
    double percentage = (_score / _questions.length) * 100;
    bool needsRemedial = percentage < 75 && !_isRemedialQuiz;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRemedialQuiz ? 'Practice Complete!' : 'Quiz Complete!'),
        backgroundColor: _getQuarterColor(widget.quarter),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    percentage >= 75
                        ? Icons.emoji_events
                        : (needsRemedial ? Icons.lightbulb : Icons.school),
                    size: 80,
                    color: percentage >= 75
                        ? Colors.amber
                        : (needsRemedial
                            ? Colors.orange
                            : _getQuarterColor(widget.quarter)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isRemedialQuiz ? 'Practice Completed!' : 'Quiz Completed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getQuarterColor(widget.quarter),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your Score: $_score/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: percentage >= 75 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (needsRemedial) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700, size: 30),
                          const SizedBox(height: 10),
                          Text(
                            'Let\'s Practice More!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try 7 easier questions to strengthen your understanding.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_isRemedialQuiz) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.blue.shade700, size: 30),
                          const SizedBox(height: 10),
                          Text(
                            'Great Practice!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You completed the practice questions. Ready to try the full quiz again?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  // Buttons row - shows 3 buttons if needs remedial, 2 if not
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Back',
                                style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                      if (needsRemedial)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              onPressed: _loadRemedialQuestions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Practice',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: _restartQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getQuarterColor(widget.quarter),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Try Again',
                                style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getQuarterColor(int quarter) {
    switch (quarter) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
