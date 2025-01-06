class Question {
  final String id;
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final String theme;
  final String userId; // Ajout du champ userId

  Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.theme,
    required this.userId,
  });

  factory Question.fromFirestore(Map<String, dynamic> data) {
    return Question(
      id: data['id'],
      question: data['question'],
      answers: List<String>.from(data['answers']),
      correctAnswer: data['correctAnswer'],
      theme: data['theme'],
      userId: data['userId'], // Récupération du userId
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correctAnswer': correctAnswer,
      'theme': theme,
      'userId': userId, // Ajout du userId dans Firestore
    };
  }
}
