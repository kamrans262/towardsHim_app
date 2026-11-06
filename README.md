# Toward HIM — Flutter UI

This repository contains Flutter Android and iOS screens for Toward HIM.
Current work is **UI-only**. No registration, sign-in, backend, Firebase, or social authentication integrations are implemented.

## Implemented UI
- Native splash and Flutter splash, Welcome, and Create Account screens.
- Shared `#F7EDDF` backgrounds, Playfair Display / DM Sans, buttons, logo, back action, fields, social buttons, and OR divider.
- Original supplied SVG icons under `assets/icons/`. Google/Apple buttons show temporary UI-only notices.
- Welcome and Create Account bottom actions use the same 25-pixel safe-area padding and scroll naturally on small devices or when the keyboard is open.
- Create Account and Login routes are connected. Login currently displays an explicit UI-only placeholder until its Figma is provided.

The official original vector logo was not supplied. `assets/branding/toward_him_logo.svg` embeds the supplied raster artwork to preserve its exact appearance; it is not editable vector paths.

## Local checks

Run `flutter pub get`, `flutter analyze`, and `flutter test test/widget_test.dart test/create_account_screen_test.dart`. The existing targeted GitHub workflow runs the same checks when this UI changes.

Run `dart run flutter_native_splash:create` only when updating the native launch splash assets. iOS builds require macOS.
