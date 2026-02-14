# Feature Button Design Specification

## Overview
This document outlines the design specification for feature buttons that can be repurposed across different screens in the TownTrek Flutter app. These buttons were originally used on the landing page as feature cards.

## Design Components

### Button Structure
```dart
Card(
  margin: const EdgeInsets.only(bottom: 16),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        // Icon Container
        // Title and Description Column
        // Arrow Icon
      ],
    ),
  ),
)
```

### Icon Container
```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: colorScheme.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    icon,
    size: 32,
    color: colorScheme.primary,
  ),
)
```

### Title Text
```dart
Text(
  title,
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: colorScheme.onSurface,
  ),
)
```

### Description Text
```dart
Text(
  description,
  style: theme.textTheme.bodyMedium?.copyWith(
    color: colorScheme.onSurface.withValues(alpha: 0.7),
  ),
)
```

### Arrow Icon
```dart
Icon(
  Icons.arrow_forward_ios,
  size: 16,
  color: colorScheme.onSurface.withValues(alpha: 0.3),
)
```

## Layout Specifications

### Spacing
- **Card Margin**: `EdgeInsets.only(bottom: 16)`
- **Card Padding**: `EdgeInsets.all(20)`
- **Icon to Text Spacing**: `SizedBox(width: 16)`
- **Title to Description Spacing**: `SizedBox(height: 4)`

### Dimensions
- **Icon Container Size**: 56x56 (with 12 padding)
- **Icon Size**: 32
- **Arrow Icon Size**: 16

## Color Scheme
- **Icon Background**: Primary color with 10% opacity
- **Icon Color**: Primary color
- **Title Color**: On surface color
- **Description Color**: On surface color with 70% opacity
- **Arrow Color**: On surface color with 30% opacity

## Usage Examples

### Business Directory Button
```dart
_buildFeatureButton(
  context,
  icon: Icons.business,
  title: 'Business Directory',
  description: 'Find local businesses, restaurants, and services',
  onPressed: () => navigateToBusinessDirectory(),
)
```

### Events Button
```dart
_buildFeatureButton(
  context,
  icon: Icons.event,
  title: 'Local Events',
  description: 'Discover upcoming events and activities',
  onPressed: () => navigateToEvents(),
)
```

### Map/Navigation Button
```dart
_buildFeatureButton(
  context,
  icon: Icons.location_on,
  title: 'Location Services',
  description: 'Navigate to businesses with integrated maps',
  onPressed: () => navigateToMaps(),
)
```

## Implementation Notes

### Widget Method
```dart
Widget _buildFeatureButton(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String description,
  required VoidCallback onPressed,
}) {
  // Implementation as shown above
  // Make sure to wrap the Card in a GestureDetector or InkWell for onPressed functionality
}
```

### Gesture Handling
For the button to be interactive, wrap the Card in either:
- `GestureDetector` with `onTap: onPressed`
- `InkWell` with `onTap: onPressed` (provides ripple effect)

### Accessibility
- Ensure proper semantic labels for screen readers
- Consider minimum touch target sizes (48x48 dp recommended)
- Test with TalkBack/VoiceOver enabled

## Future Enhancements
- Add hover states for web/desktop versions
- Consider animated transitions between states
- Implement loading states for async operations
- Add support for different button variants (filled, outlined, etc.)
