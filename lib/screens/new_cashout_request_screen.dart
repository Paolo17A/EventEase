import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/dropdown_widget.dart';
import 'package:event_ease/widgets/event_ease_textfield_widget.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NewCashoutRequestScreen extends StatefulWidget {
  const NewCashoutRequestScreen({super.key});

  @override
  State<NewCashoutRequestScreen> createState() =>
      _NewCashoutRequestScreenState();
}

class _NewCashoutRequestScreenState extends State<NewCashoutRequestScreen> {
  bool _isLoading = false;

  List<DocumentSnapshot> incomeDocs = [];
  List<DocumentSnapshot> cashoutDocs = [];
  double maxRequestableAmount = 0;

  final amountController = TextEditingController();
  String paymentChannel = '';
  final accountNumberController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCashOutRequests();
  }

  void getCashOutRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get all Income
      final incomes = await FirebaseFirestore.instance
          .collection('incomes')
          .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      incomeDocs = incomes.docs;

      //  Get all Cashout
      final cashout = await FirebaseFirestore.instance
          .collection('cashouts')
          .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      cashoutDocs = cashout.docs;

      double totalIncome = 0;
      for (var income in incomeDocs) {
        final incomeData = income.data() as Map<dynamic, dynamic>;
        double receivedAmount = incomeData['receivedAmount'];
        totalIncome += receivedAmount;
      }

      double totalCashout = 0;
      for (var cashout in cashoutDocs) {
        final cashoutData = cashout.data() as Map<dynamic, dynamic>;
        double requestedAmount = cashoutData['requestedAmount'];
        totalCashout += requestedAmount;
      }
      maxRequestableAmount = totalIncome - totalCashout;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting cashout requests: $error')));
    }
  }

  void makeWithdrawalRequest() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (amountController.text.isEmpty ||
        paymentChannel.isEmpty ||
        accountNumberController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please fill up all required fields.')));
      return;
    }
    if (double.tryParse(amountController.text) == null ||
        double.parse(amountController.text) > maxRequestableAmount) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(
              'Please fill enter a withdrawable amount not exceeding ${formatPrice(double.parse(amountController.text))}')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      //  Create an entry in the income collection
      String cashoutID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('cashouts')
          .doc(cashoutID)
          .set({
        'requestedAmount': double.parse(amountController.text),
        'receiver': FirebaseAuth.instance.currentUser!.uid,
        'status': 'PENDING APPROVAL',
        'verified': false,
        'dateRequested': DateTime.now(),
        'proofOfPayment': '',
        'paymentChannel': paymentChannel,
        'accountNumber': accountNumberController.text
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully made withdrawal request!')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.cashOutHistory);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error making withdrawal request: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: emptyWhiteAppBar(context),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: Column(
                children: [
                  midnightBGHeaderText(context,
                      label: 'NEW WITHDRAWAL REQUEST', fontSize: 25),
                  all20Pix(
                    child: Column(
                      children: [
                        _maxAmount(),
                        Gap(25),
                        _inputAmountField(),
                        _paymentChannel(),
                        _accountNumberField(),
                        Gap(40),
                        _submitRequestButton()
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _maxAmount() {
    return comicNeueText(
        label:
            'You may withdraw a maximum amount of: PHP ${formatPrice(maxRequestableAmount)}',
        fontWeight: FontWeight.bold,
        fontSize: 24);
  }

  Widget _inputAmountField() {
    return vertical10Pix(
      child: Column(children: [
        comicNeueText(
            label: 'Desired Withdrawal Amount',
            fontWeight: FontWeight.bold,
            fontSize: 19),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40,
          child: EventEaseTextField(
              text: '',
              controller: amountController,
              textInputType: TextInputType.numberWithOptions(decimal: true)),
        )
      ]),
    );
  }

  Widget _paymentChannel() {
    return Column(
      children: [
        comicNeueText(
            label: 'Desired Withdrawal Channel',
            fontWeight: FontWeight.bold,
            fontSize: 19),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40,
          decoration: BoxDecoration(
              color: CustomColors.midnightExtress,
              borderRadius: BorderRadius.circular(30)),
          child: dropdownWidget(paymentChannel, (newValue) {
            setState(() {
              paymentChannel = newValue!;
            });
          }, ['G-CASH', 'PAYMAYA', 'BDO'], '', false),
        ),
      ],
    );
  }

  Widget _accountNumberField() {
    return vertical10Pix(
      child: Column(children: [
        comicNeueText(
            label: 'Account Number', fontWeight: FontWeight.bold, fontSize: 19),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 40,
          child: EventEaseTextField(
              text: '',
              controller: accountNumberController,
              textInputType: TextInputType.numberWithOptions(decimal: false)),
        )
      ]),
    );
  }

  Widget _submitRequestButton() {
    return ElevatedButton(
        onPressed: makeWithdrawalRequest,
        child: all20Pix(
            child: Text('Make Withdrawal Request',
                style: buttonSweetCornStyle())));
  }
}
