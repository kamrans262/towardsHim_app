# Toward HIM — One Large Logo on Startup

The approved official Toward HIM logo appears **once**, centered at
**270 × 164 logical pixels** on the Flutter SplashScreen for about 1.6 seconds.

Native launch screens are unavoidable while iOS/Android starts the Flutter
engine, but their image/icon is intentionally **invisible**. They show only
the same cream background (`#F7EDDF`), so there is no initial small logo.

## Platform files

- Flutter: `lib/features/onboarding/presentation/screens/splash_screen.dart`
  owns the one visible large logo.
- Android 11 and below: `res/drawable*/launch_background.xml` uses a
  background-only shape.
- Android 12+: `values-v31/styles.xml` and
  `values-night-v31/styles.xml` explicitly use
  `@drawable/empty_splash_icon`. Android's mandatory OS icon is transparent,
  preventing a smaller logo from flashing first.
- iOS: `LaunchScreen.storyboard` uses a background color without an
  image view.

**Do not re-run `dart run flutter_native_splash:create` without reapplying
the transparent Android 12 icon override.** The plugin may reintroduce the
small launcher icon if an Android 12 image is not provided. Existing
`assets/splash` source artwork remains untouched.

## Testing

A native change requires a **fresh installed build**; Flutter hot reload
will not update iOS launch storyboards or Android splash resources.

```sh
flutter clean && flutter pub get && flutter run
```

If the device still shows an old native splash, uninstall the old app and
install a new build. Check startup on iPhone and Android 12+.
