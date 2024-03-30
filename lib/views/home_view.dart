import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import 'learning_view.dart';
import 'single_word_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final DatabaseService _dbService = DatabaseService();
  List<Word> _unlearnedWords = [];
  List<Word> _learnedWords = [];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final allWords = await _dbService.getAllWords();
    setState(() {
      _unlearnedWords = allWords.where((word) => !word.isLearned).toList();
      _learnedWords = allWords.where((word) => word.isLearned).toList();
    });
  }

  Future<void> _resetWords() async {
    await _dbService.reset();
    await _loadWords();
  }

  Future<void> _startLearningSession() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => LearningView(words: _unlearnedWords)),
    );
    _loadWords();
  }

  void _showSettingsMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Settings'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _resetWords();
            },
            child: const Text('Reset Words'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Russian Language Learning"),
        trailing: GestureDetector(
          onTap: _showSettingsMenu,
          child: const Icon(CupertinoIcons.settings, size: 30, color: CupertinoColors.systemGrey),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  WordsSection(title: 'Learned', words: _learnedWords),
                  WordsSection(title: 'Not Learned', words: _unlearnedWords),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton.filled(
                onPressed: _startLearningSession,
                child: const Text("Start Learning"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordsSection extends StatelessWidget {
  final String title;
  final List<Word> words;

  const WordsSection({required this.title, required this.words, super.key});

  @override
  Widget build(BuildContext context) {
    final groupedWords = groupWordsByType(words);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...groupedWords.entries.map((entry) => WordTypeSection(entry: entry)),
          ],
        ),
      ),
    );
  }

  Map<String, List<Word>> groupWordsByType(List<Word> words) {
    final Map<String, List<Word>> groupedWords = {};
    for (final word in words) {
      groupedWords.putIfAbsent(word.type, () => []).add(word);
    }
    return groupedWords;
  }
}

class WordTypeSection extends StatelessWidget {
  final MapEntry<String, List<Word>> entry;

  const WordTypeSection({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...entry.value.map((word) => WordTile(word: word, key: ValueKey(word.id))),
      ],
    );
  }
}

class WordTile extends StatelessWidget {
  final Word word;

  const WordTile({required this.word, super.key});

  @override
  Widget build(BuildContext context) {
    final TTSService ttsService = Provider.of<TTSService>(context);
    return Material(
      child: ListTile(
        leading: Icon(word.icon),
        title: Text(word.russian),
        subtitle: Text(word.english),
        trailing: CupertinoButton(
          onPressed: () async => await ttsService.speak(word.russian),
          child: const Icon(Icons.volume_up),
        ),
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => SingleWordView(word: word)),
        ),
      ),
    );
  }
}
