import 'retry.dart';

/// Wraps an async call with retry + optional fallback result supplier.
Future<T> resilient<T>(Future<T> Function() fn, {int retries = 2, T Function(Object error)? fallback}) async {
  try {
    return await retry(fn, retries: retries);
  } catch (e) {
    if (fallback != null) return fallback(e);
    rethrow;
  }
}
