# Env Switcher

A Flutter package that allows users to switch between different environment configurations (dev, staging, production) using a secret tap gesture. Perfect for QA testing and development builds.

## Features

- 🎯 **Secret Tap Gesture**: Tap a widget (like your logo) multiple times to reveal the environment switcher
- 🔄 **Multiple Environments**: Support for unlimited environment configurations (dev, staging, production, etc.)
- 💾 **Persistent Selection**: Remembers the selected environment across app restarts
- 🎨 **Customizable UI**: Beautiful bottom sheet with customizable title, subtitle, and styling
- 📦 **Type-Safe**: Strongly typed environment configurations with extras support
- 🔔 **Change Notifications**: Get notified when environment changes
- ⚡ **Easy Integration**: Simple API with minimal setup required

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  env_switcher: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Define Your Environments

```dart
import 'package:env_switcher/env_switcher.dart';

final environments = [
  EnvConfig(
    name: 'dev',
    displayName: 'Development',
    baseUrl: 'https://dev-api.example.com',
    extras: {
      'apiKey': 'dev-api-key-12345',
      'enableLogging': true,
    },
  ),
  EnvConfig(
    name: 'staging',
    displayName: 'Staging',
    baseUrl: 'https://staging-api.example.com',
    extras: {
      'apiKey': 'staging-api-key-67890',
      'enableLogging': true,
    },
  ),
  EnvConfig(
    name: 'production',
    displayName: 'Production',
    baseUrl: 'https://api.example.com',
    extras: {
      'apiKey': 'prod-api-key-abcdef',
      'enableLogging': false,
    },
  ),
];
```

### 2. Initialize the Environment Manager

In your `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment manager
  await EnvManager().initialize(
    environments: environments,
    defaultEnvironment: environments[0], // Dev as default
  );
  
  runApp(MyApp());
}
```

### 3. Add the Tap Gesture to Your Logo

Wrap your logo or any widget with `EnvSwitcherWidget`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: EnvSwitcherWidget(
            requiredTaps: 5, // Tap 5 times to trigger
            child: Text('My App'),
            onEnvironmentChanged: () {
              // Optional: Handle environment change
              // You might want to restart your app here
              print('Environment changed!');
            },
          ),
        ),
        body: Center(
          child: Text('Current Env: ${EnvManager().currentEnvironment?.displayName}'),
        ),
      ),
    );
  }
}
```

### 4. Access Current Environment

```dart
// Get current environment
final currentEnv = EnvManager().currentEnvironment;
print('Base URL: ${currentEnv?.baseUrl}');

// Get extra values
final apiKey = EnvManager().getExtra<String>('apiKey');
final enableLogging = EnvManager().getExtra<bool>('enableLogging');

// Use in your API client
class ApiClient {
  String get baseUrl => EnvManager().currentEnvironment?.baseUrl ?? '';
  
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/data'));
    // ...
  }
}
```

### 5. Listen to Environment Changes

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    EnvManager().addListener(_onEnvChanged);
  }
  
  @override
  void dispose() {
    EnvManager().removeListener(_onEnvChanged);
    super.dispose();
  }
  
  void _onEnvChanged() {
    setState(() {
      // Update UI when environment changes
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Text('Env: ${EnvManager().currentEnvironment?.displayName}');
  }
}
```

## Advanced Usage

### Custom Tap Configuration

```dart
EnvSwitcherWidget(
  requiredTaps: 7, // Require 7 taps instead of 5
  tapWindowMs: 5000, // 5 seconds window for all taps
  enabled: true, // Can be toggled based on build mode
  showTapFeedback: true, // Visual feedback on tap
  bottomSheetTitle: 'Switch Environment',
  bottomSheetSubtitle: 'Select your preferred environment',
  requiresRestart: true, // Show restart warning
  child: YourLogo(),
)
```

### Conditional Enabling (Release Builds)

```dart
EnvSwitcherWidget(
  enabled: !kReleaseMode, // Only enable in debug/profile mode
  child: YourLogo(),
)
```

### Manual Environment Switch

```dart
// Programmatically switch environment
await EnvManager().switchEnvironment(environments[1]);
```

### Show Bottom Sheet Manually

```dart
EnvSelectorBottomSheet.show(
  context,
  onEnvironmentChanged: () {
    print('Environment changed');
  },
);
```

## API Reference

### EnvConfig

```dart
EnvConfig(
  name: String,           // Unique identifier
  displayName: String,    // User-friendly name
  baseUrl: String,        // Base API URL
  extras: Map,            // Additional configuration
)
```

### EnvManager

```dart
// Initialize
await EnvManager().initialize(
  environments: List<EnvConfig>,
  defaultEnvironment: EnvConfig?,
)

// Access
EnvConfig? currentEnvironment
List<EnvConfig> availableEnvironments
bool isInitialized

// Methods
await switchEnvironment(EnvConfig)
T? getExtra<T>(String key)
await reset(EnvConfig)
await clearSaved()
```

### EnvSwitcherWidget

```dart
EnvSwitcherWidget(
  child: Widget,                    // Widget to wrap (required)
  requiredTaps: int = 5,           // Number of taps needed
  tapWindowMs: int = 3000,         // Time window for taps
  enabled: bool = true,            // Enable/disable feature
  onEnvironmentChanged: void Function()?,
  requiresRestart: bool = true,
  bottomSheetTitle: String,
  bottomSheetSubtitle: String,
  showTapFeedback: bool = true,
)
```

## Example App

Check out the [example](example/) folder for a complete working example.

## Tips

1. **Production Safety**: Use `enabled: !kReleaseMode` to disable the switcher in production builds
2. **App Restart**: After switching environments, you may need to restart your app or reinitialize services
3. **Secure Keys**: Don't hardcode production API keys in your app - use environment variables or secure storage
4. **Testing**: Use different tap counts for different widgets to avoid accidental triggers

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details
