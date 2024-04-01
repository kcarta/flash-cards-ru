import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:translit/translit.dart';
import 'word_view.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import '../widgets/filter_panel.dart';

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
  Map<String, bool> _typeFilters = {};
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
      // If needed, Initialize type filters with all types present in the words lists, set to true
      if (_typeFilters.isEmpty) {
        _typeFilters = {
          for (var type in {..._learnedWords.map((e) => e.type), ..._unlearnedWords.map((e) => e.type)}) type: true
        };
      }
      _filterWords();
    });
  }

  void _filterWords() {
    List<Word> filteredWords = [];
    // Filter by learned and unlearned status
    if (_currentFilter == "all" || _currentFilter == "learned") {
      filteredWords.addAll(_learnedWords);
    }
    if (_currentFilter == "all" || _currentFilter == "unlearned") {
      filteredWords.addAll(_unlearnedWords);
    }

    // Filter by type
    filteredWords = filteredWords.where((word) => _typeFilters[word.type] ?? false).toList();

    String queryText = _searchController.text.toLowerCase();
    // Filter by the search query
    filteredWords = filteredWords
        .where((word) =>
            word.russian.toLowerCase().contains(queryText) ||
            word.english.toLowerCase().contains(queryText) ||
            Translit().toTranslit(source: word.russian).contains(queryText))
        .toList();

    setState(() {
      _filteredWords = filteredWords;
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
                  WordsSection(words: _filteredWords),
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
        return WordView(words: _filteredWords, isFlashcardMode: true);
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
  final List<Word> words;

  const WordsSection({required this.words, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: CupertinoColors.systemGrey5,
            height: 1,
            thickness: 1,
          ),
          ...words.map((word) => WordTile(word: word, key: ValueKey(word.id))),
        ],
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
          CupertinoPageRoute(builder: (context) => WordView(words: [word], isFlashcardMode: false)),
        ),
      ),
    );
  }
}
