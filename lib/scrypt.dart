

// blockCopy copies n numbers from src into dst.
import 'dart:typed_data';

import 'package:binary/binary.dart';

void blockCopy(Uint32List dst, Uint32List src, int n) {
	dst.setRange(0, n, src);
}

// blockXOR XORs numbers from dst with n numbers from src.
void blockXOR(Uint32List dst, Uint32List src, int n) {
  for (var i = 0; i < n; i++) {
    dst[i] ^= src[i];
  }
}

extension RotateLeft32 on int {
  int rotateLeft32(int n) {
    var x = this & 4294967295;
    return Uint32(x).rotateRightShift(-n).value;
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
  for (var i = 0; i < 8; i+=2) {
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

void main(List<String> args) {
  Uint32List tmp = Uint32List.fromList([1,1,4,8,1,1,4,8,1,1,4,8,1,1,4,8,]);
  Uint32List inp = Uint32List.fromList([5,6,7,9,5,6,7,9,5,6,7,9,5,6,7,9,]);
  
  Uint32List out = Uint32List(16);

  salsaXOR(tmp, inp, out);

  print(tmp);
}