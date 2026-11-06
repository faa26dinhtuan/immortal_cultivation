import 'package:flutter/material.dart';

import '../../../l10n/game_strings.dart';
import '../world_region.dart';

class RoutePreview extends StatelessWidget {
  const RoutePreview({required this.steps, required this.risk, super.key});

  final List<WorldTrail> steps;
  final double risk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          GameStrings.walkingRoute,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(GameStrings.routeStep(step)),
          ),
        const SizedBox(height: 8),
        Text(GameStrings.routeRisk(risk)),
      ],
    );
  }
}
