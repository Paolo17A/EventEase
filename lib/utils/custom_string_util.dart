import 'dart:math';

String generateRandomHexString(int length) {
  final random = Random();
  final codeUnits = List.generate(length ~/ 2, (index) {
    return random.nextInt(255);
  });

  final hexString =
      codeUnits.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}

String getServiceParameter(String serviceOffered) {
  switch (serviceOffered) {
    case 'CATERING':
      return 'catering';
    case 'COSMETOLOGIST':
      return 'cosmetologist';
    case 'GUEST\'S PLACE':
      return 'guestPlace';
    case 'HOST':
      return 'host';
    case 'LIGHT AND SOUND TECHNICIAN':
      return 'technician';
    case 'PHOTOGRAPHER AND VIDEOGRAPHER':
      return 'photographer';
  }
  return '';
}
