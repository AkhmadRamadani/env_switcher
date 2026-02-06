# env_switcher_example

A demonstration app for the `env_switcher` package.

## How to Run

1. Navigate to the example directory:
```bash
cd example
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How to Use

1. **Secret Tap Gesture**: Tap the app logo (Flutter icon + title) in the app bar **5 times quickly** to open the environment switcher bottom sheet.

2. **Manual Access**: Tap the settings icon in the top right, or tap the "Switch Env" floating action button.

3. **Switch Environment**: Select your desired environment from the bottom sheet and tap "Apply Changes".

4. **View Details**: The home screen displays all environment details, feature flags, and configuration.

## Features Demonstrated

- ✅ Secret tap gesture on logo
- ✅ Manual environment switching
- ✅ Persistent environment selection
- ✅ Real-time UI updates when environment changes
- ✅ Display of all environment configurations
- ✅ Feature flags management
- ✅ Custom extras support
- ✅ Production-safe (disabled in release builds)

## Customization

You can customize the tap behavior in `main.dart`:

```dart
EnvSwitcherWidget(
  requiredTaps: 5,              // Change number of taps
  tapWindowMs: 3000,            // Change time window
  enabled: !kReleaseMode,       // Enable/disable
  showTapFeedback: true,        // Visual feedback
  child: YourWidget(),
)
```
