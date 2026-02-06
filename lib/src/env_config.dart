/// Represents an environment configuration
class EnvConfig {
  final String name;
  final String displayName;
  final String baseUrl;
  final Map<String, dynamic> extras;

  const EnvConfig({
    required this.name,
    required this.displayName,
    required this.baseUrl,
    this.extras = const {},
  });

  /// Create a copy with some fields replaced
  EnvConfig copyWith({
    String? name,
    String? displayName,
    String? baseUrl,
    Map<String, dynamic>? extras,
  }) {
    return EnvConfig(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      baseUrl: baseUrl ?? this.baseUrl,
      extras: extras ?? this.extras,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'baseUrl': baseUrl,
      'extras': extras,
    };
  }

  /// Create from JSON
  factory EnvConfig.fromJson(Map<String, dynamic> json) {
    return EnvConfig(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      baseUrl: json['baseUrl'] as String,
      extras: json['extras'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EnvConfig && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'EnvConfig(name: $name, displayName: $displayName, baseUrl: $baseUrl)';
}
