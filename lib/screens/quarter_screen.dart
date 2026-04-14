import 'package:flutter/material.dart';
import '../widgets/math_topic_card.dart';

class QuarterScreen extends StatelessWidget {
  final int quarter;
  final String title;
  final Color color;

  const QuarterScreen({
    super.key,
    required this.quarter,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.1), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _getTopicsForQuarter(),
        ),
      ),
    );
  }

  List<Widget> _getTopicsForQuarter() {
    switch (quarter) {
      case 1:
        return [
          const MathTopicCard(
            topic: 'Adding Simple Fractions Without Regrouping',
            icon: Icons.add_circle_outline,
            description:
                'Adding fractions with like denominators without regrouping',
            color: Colors.blue,
            quarter: 1, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Adding Simple Fractions With Regrouping in the Sum',
            icon: Icons.add,
            description: 'Adding fractions with regrouping in the sum',
            color: Colors.blue,
            quarter: 1, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic:
                'Adding Simple Fractions and Mixed Numbers With Regrouping in the Sum',
            icon: Icons.calculate,
            description: 'Adding fractions and mixed numbers with regrouping',
            color: Colors.blue,
            quarter: 1, // IMPORTANT: Pass the quarter number
          ),
        ];
      case 2:
        return [
          const MathTopicCard(
            topic: 'Fractions',
            icon: Icons.pie_chart,
            description:
                'Understanding fractions, equivalent fractions, and comparing fractions',
            color: Colors.green,
            quarter: 2, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Decimals',
            icon: Icons.percent,
            description: 'Introduction to decimals and decimal place value',
            color: Colors.green,
            quarter: 2, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Fraction Operations',
            icon: Icons.calculate,
            description:
                'Adding and subtracting fractions with like denominators',
            color: Colors.green,
            quarter: 2, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Decimal Operations',
            icon: Icons.money,
            description: 'Adding and subtracting decimals',
            color: Colors.green,
            quarter: 2, // IMPORTANT: Pass the quarter number
          ),
        ];
      case 3:
        return [
          const MathTopicCard(
            topic: 'Geometry',
            icon: Icons.shape_line,
            description: 'Lines, angles, and basic shapes',
            color: Colors.orange,
            quarter: 3, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Perimeter and Area',
            icon: Icons.square_foot,
            description: 'Calculating perimeter and area of basic shapes',
            color: Colors.orange,
            quarter: 3, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Volume',
            icon: Icons.cable,
            description: 'Understanding volume of rectangular prisms',
            color: Colors.orange,
            quarter: 3, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Coordinate Plane',
            icon: Icons.grid_on,
            description: 'Plotting points on a coordinate grid',
            color: Colors.orange,
            quarter: 3, // IMPORTANT: Pass the quarter number
          ),
        ];
      case 4:
        return [
          const MathTopicCard(
            topic: 'Ratios and Proportions',
            icon: Icons.compare_arrows,
            description: 'Understanding ratios and solving proportions',
            color: Colors.purple,
            quarter: 4, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Percentages',
            icon: Icons.percent,
            description: 'Introduction to percentages and applications',
            color: Colors.purple,
            quarter: 4, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Data and Statistics',
            icon: Icons.bar_chart,
            description: 'Reading graphs and basic data analysis',
            color: Colors.purple,
            quarter: 4, // IMPORTANT: Pass the quarter number
          ),
          const MathTopicCard(
            topic: 'Probability',
            icon: Icons.casino,
            description: 'Basic probability concepts',
            color: Colors.purple,
            quarter: 4, // IMPORTANT: Pass the quarter number
          ),
        ];
      default:
        return [];
    }
  }
}
