// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './../utils/database_helper.dart';
import './../models/deck.dart';
import './flashcard_list.dart';
import './../models/flashcard.dart';


class DeckList extends StatefulWidget {
  const DeckList({super.key});

  
  @override
  _DeckListState createState() => _DeckListState();
}
class _DeckListState extends State<DeckList> {
  void _editDeckName(BuildContext context, Deck deck) {
  String newDeckName = deck.name;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Deck Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                newDeckName = value;
              },
              controller: TextEditingController(text: deck.name),
              decoration: const InputDecoration(labelText: 'Deck Name'),
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
            onPressed: () {
              if (newDeckName.isNotEmpty) {
                final updatedDeck = deck.copy(name: newDeckName);
                DBHelper().updateDeck(updatedDeck);
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

void _loadDecksAndFlashcards() async {
    final String data = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(data);

    // Insert decks and get deckIds
    final Map<String, int> deckIdMap = {};

    for (var deckJson in jsonData) {
      final deck = Deck(name: deckJson['title']);
      final deckId = await DBHelper().insertDeck(deck);

      deckIdMap[deckJson['title']] = deckId;
    }

    // Insert flashcards and associate with decks
    for (var deckJson in jsonData) {
      final List<dynamic> flashcardsJson = deckJson['flashcards'];
      
      final deckId = deckIdMap[deckJson['title']];

      for (var flashcardJson in flashcardsJson) {
        final flashcard = Flashcard(
          question: flashcardJson['question'],
          answer: flashcardJson['answer'],
          deckId: deckId);
        
        await DBHelper().insertFlashcard(flashcard);
      }
    }
  }


void _addDeck() async{
      showDialog(
      context: context,
      builder: (context) {
        String deckName = '';
        return AlertDialog(
          title: const Text('Create New Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  deckName = value;
                },
                decoration: const InputDecoration(labelText: 'Deck Name'),
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
              onPressed: () {
                if (deckName.isNotEmpty) {
                  final newDeck = Deck(name: deckName);
                  DBHelper().insertDeck(newDeck);
                  setState((){});
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

Future<void> _removeDeck(Deck deck) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Deck'),
          content: Text('Are you sure you want to delete "${deck.name}" Deck? The change will be permanent.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DBHelper().removeDeck(deck);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download), 
            onPressed: () {
              _loadDecksAndFlashcards();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Deck>>(
        future: DBHelper().queryDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final decks = snapshot.data ?? [];
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return Card(
                  color: Colors.purple[100],
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FlashcardList(deckId: deck.id, deckName: deck.name),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Center(child: Text(deck.name, style: const TextStyle(fontSize: 18))),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                //print('Deck ${deck.name} edited');
                                _editDeckName(context, deck);
                              },
                            ),
                          ),
                          IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _removeDeck(deck);
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                  
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _addDeck();},
        child: const Icon(Icons.add),
      ),
    );
  }
}