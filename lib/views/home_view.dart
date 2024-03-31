import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
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
  List<Word> _filteredWords = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = "all"; // New filter state definition

  @override
  void initState() {
    super.initState();
    _loadWords();
    _searchController.addListener(_filterWords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final allWords = await _dbService.getAllWords();
    setState(() {
      _unlearnedWords = allWords.where((word) => !word.isLearned).toList();
      _learnedWords = allWords.where((word) => word.isLearned).toList();
      _filterWords();
    });
  }

  void _filterWords() {
    final query = _searchController.text.toLowerCase();
    List<Word> allWords = [];
    if (_currentFilter == "all" || _currentFilter == "learned") {
      allWords.addAll(_learnedWords);
    }
    if (_currentFilter == "all" || _currentFilter == "unlearned") {
      allWords.addAll(_unlearnedWords);
    }
    setState(() {
      _filteredWords = allWords
          .where((word) => word.russian.toLowerCase().contains(query) || word.english.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showFilterPanel() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Filters'),
        message: Column(
          children: [
            CupertinoSegmentedControl<String>(
              padding: const EdgeInsets.all(8.0),
              children: const {
                "all": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust horizontal padding as needed
                  child: Text('All', maxLines: 1),
                ),
                "learned": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust horizontal padding as needed
                  child: Text('Learned', maxLines: 1),
                ),
                "unlearned": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust horizontal padding as needed
                  child: Text('Not Learned', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              },
              onValueChanged: (String value) {
                setState(() {
                  _currentFilter = value;
                  _filterWords();
                });
                Navigator.pop(context);
              },
              groupValue: _currentFilter,
            ),
          ],
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Russian Language Learning"),
        leading: GestureDetector(
          onTap: _showSettingsMenu,
          child: const Icon(CupertinoIcons.settings, size: 30, color: CupertinoColors.systemGrey),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _startLearningSession,
          child: const Icon(CupertinoIcons.play_arrow_solid, size: 30, color: CupertinoColors.activeBlue),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search Words',
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 8.0),
                    onPressed: _showFilterPanel,
                    child: const Icon(CupertinoIcons.slider_horizontal_3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  WordsSection(title: 'Words', words: _filteredWords),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    return Material(
      child: ListTile(
        leading: Icon(word.icon),
        title: Text(word.russian),
        subtitle: Text(word.english),
        trailing: Icon(word.isLearned ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle),
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => SingleWordView(word: word)),
        ),
      ),
    );
  }
}
