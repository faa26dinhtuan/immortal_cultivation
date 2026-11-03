import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../controllers/world_controller.dart';
import '../widgets/regional_map.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final _controller = WorldController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final hours = _controller.travelHours;
            final lastTravelHours = _controller.lastTravelHours;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: GameTheme.contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(GameTheme.gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(GameStrings.regionLabel, style: typography.labelLarge),
                            Text(GameStrings.regionName, style: typography.headlineLarge),
                            Text(GameStrings.clock(_controller.day, _controller.hour)),
                          ],
                        ),
                      ),
                      RegionalMap(
                        current: _controller.current,
                        selected: _controller.selected,
                        route: _controller.route,
                        onSelect: _controller.select,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(GameTheme.gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              GameStrings.currentPlace(_controller.current),
                              style: typography.labelLarge,
                            ),
                            Text(
                              GameStrings.placeName(_controller.selected),
                              style: typography.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(GameStrings.placeDescription(_controller.selected)),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: hours > 0 ? _controller.travel : null,
                              child: Text(
                                hours > 0 ? GameStrings.travel(hours) : GameStrings.alreadyHere,
                              ),
                            ),
                            if (lastTravelHours != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(GameStrings.arrival(
                                    _controller.current,
                                    lastTravelHours,
                                  )),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
