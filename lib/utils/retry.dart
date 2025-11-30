import 'dart:math';
import 'dart:async';

/// Simple exponential backoff retry helper with jitter.
Future<T> retry<T>(Future<T> Function() fn, {int retries = 3, Duration baseDelay = const Duration(milliseconds: 400)}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } catch (e) {
      attempt++;
      if (attempt > retries) rethrow;
      final jitterMs = Random().nextInt(150);
      final wait = baseDelay * pow(2, attempt - 1).toInt() + Duration(milliseconds: jitterMs);
      await Future.delayed(wait);
    }
  }
}
