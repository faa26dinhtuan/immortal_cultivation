import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';
import '../../cultivation/cultivation_state.dart';

class CharacterSheet extends StatelessWidget {
  const CharacterSheet({
    required this.realm,
    required this.progress,
    required this.insights,
    super.key,
  });

  static const iconAsset = 'assets/icons/character/character.png';

  final CultivationRealm realm;
  final int progress;
  final List<DaoNiem> insights;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          GameTheme.gutter,
          0,
          GameTheme.gutter,
          GameTheme.gutter,
        ),
        children: [
          Text(GameStrings.character, style: typography.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                iconAsset,
                width: 64,
                height: 64,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(GameStrings.characterRealm, style: typography.labelLarge),
                    Text(GameStrings.realmName(realm), style: typography.headlineSmall),
                    Text(GameStrings.cultivationProgress(progress)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(GameStrings.characterInsights, style: typography.titleMedium),
          if (insights.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(GameStrings.noInsight),
            ),
          for (final insight in insights)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(GameStrings.daoNiemName(insight)),
              subtitle: Text(GameStrings.characterInsightEffect(insight)),
            ),
        ],
      ),
    );
  }
}
