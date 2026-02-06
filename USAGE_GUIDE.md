# Env Switcher - Complete Usage Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Basic Setup](#basic-setup)
3. [Advanced Configuration](#advanced-configuration)
4. [Best Practices](#best-practices)
5. [Common Use Cases](#common-use-cases)
6. [Troubleshooting](#troubleshooting)

## Quick Start

### 1. Installation

```yaml
dependencies:
  env_switcher: ^1.0.0
```

### 2. Define Environments

```dart
final environments = [
  EnvConfig(
    name: 'dev',
    displayName: 'Development',
    baseUrl: 'https://dev-api.example.com',
  ),
  EnvConfig(
    name: 'prod',
    displayName: 'Production',
    baseUrl: 'https://api.example.com',
  ),
];
```

### 3. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvManager().initialize(
    environments: environments,
    defaultEnvironment: environments[0],
  );
  runApp(MyApp());
}
```

### 4. Add Tap Gesture

```dart
EnvSwitcherWidget(
  requiredTaps: 5,
  child: Text('Your Logo'),
)
```

## Basic Setup

### Environment Configuration

The `EnvConfig` class holds your environment settings:

```dart
EnvConfig(
  name: 'staging',           // Unique identifier
  displayName: 'Staging',    // User-friendly name
  baseUrl: 'https://...',    // API base URL
  extras: {                  // Additional config
    'apiKey': 'xxx',
    'timeout': 30,
    'features': {...},
  },
)
```

### Initialization Options

```dart
await EnvManager().initialize(
  environments: environments,        // Required: List of configs
  defaultEnvironment: environments[0], // Optional: Default env
);
```

### Accessing Current Environment

```dart
// Get current environment
final env = EnvManager().currentEnvironment;
print(env?.baseUrl);

// Get specific extras
final apiKey = EnvManager().getExtra<String>('apiKey');
final timeout = EnvManager().getExtra<int>('timeout');
```

## Advanced Configuration

### Custom Tap Settings

```dart
EnvSwitcherWidget(
  requiredTaps: 7,              // Number of taps (default: 5)
  tapWindowMs: 5000,            // Time window in ms (default: 3000)
  enabled: !kReleaseMode,       // Conditional enable
  showTapFeedback: true,        // Visual feedback (default: true)
  bottomSheetTitle: 'Custom Title',
  bottomSheetSubtitle: 'Custom subtitle',
  requiresRestart: true,        // Show restart warning
  onEnvironmentChanged: () {    // Callback
    // Handle env change
    restartApp();
  },
  child: YourLogo(),
)
```

### Listening to Environment Changes

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _envManager = EnvManager();

  @override
  void initState() {
    super.initState();
    _envManager.addListener(_handleEnvChange);
  }

  @override
  void dispose() {
    _envManager.removeListener(_handleEnvChange);
    super.dispose();
  }

  void _handleEnvChange() {
    // Reinitialize services
    _apiClient.updateBaseUrl(_envManager.currentEnvironment?.baseUrl);
    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text('Env: ${_envManager.currentEnvironment?.displayName}');
  }
}
```

### Manual Environment Switching

```dart
// Programmatic switch
await EnvManager().switchEnvironment(environments[1]);

// Show bottom sheet manually
EnvSelectorBottomSheet.show(
  context,
  onEnvironmentChanged: () {
    print('Environment changed');
  },
  requiresRestart: false,
  title: 'Select Environment',
  subtitle: 'Choose wisely',
);
```

## Best Practices

### 1. Production Safety

Always disable the switcher in production builds:

```dart
EnvSwitcherWidget(
  enabled: !kReleaseMode, // Only debug/profile
  child: YourLogo(),
)
```

Or use build flavors:

```dart
EnvSwitcherWidget(
  enabled: BuildConfig.isDebug,
  child: YourLogo(),
)
```

### 2. App Restart Handling

After switching environments, you may need to restart services:

```dart
EnvSwitcherWidget(
  onEnvironmentChanged: () async {
    // 1. Clear cached data
    await _cacheManager.clear();
    
    // 2. Reinitialize services
    await _initializeServices();
    
    // 3. Navigate to home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomePage()),
      (route) => false,
    );
    
    // Or use restart package
    // Phoenix.rebirth(context);
  },
  child: YourLogo(),
)
```

### 3. Secure API Keys

Never hardcode production keys:

```dart
// ❌ Bad
EnvConfig(
  name: 'prod',
  extras: {'apiKey': 'hardcoded-key'},
)

// ✅ Good - Use environment variables
EnvConfig(
  name: 'prod',
  extras: {
    'apiKey': const String.fromEnvironment('API_KEY'),
  },
)

// Or use flutter_dotenv
EnvConfig(
  name: 'prod',
  extras: {
    'apiKey': dotenv.env['API_KEY'],
  },
)
```

### 4. Type-Safe Extras

Create a helper class for type-safe access:

```dart
class AppConfig {
  static EnvConfig get current => EnvManager().currentEnvironment!;
  
  static String get apiKey => 
    EnvManager().getExtra<String>('apiKey') ?? '';
  
  static int get timeout => 
    EnvManager().getExtra<int>('timeout') ?? 30;
  
  static bool get isLoggingEnabled => 
    EnvManager().getExtra<bool>('enableLogging') ?? false;
    
  static Map<String, bool> get features =>
    EnvManager().getExtra<Map>('features') ?? {};
}

// Usage
final apiKey = AppConfig.apiKey;
```

## Common Use Cases

### 1. API Client Integration

```dart
class ApiClient {
  late Dio _dio;

  ApiClient() {
    _initializeDio();
    EnvManager().addListener(_onEnvChanged);
  }

  void _initializeDio() {
    final env = EnvManager().currentEnvironment;
    _dio = Dio(BaseOptions(
      baseUrl: env?.baseUrl ?? '',
      connectTimeout: Duration(seconds: env?.extras['timeout'] ?? 30),
    ));
    
    if (env?.extras['enableLogging'] == true) {
      _dio.interceptors.add(LogInterceptor());
    }
  }

  void _onEnvChanged() {
    _initializeDio();
  }

  void dispose() {
    EnvManager().removeListener(_onEnvChanged);
  }
}
```

### 2. Feature Flags

```dart
class FeatureFlags {
  static bool isEnabled(String featureName) {
    final features = EnvManager().getExtra<Map>('features') ?? {};
    return features[featureName] == true;
  }
}

// Usage
if (FeatureFlags.isEnabled('newUI')) {
  return NewHomePage();
} else {
  return OldHomePage();
}
```

### 3. Analytics Configuration

```dart
void initializeAnalytics() {
  final env = EnvManager().currentEnvironment;
  final analyticsKey = env?.extras['analyticsKey'];
  
  if (analyticsKey != null) {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
      env?.name != 'dev',
    );
  }
}
```

### 4. Multiple Tap Triggers

Use different tap counts for different widgets:

```dart
// Logo - 5 taps
EnvSwitcherWidget(
  requiredTaps: 5,
  child: Logo(),
)

// Settings icon - 3 taps
EnvSwitcherWidget(
  requiredTaps: 3,
  child: SettingsIcon(),
)

// Version text - 7 taps
EnvSwitcherWidget(
  requiredTaps: 7,
  child: Text('v1.0.0'),
)
```

## Troubleshooting

### Environment not persisting

Make sure to call `initialize()` before `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvManager().initialize(...); // ← Must await
  runApp(MyApp());
}
```

### Tap gesture not working

1. Check if enabled:
```dart
EnvSwitcherWidget(
  enabled: true, // Make sure this is true
  child: YourWidget(),
)
```

2. Ensure widget is tappable:
```dart
// Widget must be visible and have size
EnvSwitcherWidget(
  child: Container(
    width: 100,
    height: 50,
    child: YourLogo(),
  ),
)
```

### Environment not updating immediately

Use `addListener` to react to changes:

```dart
@override
void initState() {
  super.initState();
  EnvManager().addListener(() {
    setState(() {}); // Trigger rebuild
  });
}
```

### SharedPreferences not working on web

SharedPreferences works on all platforms including web. If you have issues:

1. Clear browser cache
2. Check browser console for errors
3. Ensure you're not in incognito mode

### Multiple initializations

The package prevents multiple initializations. If you need to reinitialize:

```dart
// This is safe - will skip if already initialized
await EnvManager().initialize(...);
```

## Tips & Tricks

1. **Debug Info**: Add version info to see current environment:
```dart
Text('v1.0.0 (${EnvManager().currentEnvironment?.name})')
```

2. **Visual Indicators**: Change app theme based on environment:
```dart
ThemeData(
  primaryColor: _getEnvColor(EnvManager().currentEnvironment?.name),
)
```

3. **Logging**: Log environment info on startup:
```dart
debugPrint('Running on: ${EnvManager().currentEnvironment?.displayName}');
```

4. **Testing**: Create test-specific environments:
```dart
EnvConfig(
  name: 'test',
  displayName: 'Testing',
  baseUrl: 'http://localhost:8080',
)
```

## Support

For issues, questions, or contributions, please visit:
- GitHub Issues: [Your repo]
- Documentation: [Your docs]
- Examples: Check the `example/` folder
