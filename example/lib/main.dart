import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:env_switcher/env_switcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Define your environments
  final environments = [
    const EnvConfig(
      name: 'dev',
      displayName: 'Development',
      baseUrl: 'https://dev-api.example.com',
      extras: {
        'apiKey': 'dev-api-key-12345',
        'enableLogging': true,
        'timeout': 30,
        'features': {
          'newUI': true,
          'analytics': false,
        },
      },
    ),
    const EnvConfig(
      name: 'staging',
      displayName: 'Staging',
      baseUrl: 'https://staging-api.example.com',
      extras: {
        'apiKey': 'staging-api-key-67890',
        'enableLogging': true,
        'timeout': 20,
        'features': {
          'newUI': true,
          'analytics': true,
        },
      },
    ),
    const EnvConfig(
      name: 'production',
      displayName: 'Production',
      baseUrl: 'https://api.example.com',
      extras: {
        'apiKey': 'prod-api-key-abcdef',
        'enableLogging': false,
        'timeout': 10,
        'features': {
          'newUI': false,
          'analytics': true,
        },
      },
    ),
  ];

  // Initialize the environment manager
  await EnvManager().initialize(
    environments: environments,
    defaultEnvironment: environments[0], // Dev as default
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Env Switcher Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EnvManager _envManager = EnvManager();

  @override
  void initState() {
    super.initState();
    _envManager.addListener(_onEnvChanged);
  }

  @override
  void dispose() {
    _envManager.removeListener(_onEnvChanged);
    super.dispose();
  }

  void _onEnvChanged() {
    setState(() {});
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Environment changed to ${_envManager.currentEnvironment?.displayName}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEnv = _envManager.currentEnvironment;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: EnvSwitcherWidget(
          requiredTaps: 5,
          enabled: !kReleaseMode, // Only enable in debug/profile mode
          onEnvironmentChanged: () {
            // You can add additional logic here
            // For example, restart services, clear cache, etc.
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flutter_dash,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Env Switcher Demo'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Manual trigger
              EnvSelectorBottomSheet.show(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 How to Use',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the app logo in the app bar 5 times quickly to open the environment switcher!',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Or tap the settings icon to open it manually.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Environment
            Text(
              'Current Environment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.cloud,
              title: currentEnv?.displayName ?? 'Not Set',
              subtitle: currentEnv?.name ?? '',
              color: _getEnvColor(currentEnv?.name),
            ),
            const SizedBox(height: 24),

            // Environment Details
            Text(
              'Environment Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.link,
              title: 'Base URL',
              subtitle: currentEnv?.baseUrl ?? 'N/A',
            ),
            _buildInfoCard(
              icon: Icons.key,
              title: 'API Key',
              subtitle: _envManager.getExtra<String>('apiKey') ?? 'N/A',
            ),
            _buildInfoCard(
              icon: Icons.timer,
              title: 'Timeout',
              subtitle: '${_envManager.getExtra<int>('timeout') ?? 0} seconds',
            ),
            _buildInfoCard(
              icon: Icons.bug_report,
              title: 'Logging Enabled',
              subtitle: _envManager.getExtra<bool>('enableLogging') == true
                  ? 'Yes'
                  : 'No',
            ),
            const SizedBox(height: 24),

            // Feature Flags
            Text(
              'Feature Flags',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final features = _envManager.getExtra<Map>('features');
                if (features == null) {
                  return const Text('No feature flags available');
                }
                return Column(
                  children: features.entries.map((entry) {
                    return _buildInfoCard(
                      icon: entry.value == true
                          ? Icons.check_circle
                          : Icons.cancel,
                      title: entry.key,
                      subtitle: entry.value == true ? 'Enabled' : 'Disabled',
                      color: entry.value == true ? Colors.green : Colors.red,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Available Environments
            Text(
              'Available Environments',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._envManager.availableEnvironments.map((env) {
              final isCurrent = env == currentEnv;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getEnvColor(env.name),
                    child: Text(
                      env.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    env.displayName,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(env.baseUrl),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => EnvSelectorBottomSheet.show(context),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Switch Env'),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getEnvColor(String? envName) {
    switch (envName) {
      case 'dev':
        return Colors.blue;
      case 'staging':
        return Colors.orange;
      case 'production':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
