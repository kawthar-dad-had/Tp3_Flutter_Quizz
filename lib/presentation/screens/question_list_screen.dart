import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'add_question_screen.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/models/question_model.dart';

class QuestionListScreen extends StatefulWidget {
  @override
  _QuestionListScreenState createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final QuestionRepository _repository = QuestionRepository();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _logViewQuestionList();
    _fetchQuestions();
  }

  // Fonction pour enregistrer l'affichage de la liste des questions
  Future<void> _logViewQuestionList() async {
    await analytics.logEvent(
      name: 'view_question_list',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _fetchQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackbar('Erreur : Aucun utilisateur connecté.');
      return;
    }

    try {
      final questions = await _repository.fetchQuestionsForUser(user.uid);
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      _showSnackbar('Erreur lors du chargement des questions : ${e.toString()}');
    }
  }

  Future<void> _fillDatabase() async {
    try {
      await _repository.addQuestions();

      // Enregistrer l'événement de remplissage de la base de données
      await analytics.logEvent(
        name: 'fill_database',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _showSnackbar('Base de données remplie avec succès !');
      _fetchQuestions();
    } catch (e) {
      _showSnackbar('Erreur : ${e.toString()}');
    }
  }

  void _showChoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Que voulez-vous faire ?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.create, color: Colors.white),
                title: Text(
                  'Créer des questions',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/questions');
                },
              ),
              ListTile(
                leading: Icon(Icons.quiz, color: Colors.white),
                title: Text(
                  'Répondre à des questions',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/themes');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Questions'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _fetchQuestions,
          ),
          IconButton(
            icon: Icon(Icons.add_chart),
            tooltip: 'Remplir la base de données',
            onPressed: _fillDatabase,
          ),
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Afficher le choix des options',
            onPressed: () {
              _showChoiceModal(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
        padding: const EdgeInsets.all(16.0),
        child: _questions.isEmpty
            ? Center(
          child: Text(
            'Aucune question disponible.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            : ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: isLargeScreen ? 40 : 8,
              ),
              child: ListTile(
                title: Text(
                  question.question,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text('Thème: ${question.theme}'),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddQuestionScreen()),
          );

          // Enregistrer l'événement d'ajout de question
          await analytics.logEvent(
            name: 'add_question',
            parameters: {
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

          _fetchQuestions();
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Ajouter une question',
      ),
    );
  }
}
