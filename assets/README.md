# Assets Organization

This folder contains all static assets used in the TownTrek Flutter app.

## 📁 Folder Structure

```
assets/
├── images/
│   ├── logos/           # App logos and branding
│   │   ├── logo.png
│   │   ├── logo_white.png
│   │   └── logo_icon.png
│   ├── icons/           # Custom icons (not Material Icons)
│   │   ├── custom_marker.png
│   │   └── custom_pin.png
│   └── backgrounds/     # Background images/patterns
│       ├── splash_bg.png
│       └── pattern.png
├── animations/          # Lottie animations (if used)
│   └── loading.json
└── fonts/               # Custom fonts (if needed)
    ├── Roboto-Regular.ttf
    └── Roboto-Bold.ttf
```

## 📝 Naming Conventions

- **File names**: Use `snake_case` (e.g., `app_logo.png`, `splash_background.jpg`)
- **Prefixes**: Add prefixes for related assets:
  - `logo_` - App logos and branding
  - `icon_` - Custom icons
  - `bg_` - Background images
  - `btn_` - Button graphics

## 🎨 Image Specifications

### Logos
- **Primary Logo**: `logo.png` (main app logo)
- **White Logo**: `logo_white.png` (for dark backgrounds)
- **Icon Logo**: `logo_icon.png` (square format for app icons)
- **Formats**: PNG (preferred), SVG (if vector)
- **Sizes**: Provide multiple resolutions (1x, 2x, 3x)

### Icons
- **Format**: PNG with transparent background
- **Sizes**: 24x24, 48x48, 96x96 (provide 1x, 2x, 3x versions)
- **Style**: Match app design language

### Backgrounds
- **Format**: JPG for photos, PNG for patterns/graphics
- **Optimization**: Compress for mobile app sizes
- **Responsive**: Consider different screen densities

## 🚀 Usage in Code

```dart
// Logos
Image.asset('assets/images/logos/logo.png')

// Icons
Image.asset('assets/images/icons/custom_marker.png')

// Backgrounds
Image.asset('assets/images/backgrounds/splash_bg.png')
```

## 📦 Adding New Assets

1. Place files in appropriate subfolder
2. Update `pubspec.yaml` if adding new folders
3. Run `flutter pub get` to refresh assets
4. Use in code with proper paths

## 📱 Platform-Specific Assets

- **Android**: Place in `android/app/src/main/res/drawable-*`
- **iOS**: Place in `ios/Runner/Assets.xcassets/`
- **Web**: Assets are bundled automatically

## 🔧 Optimization Tips

- Use appropriate image formats (PNG for transparency, JPG for photos)
- Compress images without quality loss
- Provide multiple resolutions for different screen densities
- Use vector graphics (SVG) when possible for scalability
