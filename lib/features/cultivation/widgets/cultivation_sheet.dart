import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../../world/controllers/world_controller.dart';
import '../cultivation_state.dart';

class CultivationSheet extends StatelessWidget {
  const CultivationSheet({required this.controller, super.key});

  final WorldController controller;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final cultivation = controller.cultivation;
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              GameTheme.gutter, 0, GameTheme.gutter, GameTheme.gutter,
            ),
            children: [
              Text(GameStrings.cultivation, style: typography.titleLarge),
              const SizedBox(height: 8),
              Text(GameStrings.realmName(cultivation.realm)),
              Text(GameStrings.cultivationProgress(cultivation.progress)),
              Text(GameStrings.clock(controller.day, controller.hour)),
              const SizedBox(height: 12),
              Text(GameStrings.ownedInsights(cultivation.insights)),
              const SizedBox(height: 12),
              if (!controller.canCultivate)
                const Text(GameStrings.cultivationAtCave)
              else ...[
                FilledButton(
                  onPressed: controller.retreat,
                  child: Text(GameStrings.retreatAction(
                    CultivationState.retreatHours,
                    CultivationState.retreatGain,
                  )),
                ),
                OutlinedButton(
                  onPressed: controller.herbs > 0
                      ? () => controller.retreat(useHerb: true)
                      : null,
                  child: Text(
                    GameStrings.herbalRetreat(controller.herbs),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                if (cultivation.hasNextRealm) ...[
                  Text(GameStrings.breakthrough, style: typography.titleMedium),
                  for (final insight in <DaoNiem?>[null, ...cultivation.insights])
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        onPressed: cultivation.canBreakThrough(insight)
                            ? () => controller.breakThrough(insight)
                            : null,
                        child: Text(
                          GameStrings.breakthroughOption(
                            insight, cultivation.requiredProgress(insight),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ] else
                  const Text(GameStrings.firstBreakthroughComplete),
              ],
            ],
          ),
        );
      },
    );
  }
}
