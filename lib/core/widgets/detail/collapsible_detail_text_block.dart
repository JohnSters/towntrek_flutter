import 'package:flutter/material.dart';

/// Expand/collapse control for long detail copy (same interaction pattern as
/// [PlatformStatsCard]: tap the bottom bar to show or hide the full text).
class CollapsibleDetailTextBlock extends StatefulWidget {
  final String text;
  final String emptyPlaceholder;
  final String headerLabel;
  final bool initiallyExpanded;
  final TextStyle? textStyle;

  const CollapsibleDetailTextBlock({
    super.key,
    required this.text,
    this.emptyPlaceholder = 'No description available yet.',
    this.headerLabel = 'About',
    this.initiallyExpanded = true,
    this.textStyle,
  });

  @override
  State<CollapsibleDetailTextBlock> createState() =>
      _CollapsibleDetailTextBlockState();
}

class _CollapsibleDetailTextBlockState extends State<CollapsibleDetailTextBlock> {
  static const double _barPaddingH = 12;
  static const double _barPaddingV = 10;

  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final body = widget.text.trim();
    if (body.isEmpty) {
      return Text(
        widget.emptyPlaceholder,
        style: widget.textStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: colorScheme.onSurface.withValues(alpha: 0.72),
            ),
      );
    }

    final style = widget.textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          height: 1.4,
          color: colorScheme.onSurface.withValues(alpha: 0.88),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Text(body, style: style)
              : const SizedBox(width: double.infinity),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 2),
          color: colorScheme.outline.withValues(alpha: 0.14),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _barPaddingH,
                vertical: _barPaddingV,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 15,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.headerLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.15,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 22,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient shell used at the top of several entity detail screens, with
/// collapsible description text inside.
class CollapsibleGradientDescriptionCard extends StatelessWidget {
  final String bodyText;
  final String emptyPlaceholder;
  final String headerLabel;
  final bool initiallyExpanded;
  final List<Color> gradientColors;

  const CollapsibleGradientDescriptionCard({
    super.key,
    required this.bodyText,
    this.emptyPlaceholder = 'No description available yet.',
    this.headerLabel = 'About',
    this.initiallyExpanded = true,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: CollapsibleDetailTextBlock(
        text: bodyText,
        emptyPlaceholder: emptyPlaceholder,
        headerLabel: headerLabel,
        initiallyExpanded: initiallyExpanded,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: colorScheme.onSurface.withValues(alpha: 0.88),
            ),
      ),
    );
  }
}
