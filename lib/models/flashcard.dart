class Flashcard {
  int? id;
  String question;
  String answer;
  int? deckId;

  Flashcard({
    this.id,
    required this.question,
    required this.answer,
    this.deckId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'deckId': deckId,
    };
  }

  Flashcard copy({int? id, String? answer, String? question, int? deckId}) {
    return Flashcard(
      id: id ?? this.id,
      answer: answer ?? this.answer,
      question: question ?? this.question,
      deckId: deckId ?? this.deckId
    );
  }
}