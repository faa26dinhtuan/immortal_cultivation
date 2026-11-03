import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../../cultivation/widgets/cultivation_sheet.dart';
import '../controllers/world_controller.dart';
import '../widgets/flood_event_dialog.dart';
import '../widgets/regional_map.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final _controller = WorldController();
  bool _showDestination = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _travel() async {
    if (_controller.beginTravel()) {
      final choice = await showDialog<FloodChoice>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FloodEventDialog(),
      );
      if (!mounted) return;
      _controller.resolveFlood(choice);
      if (choice == null) return;
    }
    setState(() => _showDestination = false);
  }

  void _openCultivation() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => CultivationSheet(controller: _controller),
    );
  }

  void _openJournal() {
    final entries = _controller.journal.toList(growable: false);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(GameStrings.journal, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (entries.isEmpty) const Text(GameStrings.emptyJournal),
            for (final entry in entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(GameStrings.arrival(entry.place, entry.hours)),
                subtitle: Text(GameStrings.travelLogDetail(entry)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final hours = _controller.travelHours;
          return Stack(
            fit: StackFit.expand,
            children: [
              RegionalMap(
                current: _controller.current,
                selected: _controller.selected,
                route: _showDestination ? _controller.route : const [],
                onSelect: (place) {
                  setState(() => _showDestination = true);
                  _controller.select(place);
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  bottom: false,
                  minimum: const EdgeInsets.all(12),
                  child: _MapPanel(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(GameStrings.regionName, style: typography.titleLarge),
                              Text(GameStrings.currentPlace(_controller.current)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(GameStrings.clock(_controller.day, _controller.hour)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_showDestination)
                          _MapPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        GameStrings.placeName(_controller.selected),
                                        style: typography.titleMedium,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: GameStrings.closeDestination,
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(() => _showDestination = false),
                                    ),
                                  ],
                                ),
                                Text(GameStrings.placeDescription(_controller.selected)),
                                const SizedBox(height: 8),
                                FilledButton(
                                  onPressed: hours == 0 ? null : _travel,
                                  child: Text(hours == 0 ? GameStrings.alreadyHere : GameStrings.travel(hours)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _openCultivation,
                              icon: Image.asset(
                                'assets/icons/ui/meditation.png',
                                width: 24,
                                height: 24,
                                excludeFromSemantics: true,
                              ),
                              label: const Text(GameStrings.cultivation),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _openJournal,
                              icon: const Icon(Icons.menu_book_outlined),
                              label: const Text(GameStrings.journal),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GameTheme.paper,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
