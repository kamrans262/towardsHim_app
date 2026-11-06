# Toward HIM — Flutter UI

Flutter Android/iOS UI project. The current milestone includes the Splash and Welcome screens only. No backend services or authentication are implemented.

## Structure

- `lib/core/theme/`: centralized color, spacing, typography, and app theme tokens
- `lib/core/widgets/`: shared logo and button components
- `lib/core/navigation/`: named app routes
- `lib/features/onboarding/presentation/screens/`: Splash and Welcome
- `assets/branding/toward_him_logo.svg`: official raster logo embedded in an SVG container, pending the original vector source
- `assets/fonts/`: bundled OFL-licensed Playfair Display and DM Sans variable fonts

The supplied logo files are JPG/PNG, not the original vector SVG. The branded SVG container preserves their artwork but does **not** transform the image into editable vector paths. Replace the asset with the official SVG when it becomes available, without changing the widget interface.

## Local verification

Run `flutter pub get`, `dart run flutter_native_splash:create`, `flutter analyze`, and `flutter test test/widget_test.dart`. Run `flutter test` before declaring the milestone fully verified. Native splash generation must be repeated after color changes; iOS builds must run on macOS.

The Login, Create Account, and Guest destinations show temporary UI-only notices until their approved designs are implemented in later modules.
