import 'package:flutter/material.dart';

import 'core/theme/game_theme.dart';
import 'features/world/screens/world_screen.dart';
import 'l10n/game_strings.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: GameTheme.light,
      home: const WorldScreen(),
    );
  }
}
