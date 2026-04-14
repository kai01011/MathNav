class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int quarter;
  final String topic;
  final int difficulty; // 1-3 (1=easy, 2=medium, 3=hard)
  final String? audioFile; // Optional: MP3 file name for this specific question

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.quarter,
    required this.topic,
    required this.difficulty,
    this.audioFile, // Optional audio file
  });
}
