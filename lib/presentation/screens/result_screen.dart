import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String theme; // Le thème pour rejouer le même quiz
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  ResultScreen({
    required this.score,
    required this.total,
    required this.theme,
  }) {
    _logResult();
  }

  Future<void> _logResult() async {
    await analytics.logEvent(
      name: 'quiz_result',
      parameters: {
        'score': score,
        'total': total,
        'percentage': (score / total) * 100,
        'theme': theme,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  String getResultMessage() {
    double percentage = (score / total) * 100;
    if (percentage >= 80) return 'Excellent travail !';
    if (percentage >= 50) return 'Bon travail !';
    return 'Vous pouvez faire mieux !';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultat du Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Félicitations !',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Votre score : $score / $total',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                getResultMessage(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Retour',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(theme: theme), // Transmet le thème ici
                    ),
                  );
                },
                child: Text(
                  'Rejouer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
