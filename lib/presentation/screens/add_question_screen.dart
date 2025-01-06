import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/models/question_model.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _themeController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _correctAnswerController = TextEditingController();
  final QuestionRepository _repository = QuestionRepository();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void dispose() {
    _questionController.dispose();
    _themeController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : Aucun utilisateur connecté.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        id: Uuid().v4(),
        question: _questionController.text,
        answers: _answerControllers.map((c) => c.text).toList(),
        correctAnswer: _correctAnswerController.text,
        theme: _themeController.text,
        userId: user.uid,
      );

      try {
        await _repository.addQuestion(newQuestion);

        // Enregistrement de l'événement d'ajout de question
        await analytics.logEvent(
          name: 'add_question',
          parameters: {
            'question_id': newQuestion.id,
            'theme': newQuestion.theme,
            'user_id': user.uid,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ajoutée avec succès !')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la question : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une question'),
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
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _questionController,
                  label: 'Question',
                  hint: 'Entrez votre question',
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _themeController,
                  label: 'Thème',
                  hint: 'Entrez le thème de la question',
                ),
                SizedBox(height: 16),
                ..._answerControllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildTextField(
                      controller: controller,
                      label: 'Réponse',
                      hint: 'Entrez une réponse',
                    ),
                  );
                }).toList(),
                _buildTextField(
                  controller: _correctAnswerController,
                  label: 'Réponse correcte',
                  hint: 'Entrez la réponse correcte',
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveQuestion,
                    child: Text('Ajouter la question'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
    );
  }
}
