import 'package:flutter/material.dart';
import '../screens/quiz_screen.dart';
import '../services/quiz_service.dart';

class MathTopicCard extends StatelessWidget {
  final String topic;
  final IconData icon;
  final String description;
  final Color color;
  final int quarter; // Make sure this is here

  const MathTopicCard({
    super.key,
    required this.topic,
    required this.icon,
    required this.description,
    required this.color,
    required this.quarter, // Make sure this is here
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          _showTopicDetails(context);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopicDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the bottom sheet to be taller
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              icon,
              size: 60,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              topic,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Topics include:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._getSampleTopics().map(
              (topic) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 10),
                    Text(topic),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Show question count for this topic
            FutureBuilder<int>(
              future: _getQuestionCount(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${snapshot.data} questions available',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Navigate to quiz screen with the correct quarter and topic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        quarter: quarter, // Use the quarter from this widget
                        topic: topic, // Use the topic from this widget
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Start Learning'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get question count for this topic
  Future<int> _getQuestionCount() async {
    try {
      final quizService = QuizService();
      final questions = await quizService.fetchQuizzesByTopic(quarter, topic);
      return questions.length;
    } catch (e) {
      debugPrint('Error getting question count: $e');
      return 0;
    }
  }

  List<String> _getSampleTopics() {
    // These are just sample topics shown in the bottom sheet
    switch (topic) {
      case 'Adding Simple Fractions Without Regrouping':
        return [
          'Adding fractions with like denominators',
          'Simplifying fraction sums',
          'Comparing fractions',
          'Equivalent fractions'
        ];
      case 'Adding Simple Fractions With Regrouping in the Sum':
        return [
          'Adding fractions with regrouping',
          'Converting improper fractions',
          'Mixed number results',
          'Word problems'
        ];
      case 'Adding Simple Fractions and Mixed Numbers With Regrouping in the Sum':
        return [
          'Adding mixed numbers',
          'Regrouping in mixed numbers',
          'Converting between forms',
          'Word problems'
        ];
      case 'Fractions':
        return [
          'Equivalent fractions',
          'Comparing fractions',
          'Simplifying fractions',
          'Fractions on number line'
        ];
      case 'Decimals':
        return [
          'Decimal place value',
          'Comparing decimals',
          'Rounding decimals',
          'Decimals on number line'
        ];
      case 'Fraction Operations':
        return [
          'Adding fractions',
          'Subtracting fractions',
          'Like denominators',
          'Word problems'
        ];
      case 'Decimal Operations':
        return [
          'Adding decimals',
          'Subtracting decimals',
          'Money problems',
          'Word problems'
        ];
      case 'Geometry':
        return ['Shapes', 'Angles', 'Lines', 'Symmetry'];
      case 'Perimeter and Area':
        return [
          'Perimeter of shapes',
          'Area of rectangles',
          'Area of squares',
          'Word problems'
        ];
      case 'Volume':
        return [
          'Volume of cubes',
          'Volume of rectangular prisms',
          'Cubic units',
          'Word problems'
        ];
      case 'Coordinate Plane':
        return ['Plotting points', 'Ordered pairs', '4 quadrants', 'Grids'];
      case 'Ratios and Proportions':
        return [
          'Writing ratios',
          'Equivalent ratios',
          'Proportion problems',
          'Word problems'
        ];
      case 'Percentages':
        return [
          'Percent meaning',
          'Finding percentages',
          'Percent of a number',
          'Discounts'
        ];
      case 'Data and Statistics':
        return [
          'Bar graphs',
          'Line plots',
          'Mean, median, mode',
          'Data interpretation'
        ];
      case 'Probability':
        return [
          'Likelihood',
          'Possible outcomes',
          'Simple probability',
          'Experiments'
        ];
      default:
        return [
          'Practice problems',
          'Step-by-step solutions',
          'Interactive exercises',
          'Progress tracking'
        ];
    }
  }
}
