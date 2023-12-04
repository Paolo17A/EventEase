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

String formatPrice(double amount) {
  // Round the amount to two decimal places
  amount = double.parse((amount).toStringAsFixed(2));

  // Convert the double to a string and split it into whole and decimal parts
  List<String> parts = amount.toString().split('.');

  // Format the whole part with commas
  String formattedWhole = '';
  for (int i = 0; i < parts[0].length; i++) {
    if (i != 0 && (parts[0].length - i) % 3 == 0) {
      formattedWhole += ',';
    }
    formattedWhole += parts[0][i];
  }

  // If there's a decimal part, add it back
  String formattedAmount = formattedWhole;
  if (parts.length > 1) {
    formattedAmount += '.' + (parts[1].length == 1 ? '${parts[1]}0' : parts[1]);
  } else {
    // If there's no decimal part, append '.00'
    formattedAmount += '.00';
  }

  return formattedAmount;
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
