import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

// blockXOR XORs numbers from dst with n numbers from src.
void blockXOR(Uint32List dst, Uint32List src, int n) {
  for (var i = 0; i < n; i++) {
    dst[i] ^= src[i];
  }
}

extension RotateLeft32 on int {
  int rotateLeft32(int n) {
    final x = this & 0xffffffff;
    return (x << n | x >> (32 - n)) & 0xffffffff;
  }
}

void salsaXOR(Uint32List tmp, Uint32List inp, Uint32List out) {
  assert(tmp.length == 16);
  Uint32List x = Uint32List(16);
  Uint32List w = Uint32List(16);
  for (var i = 0; i < 16; i++) {
    w[i] = tmp[i] ^ inp[i];
    x[i] = w[i];
  }
  for (var i = 0; i < 8; i += 2) {
    x[4] ^= (x[0] + x[12]).rotateLeft32(7);
    x[8] ^= (x[4] + x[0]).rotateLeft32(9);
    x[12] ^= (x[8] + x[4]).rotateLeft32(13);
    x[0] ^= (x[12] + x[8]).rotateLeft32(18);

    x[9] ^= (x[5] + x[1]).rotateLeft32(7);
    x[13] ^= (x[9] + x[5]).rotateLeft32(9);
    x[1] ^= (x[13] + x[9]).rotateLeft32(13);
    x[5] ^= (x[1] + x[13]).rotateLeft32(18);

    x[14] ^= (x[10] + x[6]).rotateLeft32(7);
    x[2] ^= (x[14] + x[10]).rotateLeft32(9);
    x[6] ^= (x[2] + x[14]).rotateLeft32(13);
    x[10] ^= (x[6] + x[2]).rotateLeft32(18);

    x[3] ^= (x[15] + x[11]).rotateLeft32(7);
    x[7] ^= (x[3] + x[15]).rotateLeft32(9);
    x[11] ^= (x[7] + x[3]).rotateLeft32(13);
    x[15] ^= (x[11] + x[7]).rotateLeft32(18);

    x[1] ^= (x[0] + x[3]).rotateLeft32(7);
    x[2] ^= (x[1] + x[0]).rotateLeft32(9);
    x[3] ^= (x[2] + x[1]).rotateLeft32(13);
    x[0] ^= (x[3] + x[2]).rotateLeft32(18);

    x[6] ^= (x[5] + x[4]).rotateLeft32(7);
    x[7] ^= (x[6] + x[5]).rotateLeft32(9);
    x[4] ^= (x[7] + x[6]).rotateLeft32(13);
    x[5] ^= (x[4] + x[7]).rotateLeft32(18);

    x[11] ^= (x[10] + x[9]).rotateLeft32(7);
    x[8] ^= (x[11] + x[10]).rotateLeft32(9);
    x[9] ^= (x[8] + x[11]).rotateLeft32(13);
    x[10] ^= (x[9] + x[8]).rotateLeft32(18);

    x[12] ^= (x[15] + x[14]).rotateLeft32(7);
    x[13] ^= (x[12] + x[15]).rotateLeft32(9);
    x[14] ^= (x[13] + x[12]).rotateLeft32(13);
    x[15] ^= (x[14] + x[13]).rotateLeft32(18);
  }

  for (var i = 0; i < 16; i++) {
    tmp[i] = x[i] + w[i];
    out[i] = tmp[i];
  }
}

void blockMix(Uint32List inp, Uint32List out, int r) {
  final tmp = inp.sublist((2 * r - 1) * 16, 2 * r * 16);
  for (var i = 0; i < 2 * r; i += 2) {
    salsaXOR(tmp, Uint32List.sublistView(inp, i * 16),
        Uint32List.sublistView(out, i * 8));
    salsaXOR(tmp, Uint32List.sublistView(inp, (i + 1) * 16),
        Uint32List.sublistView(out, (i + 2 * r) * 8));
  }
}

int integer(Uint32List b, int r) {
  final j = (2 * r - 1) * 16;
  return b[j] | b[j + 1] << 32;
}

void smix(Uint8List b, int r, int N, Uint32List v, Uint32List x, Uint32List y) {
  final R = 32 * r;
  final bView = ByteData.sublistView(b);
  for (var i = 0, j = 0; i < x.length; i++, j += 4) {
    x[i] = bView.getUint32(j, Endian.little);
  }
  for (var i = 0; i < N; i += 2) {
    v.setRange(i * R, (i + 1) * R, x);
    blockMix(x, y, r);

    v.setRange((i + 1) * R, (i + 2) * R, y);
    blockMix(y, x, r);
  }

  for (var i = 0, j = 0; i < N; i += 2) {
    j = integer(x, r) & (N - 1);
    blockXOR(x, Uint32List.sublistView(v, j * R), R);
    blockMix(x, y, r);

    j = integer(y, r) & (N - 1);
    blockXOR(y, Uint32List.sublistView(v, j * R), R);
    blockMix(y, x, r);
  }

  for (var i = 0, j = 0; i < x.length; i++, j += 4) {
    bView.setUint32(j, x[i], Endian.little);
  }
}

Future<Uint8List> scrypt(
    Uint8List password, Uint8List salt, int N, int r, int p, int keyLen) async {
  if (N <= 1 || N & (N - 1) != 0) {
    throw Exception("scrypt: N must be > 1 and a power of 2");
  }
  if (r * p >= 1 << 30 ||
      r > (1 << 31) / 128 / p ||
      r > (1 << 31) / 256 ||
      N > (1 << 31) / 128 / r) {
    throw Exception("scrypt: parameters are too large");
  }

  final x = Uint32List(32 * r);
  final y = Uint32List(32 * r);
  final v = Uint32List(32 * N * r);

  // var b = pbkdf2(passphrase, salt, 1, p * 128 * r, "SHA-256");
  final b = Uint8List.fromList(await (await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 1,
    bits: p * 128 * r * 8,
  ).deriveKey(
    secretKey: SecretKey(password),
    nonce: salt,
  ))
      .extractBytes());

  for (var i = 0; i < p; i++) {
    smix(Uint8List.sublistView(b, i * 128 * r), r, N, v, x, y);
  }
  return Uint8List.fromList(await (await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 1,
    bits: keyLen * 8,
  ).deriveKey(
    secretKey: SecretKey(password),
    nonce: b,
  ))
      .extractBytes());
}
