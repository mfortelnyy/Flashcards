import 'package:flutter/material.dart';
import 'views/deck_list.dart';


void main() async{
  runApp(const FlashCardsApp());
}


class FlashCardsApp extends StatelessWidget {
  const FlashCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeckList(),
    );
  }
}
