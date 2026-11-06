import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/game_strings.dart';
import '../controllers/world_controller.dart';

class FloodEventDialog extends StatelessWidget {
  const FloodEventDialog({
    required this.elapsedHours,
    required this.remainingHours,
    super.key,
  });

  final int elapsedHours;
  final int remainingHours;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        scrollable: true,
        title: const Text(GameStrings.floodTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/events/flooded_ford.png',
                semanticLabel: GameStrings.floodImageDescription,
              ),
            ),
            const SizedBox(height: 12),
            const Text(GameStrings.floodDescription),
            const SizedBox(height: 8),
            Text(GameStrings.interruptedProgress(elapsedHours, remainingHours)),
            const SizedBox(height: 12),
            for (final choice in FloodChoice.values)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(choice);
                  },
                  child: Text(
                    GameStrings.floodOption(choice),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
