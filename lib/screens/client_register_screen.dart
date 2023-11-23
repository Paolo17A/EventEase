import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void registerNewUser() async {
    FocusScope.of(context).unfocus();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: (Text('Please fill up all fields'))));
      return;
    }
    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: (Text('Please enter a valid email address'))));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: (Text('The passwords do not match.'))));
      return;
    }
    if (_passwordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              (Text('The password must be at least six characters long.'))));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userType': 'CLIENT',
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'profileImageURL': '',
        'currentEventID': '',
        'availedSuppliers': {},
        'transactionHistory': [],
        'feedbackHistory': [],
        'membershipPayment': '',
      });
      await FirebaseAuth.instance.signOut();
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Successfully created new client account.')));
      navigator.pushReplacementNamed(NavigatorRoutes.clientLogin);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new user: $error')));
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
                  child: SafeArea(
                child: all20Pix(
                    child: Column(
                  children: [
                    loginHeaderWidgets(label: 'Create your client account'),
                    emailAddress(context, controller: _emailController),
                    password(context, controller: _passwordController),
                    confirmPassword(context,
                        controller: _confirmPasswordController),
                    const Gap(60),
                    labelledTextField(context,
                        label: 'First\nName: ',
                        controller: _firstNameController),
                    labelledTextField(context,
                        label: 'Last\nName: ', controller: _lastNameController),
                    submitButton(context,
                        label: 'CREATE YOUR ACCOUNT',
                        onPress: () => registerNewUser()),
                  ],
                )),
              )))),
    );
  }
}
