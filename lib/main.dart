import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:quizz/presentation/screens/quiz_screen.dart';
import 'package:quizz/presentation/screens/theme_selection_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/question_list_screen.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: _buildThemeData(),
      navigatorObservers: [observer],
      home: _buildHomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/questions': (context) => QuestionListScreen(),
        '/themes': (context) => ThemeSelectionScreen(),
        '/quiz': (context) => QuizScreen(theme: 'all'),
      },
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: const Color(0xFF6A1B9A),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF757575),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF6A1B9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF6A1B9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
        prefixIconColor: const Color(0xFF6A1B9A),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFFFFCA28)),
    );
  }

  Widget _buildHomeScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          analytics.logEvent(
            name: 'view_question_list',
            parameters: {'timestamp': DateTime.now().toIso8601String()},
          );
          return QuestionListScreen();
        }
        return LoginScreen();
      },
    );
  }
}

void startShootMode(BuildContext context, String? preferredTheme) {
  if (preferredTheme == null || preferredTheme.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez définir un thème préféré avant de démarrer le mode SHOOT !')),
    );
    return;
  }

  analytics.logEvent(
    name: 'shoot_mode_started',
    parameters: {
      'theme': preferredTheme,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizScreen(theme: preferredTheme),
    ),
  );
}
