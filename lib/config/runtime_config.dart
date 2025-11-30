import '../secrets.dart';

/// RuntimeConfig centralizes resolution of environment-provided secrets.
/// Priority order:
/// 1. --dart-define=GROQ_API_KEY at launch (compile-time environment)
/// 2. Value from `secrets.dart` (development fallback)
///
/// To launch with a key without modifying source:
/// flutter run --dart-define=GROQ_API_KEY=YOUR_KEY_HERE
class RuntimeConfig {
  static final String groqApiKey = _resolveGroqKey();
  static final String functionsBaseUrl = _resolveFunctionsBaseUrl();

  static String _resolveGroqKey() {
    const envValue = String.fromEnvironment('GROQ_API_KEY');
    if (envValue.isNotEmpty) return envValue;
    // Fallback to secrets.dart constant (dev only)
    return Secrets.groqApiKey;
  }

  static String _resolveFunctionsBaseUrl() {
    const envValue = String.fromEnvironment('FUNCTIONS_BASE_URL');
    if (envValue.isNotEmpty) return envValue;
    // Placeholder; user should supply real deployed functions base URL via --dart-define.
    return 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net';
  }
}
