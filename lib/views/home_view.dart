import 'package:flash_cards/widgets/filter_panel.dart';
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
  Map<String, bool> _typeFilters = {
    'noun': false,
    'verb': false,
    'adjective': false,
    'pronoun': false,
    'preposition': false,
    'phrase': false,
    'number': false,
    'time': false,
  };
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

    // Filter by learned and unlearned status
    if (_currentFilter == "all" || _currentFilter == "learned") {
      allWords.addAll(_learnedWords);
    }
    if (_currentFilter == "all" || _currentFilter == "unlearned") {
      allWords.addAll(_unlearnedWords);
    }

    // Further filter by type if any type filters are active
    bool hasActiveTypeFilter = _typeFilters.values.any((isActive) => isActive);
    if (hasActiveTypeFilter) {
      allWords = allWords.where((word) => _typeFilters[word.type] ?? false).toList();
    }

    // Finally, filter by the search query
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
        title: const Text('Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        message: SingleChildScrollView(
          child: FilterPanel(
            currentFilter: _currentFilter,
            typeFilters: _typeFilters,
            onApplyFilters: (String newFilter, Map<String, bool> newTypeFilters) {
              setState(() {
                _currentFilter = newFilter;
                _typeFilters = newTypeFilters;
                _filterWords();
              });
              Navigator.pop(context); // Close the panel after applying filters
            },
          ),
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
      CupertinoPageRoute(builder: (context) {
        // Pass unlearned words matching the current type filters to the LearningView
        List<Word> wordsToLearn = _unlearnedWords.where((word) => _typeFilters[word.type] ?? false).toList();
        return LearningView(words: wordsToLearn);
      }),
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
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...words.map((word) => WordTile(word: word, key: ValueKey(word.id))),
          ],
        ),
      ),
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
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(word.english, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                word.type,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        trailing: Icon(word.isLearned ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle),
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => SingleWordView(word: word)),
        ),
      ),
    );
  }
}
