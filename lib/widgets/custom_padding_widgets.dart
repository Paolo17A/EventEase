import 'package:flutter/material.dart';

Padding all20Pix({required Widget child}) {
  return Padding(padding: const EdgeInsets.all(20), child: child);
}

Padding vertical10Pix({required Widget child}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), child: child);
}
