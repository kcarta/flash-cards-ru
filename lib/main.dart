import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      child: MaterialApp(
        home: Builder(
          builder: (context) => const CupertinoApp(
            title: 'Flash Cards',
            localizationsDelegates: [
              // Required by Material widgets like showModalBottomSheet
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            theme: CupertinoThemeData(
              primaryColor: CupertinoColors.systemBlue,
            ),
            home: HomeView(),
          ),
        ),
      ),
    );
  }
}
