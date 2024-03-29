import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final TTSService _ttsService = TTSService();
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

  Map<String, List<Word>> _groupWordsByType(List<Word> words) {
    final Map<String, List<Word>> groupedWords = {};
    for (final word in words) {
      groupedWords.putIfAbsent(word.type, () => []).add(word);
    }
    return groupedWords;
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
            _buildWordLists(),
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

  Widget _buildWordLists() {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          _buildWordsSection('Learned', _learnedWords),
          _buildWordsSection('Not Learned', _unlearnedWords),
        ],
      ),
    );
  }

  Widget _buildWordsSection(String title, List<Word> words) {
    final groupedWords = _groupWordsByType(words);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...groupedWords.entries.map(_buildWordTypeSection),
          ],
        ),
      ),
    );
  }

  Widget _buildWordTypeSection(MapEntry<String, List<Word>> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.key, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...entry.value.map(_buildWordTile),
      ],
    );
  }

  Widget _buildWordTile(Word word) {
    return Material(
      child: ListTile(
        leading: Icon(word.icon),
        title: Text(word.russian),
        subtitle: Text(word.english),
        trailing: CupertinoButton(
          onPressed: () => _ttsService.speak(word.russian),
          child: const Icon(Icons.volume_up),
        ),
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => SingleWordView(word: word)),
        ),
      ),
    );
  }

  void _showSettingsMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Settings'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDestructiveAction: true, // Optional: styles the action as destructive
            onPressed: () {
              Navigator.pop(context); // Close the menu
              _resetWords(); // Call your reset words method
            },
            child: const Text('Reset Words'),
          ),
          // Add more actions here if needed
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context); // Close the menu without doing anything
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
