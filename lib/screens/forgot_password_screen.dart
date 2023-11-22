import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  void sendResetPasswordEmail() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        !_emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please input a valid email address.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final eligibleUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();
      if (eligibleUsers.docs.isEmpty) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'No user with email address "${_emailController.text.trim()}" found.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully sent password reset email.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error sending reset password email: $error')));
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
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: all20Pix(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        loginHeaderWidgets(label: 'Forgot your password?'),
                        emailAddress(context, controller: _emailController),
                        Gap(120),
                        _submitButton(),
                      ],
                    ),
                  ),
                ),
              )),
        ));
  }

  Widget _submitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: sendResetPasswordEmail,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: comicNeueText(
            label: 'Send Password Reset Email',
            color: CustomColors.sweetCorn,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }
}
