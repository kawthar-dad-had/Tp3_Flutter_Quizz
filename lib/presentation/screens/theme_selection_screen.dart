import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/repositories/question_repository.dart';
import '../../main.dart';
import 'quiz_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  final QuestionRepository _repository = QuestionRepository();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  String? _preferredTheme; // Stocke le thème préféré

  @override
  void initState() {
    super.initState();
    _loadPreferredTheme();
  }

  Future<void> _loadPreferredTheme() async {
    // Charger le thème préféré (logique personnalisée)
    setState(() {
      _preferredTheme = null; // Remplacez par votre méthode de récupération si nécessaire
    });
  }

  Future<void> _setPreferredTheme(String theme) async {
    setState(() {
      _preferredTheme = theme;
    });

    await analytics.setUserProperty(name: 'preferred_theme', value: theme);
    await analytics.logEvent(
      name: 'preferred_theme_set',
      parameters: {
        'theme': theme,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thème "$theme" défini comme préféré !')),
    );
  }

  Future<void> _logThemeSelection(String theme) async {
    await analytics.logEvent(
      name: 'theme_selected',
      parameters: {
        'theme': theme,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.create, color: Colors.white),
                title: Text(
                  'Créer des questions',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Ferme le modal
                  Navigator.pushReplacementNamed(context, '/questions');
                },
              ),
              ListTile(
                leading: Icon(Icons.quiz, color: Colors.white),
                title: Text(
                  'Répondre à des questions',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Ferme le modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choix de la thématique'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on), // Icône d'éclair pour le mode SHOOT
            tooltip: 'Mode SHOOT',
            onPressed: () => startShootMode(context, _preferredTheme),
          ),
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Afficher les options',
            onPressed: () {
              _showChoiceModal(context);
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
        child: FutureBuilder<List<String>>(
          future: _repository.getThemes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Aucune thématique disponible.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final themes = snapshot.data!;

            return ListView.builder(
              itemCount: themes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.quiz, color: Theme.of(context).primaryColor),
                      title: Text(
                        'Répondre à toutes les questions',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      onTap: () async {
                        await _logThemeSelection('all');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(theme: 'all'),
                          ),
                        );
                      },
                    ),
                  );
                }
                final theme = themes[index - 1];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: Icon(Icons.category, color: Theme.of(context).colorScheme.secondary),
                    title: Text(
                      theme,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await _logThemeSelection(theme);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(theme: theme),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: _preferredTheme == theme ? Colors.red : Colors.grey,
                      ),
                      tooltip: 'Définir comme thème préféré',
                      onPressed: () async {
                        await _setPreferredTheme(theme);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
