import 'package:flash_cards/services/stt_service.dart';
import 'package:flash_cards/services/tts_service.dart';
import 'package:flash_cards/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TTSService>(
          create: (_) => TTSService(),
        ),
        Provider<STTService>(
          create: (_) => STTService(),
        ),
      ],
      child: const CupertinoApp(
          title: 'Flash Cards',
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
          ),
          home: HomeView()),
    );
  }
}
