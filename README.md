# Sorting

To add a sort button to your `HomeView` and allow sorting of words based on different criteria, you can follow these steps:

1. Define a new state variable in `_HomeViewState` to keep track of the current sort order.
2. Implement a method `_sortWords` to sort `_filteredWords` based on the selected sort order.
3. Add a sort button to the `CupertinoNavigationBar`'s `trailing` widgets alongside the existing play button.
4. Show a `CupertinoActionSheet` or similar widget when the sort button is tapped, allowing the user to select the sort order.
5. Call `_sortWords` and update the UI accordingly when a sort order is selected.

Here's how you can integrate these changes into your code:

```dart
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
  String _currentFilter = "all";
  String _sortOrder = 'Alphabetical'; // New state variable for sort order

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
    if (_currentFilter == "all" || _currentFilter == "learned") {
      filteredWords.addAll(_learnedWords);
    }
    if (_currentFilter == "all" || _currentFilter == "unlearned") {
      filteredWords.addAll(_unlearnedWords);
    }

    filteredWords = filteredWords.where((word) => _typeFilters[word.type] ?? false).toList();

    String queryText = _searchController.text.toLowerCase();
    filteredWords = filteredWords
        .where((word) =>
            word.russian.toLowerCase().contains(queryText) ||
            word.english.toLowerCase().contains(queryText) ||
            Translit().toTranslit(source: word.russian).contains(queryText))
        .toList();

    _sortWords(filteredWords); // Call sort method after filtering
  }

  void _sortWords(List<Word> words) {
    switch (_sortOrder) {
      case 'Alphabetical':
        words.sort((a, b) => a.russian.compareTo(b.russian));
        break;
      case 'Reverse Alphabetical':
        words.sort((a, b) => b.russian.compareTo(a.russian));
        break;
      // Add more sorting criteria as needed
    }
    setState(() {
      _filteredWords = words;
    });
  }

  void _showSortOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Sort By'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('Alphabetical'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sortOrder = 'Alphabetical';
                _filterWords();
              });
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Reverse Alphabetical'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sortOrder = 'Reverse Alphabetical';
                _filterWords();
              });
            },
          ),
          // Add more sorting options here
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showSortOptions,
              child: const Icon(CupertinoIcons.sort_down, size: 30, color: CupertinoColors.activeBlue),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _startLearningSession,
              child: const Icon(CupertinoIcons.play_arrow_solid, size: 30, color: CupertinoColors.activeBlue),
            ),
          ],
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

  // Other methods remain unchanged
}
```

In this code, `_sortWords` sorts the words based on the `_sortOrder` state, which is updated when a user selects a sorting option. The `Row` widget in the `trailing` property of `CupertinoNavigationBar` houses both the sort and play buttons. Make sure to adjust your UI accordingly if the space is limited.

# Actions in Play
To make the play button in the `CupertinoNavigationBar` open a panel with several different options, you can modify the `_startLearningSession` method to show a `CupertinoActionSheet` (or similar widget) that presents the user with various options. Each option could represent a different type of learning session or activity.

Here's how you could adjust the `_startLearningSession` method to show an action sheet with multiple options:

```dart
Future<void> _startLearningSession() async {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Start Learning Session'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text('Flashcards'),
          onPressed: () async {
            Navigator.pop(context); // Close the action sheet
            await Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => WordView(words: _filteredWords, isFlashcardMode: true)),
            );
            _loadWords(); // Reload words after session ends
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Quiz'),
          onPressed: () {
            Navigator.pop(context); // Implement navigation to quiz view
            // TODO: Implement quiz session
          },
        ),
        // Add more options for different types of sessions or activities
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}
```

In this updated `_startLearningSession` method, the `CupertinoActionSheet` offers multiple options such as "Flashcards" and "Quiz". When the user selects an option, the action sheet is dismissed with `Navigator.pop(context)`, and the selected activity is started. For example, selecting "Flashcards" navigates to the `WordView` with `isFlashcardMode: true`, similar to your original method. You can add more options by adding additional `CupertinoActionSheetAction` widgets to the `actions` list.

Remember to implement the functionality for each option accordingly. For instance, the "Quiz" option in the example above has a placeholder comment where you should add the implementation for starting a quiz session.

# TODO

- Styling in card view
  - Rounded corners
  - Transparency down to the swipe background?
- Sorting in home view
  - A-Z Russian
  - A-Z English
  - Type
- Sorting the types by priority
- 
- Different activities
  - 