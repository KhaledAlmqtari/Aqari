import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../../domain/entities/pin_credential.dart';

/// PinLocalDataSource securely hashes and stores the user PIN using PBKDF2-HMAC-SHA256.
class PinLocalDataSource {
  final FlutterSecureStorage storage;

  PinLocalDataSource(this.storage);

  static const _key = 'pin_credential';
  static const _attemptKey = 'pin_failed_attempts';
  static const _lockKey = 'pin_lock_until';

  final _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Future<String> _derive(String pin, List<int> salt) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    return base64Encode(await key.extractBytes());
  }

  /// Checks if a PIN has been established by the user.
  /// Uses a safe timeout and try-catch to prevent hanging across platforms.
  Future<bool> hasPin() async {
    try {
      final value = await storage.read(key: _key).timeout(
            const Duration(seconds: 2),
            onTimeout: () => null,
          );
      return value != null;
    } catch (_) {
      return false;
    }
  }

  /// Hashes and securely stores a new PIN.
  Future<void> createPin(String pin) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));

    final hash = await _derive(pin, salt);

    final credential = PinCredential(
      salt: base64Encode(salt),
      hash: hash,
    );

    await storage.write(
      key: _key,
      value: jsonEncode({
        'salt': credential.salt,
        'hash': credential.hash,
      }),
    );

    await storage.delete(key: _attemptKey);
    await storage.delete(key: _lockKey);
  }

  /// Verifies entered PIN against stored PBKDF2 hash.
  Future<bool> verifyPin(String pin) async {
    try {
      final lockUntilStr = await storage.read(key: _lockKey);
      final lockUntil = int.tryParse(lockUntilStr ?? '');

      if (lockUntil != null &&
          DateTime.now().millisecondsSinceEpoch < lockUntil) {
        throw Exception('PIN_LOCKED');
      }

      final raw = await storage.read(key: _key);
      if (raw == null) return false;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final salt = base64Decode(data['salt'] as String);
      final expected = data['hash'] as String;

      final actual = await _derive(pin, salt);

      if (actual == expected) {
        await storage.delete(key: _attemptKey);
        await storage.delete(key: _lockKey);
        return true;
      }

      final attempts = int.tryParse(
            await storage.read(key: _attemptKey) ?? '0',
          ) ??
          0;

      final nextAttempts = attempts + 1;

      await storage.write(
        key: _attemptKey,
        value: nextAttempts.toString(),
      );

      if (nextAttempts >= 5) {
        final until = DateTime.now()
            .add(const Duration(seconds: 30))
            .millisecondsSinceEpoch;

        await storage.write(
          key: _lockKey,
          value: until.toString(),
        );

        await storage.write(key: _attemptKey, value: '0');
      }

      return false;
    } catch (e) {
      if (e.toString().contains('PIN_LOCKED')) rethrow;
      return false;
    }
  }
}
