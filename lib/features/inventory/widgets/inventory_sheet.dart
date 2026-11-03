import 'package:flutter/material.dart';

import '../../../core/theme/game_theme.dart';
import '../../../l10n/game_strings.dart';

class InventorySheet extends StatelessWidget {
  const InventorySheet({required this.herbs, super.key});

  static const bagIcon = 'assets/icons/ui/inventory.png';
  static const herbIcon = 'assets/icons/items/herb.png';

  final int herbs;

  @override
  Widget build(BuildContext context) {
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
          Text(GameStrings.inventory, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (herbs == 0)
            const Text(GameStrings.emptyInventory)
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.asset(
                herbIcon,
                width: 40,
                height: 40,
                excludeFromSemantics: true,
              ),
              title: Text(GameStrings.herbCount(herbs)),
              subtitle: const Text(GameStrings.herbUse),
            ),
        ],
      ),
    );
  }
}
