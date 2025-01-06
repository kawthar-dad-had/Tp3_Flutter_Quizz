import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQuestion(Question question) async {
    await _firestore.collection('questions').doc(question.id).set(question.toFirestore());
  }

  Future<List<Question>> fetchQuestions() async {
    final querySnapshot = await _firestore.collection('questions').get();
    return querySnapshot.docs.map((doc) => Question.fromFirestore(doc.data())).toList();
  }

  Future<List<Question>> fetchQuestionsForUser(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('userId', isEqualTo: userId) // Filtrer par userId
        .get();

    return querySnapshot.docs
        .map((doc) => Question.fromFirestore(doc.data()))
        .toList();
  }
  Future<void> addQuestions() async {
    final uuid = Uuid();

    // Liste des questions à ajouter
    final List<Map<String, dynamic>> questions = [
      {
        "question": "Quel est le plus grand océan de la Terre ?",
        "answers": ["Océan Atlantique", "Océan Indien", "Océan Pacifique", "Océan Arctique"],
        "correctAnswer": "Océan Pacifique",
        "theme": "Géographie",
        "userId": "LIO9qPv9sGMB9epdAg43vjVpPn93"
      },
      {
        "question": "En quelle année la Première Guerre mondiale a-t-elle commencé ?",
        "answers": ["1912", "1914", "1916", "1918"],
        "correctAnswer": "1914",
        "theme": "Histoire",
        "userId": "1DVweG0qlWOw7oBuG1lTIbPeRfy2"
      },
      {
        "question": "Quel est l'organe principal du système nerveux central ?",
        "answers": ["Le cœur", "Les poumons", "Le cerveau", "Le foie"],
        "correctAnswer": "Le cerveau",
        "theme": "Biologie",
        "userId": "LIO9qPv9sGMB9epdAg43vjVpPn93"
      },
      {
        "question": "Qui a peint la Joconde ?",
        "answers": ["Leonardo da Vinci", "Vincent van Gogh", "Claude Monet", "Pablo Picasso"],
        "correctAnswer": "Leonardo da Vinci",
        "theme": "Art",
        "userId": "1DVweG0qlWOw7oBuG1lTIbPeRfy2"
      },
      {
        "question": "Quel est l'élément chimique dont le symbole est 'Fe' ?",
        "answers": ["Fer", "Fluor", "Phosphore", "Francium"],
        "correctAnswer": "Fer",
        "theme": "Chimie",
        "userId": "LIO9qPv9sGMB9epdAg43vjVpPn93"
      },
      {
        "question": "Quel est l'instrument principal de Beethoven ?",
        "answers": ["Le violon", "Le piano", "La flûte", "La guitare"],
        "correctAnswer": "Le piano",
        "theme": "Musique",
        "userId": "1DVweG0qlWOw7oBuG1lTIbPeRfy2"
      },
      {
        "question": "Quelle planète est surnommée la 'planète rouge' ?",
        "answers": ["Mars", "Jupiter", "Saturne", "Vénus"],
        "correctAnswer": "Mars",
        "theme": "Astronomie",
        "userId": "LIO9qPv9sGMB9epdAg43vjVpPn93"
      },
      {
        "question": "Quel est le premier élément du tableau périodique ?",
        "answers": ["Hélium", "Hydrogène", "Oxygène", "Carbone"],
        "correctAnswer": "Hydrogène",
        "theme": "Chimie",
        "userId": "1DVweG0qlWOw7oBuG1lTIbPeRfy2"
      },
      {
        "question": "Dans quel pays se trouve la Grande Muraille ?",
        "answers": ["Inde", "Chine", "Japon", "Corée du Sud"],
        "correctAnswer": "Chine",
        "theme": "Géographie",
        "userId": "LIO9qPv9sGMB9epdAg43vjVpPn93"
      },
      {
        "question": "Quel écrivain est connu pour avoir écrit 'Hamlet' ?",
        "answers": ["Charles Dickens", "William Shakespeare", "Mark Twain", "Victor Hugo"],
        "correctAnswer": "William Shakespeare",
        "theme": "Littérature",
        "userId": "1DVweG0qlWOw7oBuG1lTIbPeRfy2"
      }
    ]
    ;

    // Ajout des questions à Firestore
    for (final question in questions) {
      final docId = uuid.v4();
      await _firestore.collection('questions').doc(docId).set({
        "id": docId,
        ...question, // Ajoute tous les champs de la question
      });
      print('Question ajoutée : ${question["question"]}');
    }
  }

  Future<List<String>> getThemes() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('questions').get();
    final themes = querySnapshot.docs.map((doc) => doc['theme'] as String).toSet().toList();
    return themes;
  }

  Future<List<Question>> fetchQuestionsByTheme(String theme) async {
    final querySnapshot = theme == 'all'
        ? await FirebaseFirestore.instance.collection('questions').get()
        : await FirebaseFirestore.instance
        .collection('questions')
        .where('theme', isEqualTo: theme)
        .get();

    return querySnapshot.docs.map((doc) => Question.fromFirestore(doc.data())).toList();
  }

}
