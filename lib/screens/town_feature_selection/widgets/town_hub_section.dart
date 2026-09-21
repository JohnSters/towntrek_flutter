import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'town_hub_action_tile.dart';

/// Collapsible town-hub grouping using the same full-width row as Notices.
class TownHubSection extends StatefulWidget {
  const TownHubSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    required this.accentColor,
    this.initiallyExpanded = true,
    this.emphasized = false,
    this.icon = Icons.explore_rounded,
  });

  final String title;
  final String description;
  final Widget child;
  final Color accentColor;
  final bool initiallyExpanded;
  final bool emphasized;
  final IconData icon;

  static Key headerKey(String title) => Key('town-hub-section-$title');

  @override
  State<TownHubSection> createState() => _TownHubSectionState();
}

class _TownHubSectionState extends State<TownHubSection> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TownHubActionTile(
          key: TownHubSection.headerKey(widget.title),
          title: widget.title,
          subtitle: widget.description,
          onTap: _toggle,
          expanded: _expanded,
          emphasized: widget.emphasized,
          accentColor: widget.accentColor,
          tintColor: widget.accentColor,
          tintStrength: widget.emphasized
              ? TownFeatureConstants.hubActionExploreTintStrength
              : TownFeatureConstants.hubActionTintStrength,
          leading: TownHubIconLead(
            icon: widget.icon,
            accentColor: widget.accentColor,
          ),
          showChevron: false,
          trailing: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: TownFeatureConstants.hubActionGap,
                  ),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
