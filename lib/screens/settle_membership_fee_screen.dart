import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

class SettleMembershipFeeScreen extends StatefulWidget {
  const SettleMembershipFeeScreen({super.key});

  @override
  State<SettleMembershipFeeScreen> createState() =>
      _SettleMembershipFeeScreenState();
}

class _SettleMembershipFeeScreenState extends State<SettleMembershipFeeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: comicNeueText(label: 'SETTLE MEMBERSHIP FEE'),
    ));
  }
}
