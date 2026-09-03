import 'package:flutter_test/flutter_test.dart';
import 'package:infolocate/utils/app_encryption.dart';

void main() {
  test('encrypt/decrypt roundtrip matches Android client-auth payload', () {
    const text = 'arslogistics';
    final encrypted = AppEncryption.encryptData(text);
    expect(encrypted.length, greaterThan(128));
    expect(AppEncryption.decryptData(encrypted), text);
  });

  test('decrypts a known production URLAuthorization status field', () {
    const status =
        'b70ee640458032364daa564da97e424fb70ee640458032364daa564da97e424f465936B045028E0BAB4E84A84AFDF757EA905216343469CC2A266B72CD47A6B5C41E5EE4FA308F61DE6D927B1EE37BB7';
    expect(AppEncryption.decryptData(status), 'failure');
  });
}
