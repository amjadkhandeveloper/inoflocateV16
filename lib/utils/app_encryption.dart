import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' hide Mac;

/// AES-256-CBC + HMAC-SHA256 used by InfoLocate client-auth (`URLAuthorization`).
///
/// Matches the Android `Encrypted` helper: random hex IV, PKCS7 padding, and
/// payload layout `IV + hmacKey + hmac + ciphertext` (all hex).
class AppEncryption {
  AppEncryption._();

  static const String hexKey =
      '296D7C7CBBE1CC1067F92CA1743284A1D9BA295DE02D6D527A5E4DA2069173BF';

  static final Random _random = Random.secure();

  static String encryptData(String text) {
    final hexIV = _generateRandomHex(16);
    final cipherHexStr =
        _toHex(_aesCbc(utf8.encode(text), hexIV, encrypt: true));
    final hmacHexKey = _generateRandomHex(16);
    final hmacHexStr = _computeHmac(hexIV, cipherHexStr, hmacHexKey);
    return '$hexIV$hmacHexKey$hmacHexStr$cipherHexStr';
  }

  /// Returns plaintext, empty string for a null input, or null when decrypt fails.
  static String? decryptData(String? hexStr) {
    if (hexStr == null) return '';
    if (hexStr.isEmpty || hexStr == 'null') return null;
    if (hexStr.length <= 128) return null;

    final hexIV = hexStr.substring(0, 32);
    final hmacHexKey = hexStr.substring(32, 64);
    final hmacHexStr = hexStr.substring(64, 128);
    final cipherHexStr = hexStr.substring(128);
    final computed = _computeHmac(hexIV, cipherHexStr, hmacHexKey);
    if (computed.toLowerCase() != hmacHexStr.toLowerCase()) return null;

    final decrypted = _aesCbc(_fromHex(cipherHexStr), hexIV, encrypt: false);
    return utf8.decode(decrypted);
  }

  static String _generateRandomHex(int byteLength) {
    const alphabet = 'abcdef0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < byteLength * 2; i++) {
      buffer.write(alphabet[_random.nextInt(alphabet.length)]);
    }
    return buffer.toString().replaceAll('00', '11');
  }

  static String _computeHmac(
    String hexIV,
    String cipherHexStr,
    String hmacHexKey,
  ) {
    final hexString = (hexIV + cipherHexStr + hexKey).toLowerCase();
    final hmac = Hmac(sha256, utf8.encode(hmacHexKey.toLowerCase()));
    return hmac.convert(utf8.encode(hexString)).toString();
  }

  static Uint8List _aesCbc(
    List<int> data,
    String hexIV, {
    required bool encrypt,
  }) {
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    )..init(
        encrypt,
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(_fromHex(hexKey)), _fromHex(hexIV)),
          null,
        ),
      );
    return cipher.process(Uint8List.fromList(data));
  }

  static Uint8List _fromHex(String hex) {
    final normalized = hex.trim().replaceAll(' ', '').toLowerCase();
    final out = Uint8List(normalized.length ~/ 2);
    for (var i = 0; i < normalized.length; i += 2) {
      out[i ~/ 2] = int.parse(normalized.substring(i, i + 2), radix: 16);
    }
    return out;
  }

  static String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
