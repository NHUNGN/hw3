import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<CardModel> cards = [];
  CardModel? firstSelectedCard;
  int? firstSelectedIndex;
  bool allowInteraction = true;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  // Initialize a list of cards with pairs of matching front designs
  void _initializeCards() {
    List<String> cardFaces = [
      '🍎', '🍌', '🍇', '🍉', '🍓', '🍒', '🍑', '🍍'
    ];
    cards = (cardFaces + cardFaces)
        .map((face) => CardModel(frontDesign: face, isFaceUp: false))
        .toList();
    cards.shuffle();
  }

  void _flipCard(int index) {
    if (!allowInteraction || cards[index].isFaceUp) return;

    setState(() {
      cards[index].isFaceUp = true;
    });

    if (firstSelectedCard == null) {
      // First card selection
      firstSelectedCard = cards[index];
      firstSelectedIndex = index;
    } else {
      // Second card selection
      allowInteraction = false; // Temporarily disable interaction during comparison

      if (firstSelectedCard!.frontDesign == cards[index].frontDesign) {
        // Cards match, keep them face-up
        _resetSelection();
      } else {
        // Cards don't match, flip them back after a short delay
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            cards[firstSelectedIndex!].isFaceUp = false;
            cards[index].isFaceUp = false;
            _resetSelection();
          });
        });
      }
    }
  }

  void _resetSelection() {
    firstSelectedCard = null;
    firstSelectedIndex = null;
    allowInteraction = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _flipCard(index),
            child: AnimatedCard(cardModel: cards[index]),
          );
        },
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final CardModel cardModel;

  AnimatedCard({required this.cardModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationYTransition(turns: animation, child: child);
      },
      child: cardModel.isFaceUp
          ? _buildFrontCard() // Display the front design if face-up
          : _buildBackCard(), // Display the back design if face-down
    );
  }

  Widget _buildFrontCard() {
    return Card(
      key: ValueKey(true),
      color: Colors.white,
      child: Center(
        child: Text(
          cardModel.frontDesign,
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      key: ValueKey(false),
      color: Colors.blueAccent,
      child: Center(
        child: Text(
          '?',
          style: TextStyle(fontSize: 48, color: Colors.white),
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;
  RotationYTransition({required Animation<double> turns, required this.child})
      : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final angle = animation.value * pi; // Convert the animation value into radians for rotation

    return Transform(
      transform: Matrix4.rotationY(angle),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class CardModel {
  final String frontDesign;
  bool isFaceUp;
  CardModel({required this.frontDesign, this.isFaceUp = false});
}
