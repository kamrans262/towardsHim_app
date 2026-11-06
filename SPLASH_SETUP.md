# Toward HIM Native Splash Setup

This package contains the original user-supplied logo, a centered logo image for iOS and Android 11 and below, an Android 12+ circular-mask-safe image, and a flutter_native_splash configuration file. No logo artwork was redrawn or changed. Background is sampled from the supplied image: `#F6EDDE`.

Extract the ZIP directly into the root of the `towardsHim_app` Flutter project.

Then run from the project root:

```sh
flutter pub add --dev "flutter_native_splash:^2.4.8" && dart run flutter_native_splash:create
```

The generator will update the necessary Android resources and iOS `LaunchScreen.storyboard`. Commit the generated native files and assets together. Validate on device; on Android 12+ splash duration and circular masking are OS-controlled.

To restore generated assets if the source is changed, re-run `dart run flutter_native_splash:create`.
