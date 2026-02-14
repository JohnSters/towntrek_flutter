# TownTrek Style Guide

## Overview

This style guide establishes the visual design principles and standards for the TownTrek Flutter application. It ensures consistency across all user interfaces and provides clear guidelines for developers and designers working on the project.

## Design Philosophy

### Core Principles
- **Clean & Minimal**: No shadows, gradients, or decorative elements
- **Material Design 3**: Following Google's latest Material Design guidelines
- **Accessibility First**: WCAG 2.1 AA compliance for color contrast and interaction
- **Mobile-First**: Optimized for mobile devices with responsive scaling
- **Consistent Branding**: TownTrek blue (#0175C2) as primary brand color

### Key Restrictions
- ❌ **No Shadows**: Zero elevation on all components
- ❌ **No Drop Shadows**: Flat design approach
- ✅ **Subtle Gradients**: Acceptable for backgrounds and branding elements (e.g., logo containers, hero sections)
- ✅ **Material Icons**: Only use Material Design Icons
- ✅ **Rounded Corners**: 8px for buttons, 12px for cards, 16px for dialogs

## Color System

### Primary Palette

#### Brand Colors
- **Primary**: `#0175C2` - TownTrek blue for CTAs and primary actions
- **Secondary**: `#03A9F4` - Lighter blue for secondary elements
- **Tertiary**: `#00BCD4` - Cyan for accents and highlights

#### Semantic Colors
- **Success**: `#4CAF50` - Green for positive actions and confirmations
- **Warning**: `#FF9800` - Orange for cautions and warnings
- **Error**: `#F44336` - Red for errors and destructive actions
- **Info**: `#2196F3` - Blue for informational content

### Neutral Colors

#### Light Theme
- **Surface**: `#FFFFFF` - Main background for cards and dialogs
- **Background**: `#FAFAFA` - App-level background
- **On Surface**: `#1C1B1F` - Primary text on light backgrounds
- **On Surface Variant**: `#49454F` - Secondary text and icons
- **Outline**: `#79747E` - Borders and dividers
- **Outline Variant**: `#CAC4D0` - Subtle borders

#### Dark Theme
- **Surface**: `#0F1419` - Main background for cards and dialogs
- **On Surface**: `#E6E1E5` - Primary text on dark backgrounds
- **On Surface Variant**: `#CAC4D0` - Secondary text and icons
- **Outline**: `#938F99` - Borders and dividers
- **Outline Variant**: `#403D43` - Subtle borders

### Usage Guidelines

#### Color Application Rules
1. **Primary Color**: Use only for primary actions (main buttons, links, active states)
2. **Secondary Color**: Use for secondary actions and accent elements
3. **Semantic Colors**: Reserve for their specific meanings only
4. **Neutral Colors**: Use for backgrounds, text, and structural elements

#### Contrast Requirements
- **Text on Background**: Minimum 4.5:1 contrast ratio (WCAG AA)
- **Interactive Elements**: Minimum 3:1 contrast ratio
- **Focus Indicators**: Minimum 3:1 contrast against adjacent colors

## Typography

### Font Family
- **Primary Font**: Roboto (Google Fonts)
- **Fallback**: System default sans-serif

### Type Scale (Material Design 3)

#### Display Styles (Large screens, hero content)
- **Display Large**: 57px / 1.12 line-height / -0.25 letter-spacing
- **Display Medium**: 45px / 1.16 line-height / 0 letter-spacing
- **Display Small**: 36px / 1.22 line-height / 0 letter-spacing

#### Headline Styles (Section headers)
- **Headline Large**: 32px / 1.25 line-height / 0 letter-spacing
- **Headline Medium**: 28px / 1.29 line-height / 0 letter-spacing
- **Headline Small**: 24px / 1.33 line-height / 0 letter-spacing

#### Title Styles (Card headers, dialogs)
- **Title Large**: 22px / 1.27 line-height / 0 letter-spacing / Medium (500)
- **Title Medium**: 16px / 1.5 line-height / 0.15 letter-spacing / Medium (500)
- **Title Small**: 14px / 1.43 line-height / 0.1 letter-spacing / Medium (500)

#### Body Styles (Content text)
- **Body Large**: 16px / 1.5 line-height / 0.5 letter-spacing / Regular (400)
- **Body Medium**: 14px / 1.43 line-height / 0.25 letter-spacing / Regular (400)
- **Body Small**: 12px / 1.33 line-height / 0.4 letter-spacing / Regular (400)

#### Label Styles (Buttons, form labels)
- **Label Large**: 14px / 1.43 line-height / 0.1 letter-spacing / Medium (500)
- **Label Medium**: 12px / 1.5 line-height / 0.5 letter-spacing / Medium (500)
- **Label Small**: 11px / 1.45 line-height / 0.5 letter-spacing / Medium (500)

### Typography Guidelines

#### Text Hierarchy
1. **Display**: App titles, hero sections
2. **Headline**: Page/section titles
3. **Title**: Card headers, dialog titles, form sections
4. **Body**: Main content, descriptions
5. **Label**: Buttons, form labels, captions

#### Text Color Usage
- **On Surface**: Primary text (headings, important content)
- **On Surface Variant**: Secondary text (descriptions, metadata)
- **Primary**: Links, actionable text
- **Error**: Error messages, validation text

## Component Guidelines

### Buttons

#### Primary Buttons (ElevatedButton)
- **Background**: Primary color (#0175C2)
- **Foreground**: White
- **Border Radius**: 8px
- **Padding**: 24px horizontal, 12px vertical
- **Text Style**: Label Large (14px, Medium)
- **Elevation**: 0 (no shadow)

#### Secondary Buttons (OutlinedButton)
- **Border**: Outline color (#79747E)
- **Foreground**: On Surface color
- **Border Radius**: 8px
- **Padding**: 24px horizontal, 12px vertical
- **Text Style**: Label Large (14px, Medium)

#### Text Buttons (TextButton)
- **Foreground**: Primary color (#0175C2)
- **Padding**: 16px horizontal, 12px vertical
- **Text Style**: Label Large (14px, Medium)

### Cards

#### Standard Cards (Card)
- **Background**: Surface color
- **Border Radius**: 12px
- **Elevation**: 0 (no shadow)
- **Padding**: 20px all sides
- **Margin**: 0 (no external margin)

#### Content Structure
```
┌─ Card Container (12px border radius)
│  ┌─ Icon Container (12px border radius, 10% primary)
│  │  [Icon 32px]
│  └─
│  ┌─ Title (Title Medium)
│  │
│  ┌─ Description (Body Medium, 70% opacity)
│  │
│  └─ Action Arrow (20px right, 30% opacity)
└─
```

### Forms & Inputs

#### Text Fields (TextFormField)
- **Border**: Outline style with 8px radius
- **Colors**:
  - Default: Outline color
  - Focused: Primary color, 2px width
  - Error: Error color
- **Padding**: 16px horizontal, 12px vertical
- **Background**: Surface color

#### Input Decoration
- **Label Style**: Body Large, On Surface Variant
- **Hint Style**: Body Medium, Outline color
- **Error Style**: Body Small, Error color

### Dialogs

#### Alert Dialogs (AlertDialog)
- **Background**: Surface color
- **Border Radius**: 16px
- **Elevation**: 0
- **Title Style**: Headline Small
- **Content Style**: Body Medium
- **Button Spacing**: 8px between buttons

### Navigation

#### Bottom Navigation (BottomNavigationBar)
- **Background**: Surface color
- **Selected Color**: Primary color
- **Unselected Color**: Outline color
- **Elevation**: 0
- **Label Style**: 12px, Medium weight

## Icons

### Icon Guidelines

#### Material Design Icons Only
- **Source**: Material Design Icons (https://fonts.google.com/icons)
- **Style**: Filled icons (not outlined)
- **Color**: On Surface for inactive, Primary for active
- **Size**: 24px default, 32px for feature icons

#### Common Icon Usage
- `business` - Business listings
- `event` - Events and calendar
- `location_on` - Maps and location
- `search` - Search functionality
- `arrow_forward_ios` - Navigation/chevrons
- `location_city` - Town/city selection
- `info` - Information/help
- `check_circle` - Success states
- `error` - Error states
- `warning` - Warning states

#### Icon in Context
- **Standalone Icons**: 24px, centered in 48px touch targets
- **Button Icons**: 18px, with 8px padding from text
- **List Icons**: 24px, vertically centered
- **Card Icons**: 32px, in colored container (10% primary opacity)

## Spacing & Layout

### Spacing Scale
- **4px**: Minimal spacing, icon padding
- **8px**: Component padding, small gaps
- **12px**: Card padding, medium gaps
- **16px**: Screen padding, large gaps
- **20px**: Card content padding
- **24px**: Button padding, section spacing
- **32px**: Major section spacing
- **40px**: Hero content spacing
- **48px**: Page section spacing

### Layout Principles

#### Screen Layout
```
┌─ Safe Area (16px padding)
│  ┌─ App Bar (if present)
│  │
│  ┌─ Content Area
│  │  ┌─ Hero Section (40px top margin)
│  │  │
│  │  ┌─ Feature Cards (16px vertical spacing)
│  │  │
│  │  ┌─ Actions (48px top margin)
│  │  │
│  │  ┌─ Footer (32px top margin)
│  └─
└─
```

#### Component Spacing
- **Card Margins**: 16px bottom margin between cards
- **Button Groups**: 16px vertical spacing
- **Form Fields**: 16px vertical spacing
- **List Items**: 8px divider height

### Responsive Design

#### Breakpoints
- **Mobile**: < 600px (primary target)
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

#### Scaling Guidelines
- **Text**: Scale proportionally with screen size
- **Spacing**: Scale with text size (1.5x line height)
- **Touch Targets**: Minimum 48px on all devices

## Accessibility

### Color Contrast
- **Normal Text**: 4.5:1 minimum contrast ratio
- **Large Text**: 3:1 minimum contrast ratio (18pt+ or 14pt+ bold)
- **Interactive Elements**: 3:1 minimum contrast ratio
- **Focus Indicators**: 3:1 contrast against adjacent colors

### Touch Targets
- **Minimum Size**: 48px x 48px (48dp)
- **Preferred Size**: 56px x 56px (56dp)
- **Icon Touch Targets**: 48px container minimum

### Focus Management
- **Focus Indicators**: 2px solid border in primary color
- **Focus Order**: Logical tab order through interface
- **Keyboard Navigation**: Full keyboard accessibility

### Content Guidelines
- **Text Alternatives**: Alt text for all images
- **Semantic Structure**: Proper heading hierarchy
- **Color Independence**: Don't rely on color alone for meaning
- **Motion Sensitivity**: Respect reduced motion preferences

## Implementation Guidelines

### Theme Usage

#### Accessing Theme Colors
```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Correct usage
Container(
  color: colorScheme.primary,
  child: Text(
    'Primary Button',
    style: theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.onPrimary,
    ),
  ),
)
```

#### Component Implementation
```dart
// Correct button implementation
ElevatedButton(
  onPressed: () => _handleAction(),
  child: const Text('Continue'),
  // Theme handles styling automatically
)

// Correct card implementation
Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Card content
      ],
    ),
  ),
)
```

### Code Organization

#### Theme Import
```dart
import 'package:towntrek_flutter/theme/app_theme.dart';

// Use AppTheme.lightTheme or AppTheme.darkTheme
```

#### Component Structure
- **Consistent Padding**: Use theme-defined padding values
- **Proper Text Styles**: Always use theme text styles
- **Color Scheme Usage**: Never hardcode colors

### Testing Guidelines

#### Visual Testing
- **Theme Switching**: Test light/dark mode transitions
- **Screen Sizes**: Test on multiple device sizes
- **High Contrast**: Test with system high contrast settings

#### Accessibility Testing
- **Screen Readers**: Test with TalkBack/VoiceOver
- **Keyboard Navigation**: Test full keyboard accessibility
- **Color Blindness**: Test with color blindness simulators

## Maintenance

### Theme Updates
- **Version Control**: Document all theme changes
- **Deprecation Policy**: Mark deprecated styles before removal
- **Migration Guide**: Provide migration path for breaking changes

### Design System Evolution
- **Regular Review**: Quarterly design system audit
- **User Feedback**: Incorporate user feedback into updates
- **Platform Updates**: Stay current with Material Design updates

---

## Quick Reference

### Color Tokens
- **Primary**: `AppTheme.primaryColor`
- **Success**: `AppTheme.successColor`
- **Error**: `AppTheme.errorColor`

### Component Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px

### Border Radius
- **Buttons**: 8px
- **Cards**: 12px
- **Dialogs**: 16px

### Typography Scale
- **Display**: 57px - 36px
- **Headline**: 32px - 24px
- **Title**: 22px - 14px
- **Body**: 16px - 12px
- **Label**: 14px - 11px

---

**Last Updated**: October 10, 2025
**Version**: 1.0
**Contact**: Design System Team
