import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../../character/widgets/character_sheet.dart';
import '../../cultivation/widgets/cultivation_sheet.dart';
import '../../inventory/widgets/inventory_sheet.dart';
import '../controllers/world_controller.dart';
import '../widgets/flood_event_dialog.dart';
import '../widgets/regional_map.dart';
import '../widgets/route_preview.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({this.controller, super.key});

  final WorldController? controller;

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final _controller = widget.controller ?? WorldController();
  bool _showDestination = false;
  bool _eventOpen = false;

  @override
  void initState() {
    super.initState();
    if (_controller.floodPending) {
      _showDestination = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showTravelEvent();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _travel() async {
    HapticFeedback.lightImpact();
    if (_controller.beginTravel()) {
      await _showTravelEvent();
      return;
    }
    setState(() => _showDestination = false);
  }

  Future<void> _showTravelEvent() async {
    if (_eventOpen || !_controller.floodPending) return;
    _eventOpen = true;
    final choice = await showDialog<FloodChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FloodEventDialog(
        elapsedHours: _controller.journeyElapsedHours,
        remainingHours: _controller.remainingHours,
      ),
    );
    _eventOpen = false;
    if (!mounted) return;
    _controller.resolveFlood(choice);
    setState(() => _showDestination = _controller.floodPending);
  }

  void _openCharacter() {
    final cultivation = _controller.cultivation;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => CharacterSheet(
        realm: cultivation.realm,
        progress: cultivation.progress,
        knowsManual: cultivation.knowsManual,
        insights: cultivation.insights.toList(growable: false),
      ),
    );
  }

  void _openCultivation() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => CultivationSheet(controller: _controller),
    );
  }

  void _openInventory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => InventorySheet(herbs: _controller.herbs),
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
            Text(
              GameStrings.journal,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty) const Text(GameStrings.emptyJournal),
            for (final entry in entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(GameStrings.journalTitle(entry)),
                subtitle: Text(GameStrings.journalDetail(entry)),
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
                interruptedTrail: _controller.interruptedTrail,
                selected: _controller.selected,
                route: _showDestination ? _controller.route : const [],
                onSelect: (place) {
                  if (_controller.floodPending) return;
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
                              Text(
                                GameStrings.regionName,
                                style: typography.titleLarge,
                              ),
                              Text(
                                _controller.floodPending
                                    ? GameStrings.journeyInterrupted
                                    : GameStrings.currentPlace(
                                        _controller.current,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            GameStrings.clock(
                              _controller.day,
                              _controller.hour,
                            ),
                          ),
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
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * .48,
                            ),
                            child: SingleChildScrollView(
                              child: _MapPanel(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            GameStrings.placeName(
                                              _controller.selected,
                                            ),
                                            style: typography.titleMedium,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: GameStrings.closeDestination,
                                          icon: const Icon(Icons.close),
                                          onPressed: () => setState(
                                            () => _showDestination = false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      GameStrings.placeDescription(
                                        _controller.selected,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_controller.floodPending)
                                      FilledButton(
                                        onPressed: _showTravelEvent,
                                        child: const Text(
                                          GameStrings.resumeJourney,
                                        ),
                                      )
                                    else if (_controller.canHarvest &&
                                        _controller.selected ==
                                            _controller.current) ...[
                                      Text(
                                        GameStrings.herbCount(
                                          _controller.herbs,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      FilledButton(
                                        onPressed: _controller.harvest,
                                        child: Text(
                                          GameStrings.harvestAction(
                                            WorldController.harvestHours,
                                          ),
                                        ),
                                      ),
                                    ] else if (_controller.canSurveyPass &&
                                        _controller.selected ==
                                            _controller.current)
                                      FilledButton(
                                        onPressed: _controller.surveyPass,
                                        child: Text(
                                          GameStrings.surveyPass(
                                            WorldController.surveyHours,
                                          ),
                                        ),
                                      )
                                    else ...[
                                      if (hours > 0) ...[
                                        RoutePreview(
                                          steps: _controller.route,
                                          risk: _controller.eventRisk,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      FilledButton(
                                        onPressed: hours == 0 ? null : _travel,
                                        child: Text(
                                          hours == 0
                                              ? GameStrings.alreadyHere
                                              : GameStrings.travel(hours),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_controller.saveFailed)
                          _MapPanel(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(GameStrings.saveFailed),
                                TextButton(
                                  onPressed: _controller.retrySave,
                                  child: const Text(GameStrings.retry),
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
                              onPressed: _openCharacter,
                              icon: Image.asset(
                                CharacterSheet.iconAsset,
                                width: 24,
                                height: 24,
                                excludeFromSemantics: true,
                              ),
                              label: const Text(GameStrings.character),
                            ),
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
                              onPressed: _openInventory,
                              icon: Image.asset(
                                InventorySheet.bagIcon,
                                width: 24,
                                height: 24,
                                excludeFromSemantics: true,
                              ),
                              label: const Text(GameStrings.inventory),
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
