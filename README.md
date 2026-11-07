# Toward HIM — Flutter UI

Flutter Android/iOS project. Current phase: **UI only**. Authentication, actual
audio playback, notifications, payments, data fetching, external Store launching,
and verification emails are not integrated.

## Implemented screens

- Native/Flutter splash, Welcome, Create Account, Login, Forgot Password / OTP
- Home dashboard based on the approved 430px Figma design
- Listen tab with its approved Figma header, quick categories, four audio demo rows and UI-only play state
- Demo Login navigation to Home with no authentication
- Five-tab main shell: Home, Listen, Towards HIM 3, Community, Store
- Challenge, Community and Store show UI-only placeholders until their
  approved designs / URL are available (no invented merchandise URL)

## Home design assets

- `assets/images/home/misty_sunrise_mountain_lake.webp`: optimized from the
  supplied misty sunrise image; full-bleed Home hero and featured-card visual
- `assets/images/home/golden_hour_meditation.webp`: optimized from the
  supplied Golden Hour Meditation photo for audio and activity thumbnails
- `assets/icons/home/`: supplied notification/profile SVGs and matching
  lightweight Podcast/Meditation/Prayer icons
- `assets/icons/navigation/`: the five supplied bottom-tab SVGs under
  descriptive names

## Architecture

- `lib/core/theme/`: shared colors, spacing, typography
- `lib/core/widgets/`: global content card, section heading, progress,
  play button, svg icon action, and fixed bottom navigation
- `lib/features/home/domain/models/`: typed dashboard/demo models
- `lib/features/home/data/home_demo_data.dart`: reference demo content
- `lib/features/home/presentation/controllers/`: feature-scoped navigation
  `ChangeNotifier`, disposed by the shell
- `lib/features/home/presentation/widgets/`: reusable dashboard cards
- `lib/features/home/presentation/screens/`: Home and preserved-tab shell
- `lib/features/listen/`: structured episode demo models/data, reusable media rows and Listen UI
- `lib/core/widgets/app_audio_content_row.dart`: reused for both 70px Home and 100px Listen thumbnails

The Home scroll/play demo state remains alive between tab switches via
`IndexedStack`. Store has no configured URL, so it shows a local placeholder
instead of opening an invented website.

## Tests

```bash
flutter pub get
flutter analyze
flutter test test/widget_test.dart test/create_account_screen_test.dart test/login_screen_test.dart test/forgot_password_screen_test.dart test/home_screen_test.dart test/listen_screen_test.dart
```

The targeted workflow performs those checks on `main`. Native iOS simulator
visual checks require macOS. Only regenerate `flutter_native_splash` when
changing the native launch design.
