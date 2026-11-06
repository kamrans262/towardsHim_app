# Toward HIM — Flutter UI

Flutter app for Android and iOS. The current phase is **UI-only**:
no backend, account creation, sign-in, Apple/Google SDK, email sending,
or password recovery/OTP verification service.

## Screens
- Native/Flutter splash, Welcome, Create Account, Login
- Forgot Password and Verify Your Account (single Figma screen)
- Shared 25 px bottom-safe-area action placement and scrolling on smaller devices

## Shared components
- `lib/core/theme/` — background `#F7EDDF`, colors, typography, spacing
- `lib/core/widgets/` — logo, auth header, inputs, buttons, icon send button,
  six-box OTP input, social section, divider, inline link, and safe-area layout
- `lib/core/navigation/` — named routes
- `assets/icons/` — supplied original SVGs
- `lib/features/auth/` — screen-owned text controllers and focus nodes

### Forgot Password UI behavior
- Send displays a UI-only notice; **no email is sent**.
- Six visible OTP boxes use one native numeric input, supporting normal
  typing, full-code paste, deletion and SMS one-time-code autofill.
- Verify stays disabled until a valid-looking email and six digits exist.
  If tapped after completion it displays an UI-only notice; **no code is
  actually verified**.
- Back to login returns to the existing Login UI.

The supplied official branding artwork is embedded in
`assets/branding/toward_him_logo.svg` as raster content, not editable
vector paths.

## Validation
`flutter pub get && flutter analyze && flutter test test/widget_test.dart test/create_account_screen_test.dart test/login_screen_test.dart test/forgot_password_screen_test.dart`

The targeted GitHub workflow performs the same checks on `main`.
iOS simulator builds require macOS. Only run
`dart run flutter_native_splash:create` when changing native splash assets.
