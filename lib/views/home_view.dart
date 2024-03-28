import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import 'learning_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DatabaseService dbService = DatabaseService();
  List<Word> unlearnedWords = [];
  List<Word> learnedWords = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() async {
    var allWords = await dbService.getAllWords();
    setState(() {
      unlearnedWords = allWords.where((word) => !word.isLearned).toList();
      learnedWords = allWords.where((word) => word.isLearned).toList();
    });
  }

  void _startLearningSession() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => LearningView(words: unlearnedWords)),
    );
    _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Russian Flashcards'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildWordsSection('Learned Words', learnedWords),
                  _buildWordsSection('Unlearned Words', unlearnedWords),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton.filled(
                onPressed: _startLearningSession,
                child: const Text('Start Learning'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton.filled(
                onPressed: _resetWords,
                child: const Text('RESET WORDS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsSection(String title, List<Word> words) {
    return SliverToBoxAdapter(
      child: Container(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...words.map((word) => Material(
                  child: ListTile(
                    title: Text(word.russian),
                    subtitle: Text(word.english),
                    trailing: Icon(word.isLearned
                        ? CupertinoIcons.check_mark_circled
                        : CupertinoIcons.circle),
                  ),
                )),
          ])),
    );
  }

  // Reset the words in the database.
  void _resetWords() async {
    await dbService.reset();
    _loadWords();
    // Reload the view
    setState(() {});
  }
}
