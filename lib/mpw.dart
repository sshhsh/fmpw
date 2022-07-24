import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:fmpw/scrypt.dart';

class _Send {
  SendPort p;
  String nameStr;
  String passwordStr;
  _Send(this.p, this.nameStr, this.passwordStr);
}

class MPW {
  static const String NS = "com.lyndir.masterpassword";
  Future<Uint8List> key;
  MPW(String name, String password) : key = calculateKeyInBack(name, password);

  static Future<Uint8List> calculateKeyInBack(
      String nameStr, String passwordStr) async {
    final p = ReceivePort();
    await Isolate.spawn(
        _returnKeyInBack, _Send(p.sendPort, nameStr, passwordStr));
    return await p.first as Uint8List;
  }

  static Future<void> _returnKeyInBack(_Send send) async {
    final key = await calculateKey(send.nameStr, send.passwordStr);
    print(key);
    Isolate.exit(send.p, key);
  }

  static Future<Uint8List> calculateKey(String nameStr, String passwordStr) {
    final nameCharLength = nameStr.length;
    final name = utf8.encoder.convert(nameStr);
    final password = utf8.encoder.convert(passwordStr);
    final NS = utf8.encoder.convert(MPW.NS);
    final salt = Uint8List(NS.length + 4 + name.length);
    var i = 0;
    salt.setRange(i, i += NS.length, NS);
    ByteData.sublistView(salt).setUint32(i, nameCharLength, Endian.big);
    i += 4;
    salt.setRange(i, i += name.length, name);

    return scrypt(
        password, salt, 32768/*= n*/, 8/*= r*/, 2/*= p*/, 64/*= buflen*/);
  }

  Future<Uint8List> calculateSeed(String siteStr,
      {int counter = 1, String contextStr = "", String NSStr = MPW.NS}) async {
    if (siteStr.isEmpty) {
      throw Exception("Argument site not present");
    }
    if (counter < 1 || counter > 0xffffffff) {
      throw Exception("Argument counter out of range");
    }

    final site = utf8.encoder.convert(siteStr);
    final NS = utf8.encoder.convert(NSStr);
    final context =
        contextStr.isEmpty ? null : utf8.encoder.convert(contextStr);

    final data = Uint8List(NS.length +
        4 /*sizeof(uint32)*/ +
        site.length +
        4 /*sizeof(int32)*/
        +
        (context != null ? 4 /*sizeof(uint32)*/ + context.length : 0));
    final dataView = ByteData.sublistView(data);
    var i = 0;

    data.setRange(i, i += NS.length, NS);
    dataView.setUint32(i, site.length, Endian.big);
    i += 4;
    data.setRange(i, i += site.length, site);
    dataView.setUint32(i, counter, Endian.big);
    i += 4;

    if (context != null) {
      dataView.setUint32(i, context.length, Endian.big);
      i += 4;
      data.setRange(i, i += context.length, site);
    }

    return Uint8List.fromList((await Hmac.sha256()
            .calculateMac(data, secretKey: SecretKey(await key)))
        .bytes);
  }

  Future<String> generate(String site,
      {int counter = 1,
      String context = "",
      String template = "long",
      String NS = MPW.NS}) async {
    final templateList = templates[template];
    if (templateList == null) {
      throw Exception("Argument template invalid");
    }

    final seed = await calculateSeed(site,
        counter: counter, contextStr: context, NSStr: NS);
    final templateStr = templateList[seed[0] % templateList.length];
    var i = 0;
    return templateStr.split("").map((c) {
      final chars = passchars[c];
      if (chars == null) {
        throw Exception("passchars invalid");
      }
      final res = chars[seed[i + 1] % chars.length];
      i++;
      return res;
    }).join();
  }

  static const templates = {
    "maximum": ["anoxxxxxxxxxxxxxxxxx", "axxxxxxxxxxxxxxxxxno"],
    "long": [
      "CvcvnoCvcvCvcv",
      "CvcvCvcvnoCvcv",
      "CvcvCvcvCvcvno",
      "CvccnoCvcvCvcv",
      "CvccCvcvnoCvcv",
      "CvccCvcvCvcvno",
      "CvcvnoCvccCvcv",
      "CvcvCvccnoCvcv",
      "CvcvCvccCvcvno",
      "CvcvnoCvcvCvcc",
      "CvcvCvcvnoCvcc",
      "CvcvCvcvCvccno",
      "CvccnoCvccCvcv",
      "CvccCvccnoCvcv",
      "CvccCvccCvcvno",
      "CvcvnoCvccCvcc",
      "CvcvCvccnoCvcc",
      "CvcvCvccCvccno",
      "CvccnoCvcvCvcc",
      "CvccCvcvnoCvcc",
      "CvccCvcvCvccno"
    ],
    "medium": ["CvcnoCvc", "CvcCvcno"],
    "basic": ["aaanaaan", "aannaaan", "aaannaaa"],
    "short": ["Cvcn"],
    "pin": ["nnnn"],
    "name": ["cvccvcvcv"],
    "phrase": [
      "cvcc cvc cvccvcv cvc",
      "cvc cvccvcvcv cvcv",
      "cv cvccv cvc cvcvccv"
    ]
  };
  static const passchars = {
    "V": "AEIOU",
    "C": "BCDFGHJKLMNPQRSTVWXYZ",
    "v": "aeiou",
    "c": "bcdfghjklmnpqrstvwxyz",
    "A": "AEIOUBCDFGHJKLMNPQRSTVWXYZ",
    "a": "AEIOUaeiouBCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz",
    "n": "0123456789",
    "o": "@&%?,=[]_:-+*\$#!'^~;()/.",
    "x":
        "AEIOUaeiouBCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz0123456789!@#\$%^&*()",
    " ": " "
  };
}
