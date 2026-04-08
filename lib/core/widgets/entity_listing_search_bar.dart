import 'package:flutter/material.dart';

import '../constants/entity_listing_constants.dart';
import '../theme/entity_listing_theme.dart';

/// Search field used on entity listing pages (matches Creative Spaces list styling).
class EntityListingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final EntityListingTheme theme;
  final String hintText;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  const EntityListingSearchBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.hintText,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onSubmitted: (_) => onSubmitted(),
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.2),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: onClear,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: EntityListingConstants.searchBarContentPadding,
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                EntityListingConstants.searchBarRadius,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                EntityListingConstants.searchBarRadius,
              ),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.16),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                EntityListingConstants.searchBarRadius,
              ),
              borderSide: BorderSide(
                color: theme.accent.withValues(alpha: 0.45),
              ),
            ),
          ),
        );
      },
    );
  }
}
