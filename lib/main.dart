import 'package:flutter/material.dart';

import 'core/theme/game_theme.dart';
import 'data/local/game_save_repository.dart';
import 'features/world/controllers/world_controller.dart';
import 'features/world/screens/world_screen.dart';
import 'l10n/game_strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(repository: GameSaveRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({this.repository, super.key});

  final GameSaveRepository? repository;

  @override
  Widget build(BuildContext context) {
    final saves = repository;
    return MaterialApp(
      title: GameStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: GameTheme.light,
      home: saves == null ? const WorldScreen() : _LoadGame(repository: saves),
    );
  }
}

class _LoadGame extends StatefulWidget {
  const _LoadGame({required this.repository});

  final GameSaveRepository repository;

  @override
  State<_LoadGame> createState() => _LoadGameState();
}

class _LoadGameState extends State<_LoadGame> {
  late Future<WorldController> _load = _loadController();

  Future<WorldController> _loadController() async {
    final snapshot = await widget.repository.load();
    return WorldController(snapshot: snapshot, repository: widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorldController>(
      future: _load,
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller != null) return WorldScreen(controller: controller);

        return Scaffold(
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(GameStrings.loadFailed),
                      FilledButton(
                        onPressed: () => setState(() => _load = _loadController()),
                        child: const Text(GameStrings.retry),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(
                    semanticsLabel: GameStrings.loadingSave,
                  ),
          ),
        );
      },
    );
  }
}
