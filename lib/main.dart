import 'package:flash_cards/views/home_view.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
        title: 'Flash Cards',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
        ),
        home: HomeView());
  }
}
