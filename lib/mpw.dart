import 'package:cryptography/cryptography.dart';

Future<void> getKey() async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 32 * 8,
  );

  // Password we want to hash
  final secretKey = SecretKey([1,2,3]);

  // A random salt
  final nonce = [4,5,6];

  // Calculate a hash that can be stored in the database
  final newSecretKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: nonce,
  );
  final newSecretKeyBytes = await newSecretKey.extractBytes();
  print('Result: $newSecretKeyBytes');
}