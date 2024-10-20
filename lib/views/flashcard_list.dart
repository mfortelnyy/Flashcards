// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_const_constructors_in_immutables

import './../views/quiz';
import 'package:flutter/material.dart';
import './../models/flashcard.dart';
import './../utils/database_helper.dart';

class FlashcardList extends StatefulWidget {
  final int? deckId;
  final String deckName;

   FlashcardList({super.key, required this.deckId, required this.deckName});

  @override
  _FlashcardListState createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
bool isSorted = false;

Future<dynamic> addFlashcard(BuildContext context) {
    return showDialog(
    context: context,
    builder: (context) {
      String question = '';
      String answer = '';

      return AlertDialog(
        title: const Text('Create New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                question = value;
              },
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              onChanged: (value) {
                answer = value;
              },
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (question.isNotEmpty && answer.isNotEmpty) {
                final newFlashcard = Flashcard(
                  deckId: widget.deckId,
                  question: question,
                  answer: answer,
                );
                await DBHelper().insertFlashcard(newFlashcard);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
  }

void _editFlashcard(Flashcard flashcard) async {
    String editedQuestion = flashcard.question;
    String editedAnswer = flashcard.answer;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  editedQuestion = value;
                },
                controller: TextEditingController(text: flashcard.question),
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                onChanged: (value) {
                  editedAnswer = value;
                },
                controller: TextEditingController(text: flashcard.answer), 
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (editedQuestion.isNotEmpty && editedAnswer.isNotEmpty) {
                  final updatedFlashcard = flashcard.copy(
                    deckId: flashcard.deckId,
                    id: flashcard.id,
                    question: editedQuestion,
                    answer: editedAnswer,
                  );
                  DBHelper().updateFlashcard(updatedFlashcard);
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ); 
  }

void _removeFlashcard(Flashcard flashcard) {
      showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: Text('Are you sure you want to delete Flashcard Question:  "${flashcard.question}"  |  Answer: "${flashcard.answer}"  ?  The change will be permanent.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DBHelper().removeFlashcard(flashcard);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

}

void _toggleSortOrder() {
  setState(() {
    isSorted = !isSorted;
  });
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.deckName),
        actions: [
          IconButton(
            icon: Icon(isSorted ? Icons.sort_sharp : Icons.sort_by_alpha_sharp),
            onPressed: () => _toggleSortOrder(),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Quiz(deckId: widget.deckId),
                        ),
                      );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: DBHelper().queryFlashcards(widget.deckId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final flashcards = snapshot.data ?? [];
            if (isSorted) {
              flashcards.sort((a, b) {
              final aQuestion = a.question;
              final bQuestion = b.question;
              return aQuestion.compareTo(bQuestion);
              });
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                final flashcard = flashcards[index];
                return Card(
                  color: const Color.fromARGB(255, 73, 205, 223),
                  child: ListTile(
                    title: Center(child: Text(flashcard.question, style: const TextStyle(fontSize: 16),)),
                    trailing: Wrap(
                      children: <Widget>[
                      IconButton( 
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editFlashcard(flashcard),),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: ()  => _removeFlashcard(flashcard))
                      ],
                      
                      )
                  ), 
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    addFlashcard(context);
  },
  child: const Icon(Icons.add),
),

    );
  }


}