import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:env_switcher/src/env_config.dart';

/// Singleton class to manage environment configurations
class EnvManager extends ChangeNotifier {
  static final EnvManager _instance = EnvManager._internal();
  factory EnvManager() => _instance;
  EnvManager._internal();

  static const String _storageKey = 'env_switcher_selected_env';

  List<EnvConfig> _availableEnvironments = [];
  EnvConfig? _currentEnvironment;
  bool _isInitialized = false;

  /// Get the current selected environment
  EnvConfig? get currentEnvironment => _currentEnvironment;

  /// Get all available environments
  List<EnvConfig> get availableEnvironments => List.unmodifiable(_availableEnvironments);

  /// Check if manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the environment manager with available environments
  Future<void> initialize({
    required List<EnvConfig> environments,
    EnvConfig? defaultEnvironment,
  }) async {
    if (_isInitialized) {
      debugPrint('EnvManager: Already initialized');
      return;
    }

    if (environments.isEmpty) {
      throw ArgumentError('At least one environment must be provided');
    }

    _availableEnvironments = environments;

    // Try to load saved environment
    final prefs = await SharedPreferences.getInstance();
    final savedEnvName = prefs.getString(_storageKey);

    if (savedEnvName != null) {
      _currentEnvironment = _availableEnvironments.firstWhere(
        (env) => env.name == savedEnvName,
        orElse: () => defaultEnvironment ?? _availableEnvironments.first,
      );
    } else {
      _currentEnvironment = defaultEnvironment ?? _availableEnvironments.first;
    }

    _isInitialized = true;
    notifyListeners();
    debugPrint('EnvManager: Initialized with ${_currentEnvironment?.name}');
  }

  /// Switch to a different environment
  Future<void> switchEnvironment(EnvConfig newEnvironment) async {
    if (!_availableEnvironments.contains(newEnvironment)) {
      throw ArgumentError('Environment ${newEnvironment.name} is not available');
    }

    _currentEnvironment = newEnvironment;

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, newEnvironment.name);

    notifyListeners();
    debugPrint('EnvManager: Switched to ${newEnvironment.name}');
  }

  /// Get an extra value from current environment
  T? getExtra<T>(String key) {
    return _currentEnvironment?.extras[key] as T?;
  }

  /// Reset to default environment
  Future<void> reset(EnvConfig defaultEnvironment) async {
    await switchEnvironment(defaultEnvironment);
  }

  /// Clear saved environment (will use default on next init)
  Future<void> clearSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    debugPrint('EnvManager: Cleared saved environment');
  }
}
