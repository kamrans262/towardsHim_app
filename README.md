# Toward HIM — Flutter UI

Flutter app for Android and iOS. The current phase is **UI-only**:
no backend, account creation, sign-in, Apple/Google SDK, or password-recovery API.

## Screens
- Native/Flutter splash, Welcome, Create Account, Login
- Forgot Password: navigable UI-only placeholder until its Figma is approved
- Shared 25 px bottom-safe-area action placement on Welcome, Create Account and Login, with scrolling for compact devices/keyboard

## Shared components
- `lib/core/theme/` — background `#F7EDDF`, colors, typography, spacing
- `lib/core/widgets/` — logo, auth header, inputs, buttons, social section, divider, inline link, and safe-area layout
- `lib/core/navigation/` — named routes
- `assets/icons/` — supplied SVG icons; social buttons currently show UI-only notices
- `lib/features/auth/` — route-scoped input controllers and focus nodes, disposed on exit

The supplied official branding artwork is embedded in `assets/branding/toward_him_logo.svg` as raster content, not editable vector paths.

## Validation
Run `flutter pub get && flutter analyze && flutter test test/widget_test.dart test/create_account_screen_test.dart test/login_screen_test.dart`.
A targeted GitHub workflow performs the same checks on changes to `main`. iOS simulator builds require macOS. Only run `dart run flutter_native_splash:create` if changing native splash assets.
