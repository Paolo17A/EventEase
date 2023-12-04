import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddFAQScreen extends StatefulWidget {
  const AddFAQScreen({super.key});

  @override
  State<AddFAQScreen> createState() => _AddFAQScreenState();
}

class _AddFAQScreenState extends State<AddFAQScreen> {
  bool _isLoading = false;

  final questionController = TextEditingController();
  final answerController = TextEditingController();

  void submitFAQEntry() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (questionController.text.isEmpty || answerController.text.isEmpty) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Please fill up all fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String FAQID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('faqs').doc(FAQID).set({
        'question': questionController.text.trim(),
        'answer': answerController.text.trim()
      });
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Successfully added new FAQ.')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.viewFAQs);
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error adding FAQ: $error')));
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
        body: switchedLoadingContainer(
            _isLoading,
            SingleChildScrollView(
              child: Column(
                children: [
                  midnightBGHeaderText(context, label: 'New FAQ'),
                  _FAQFields(),
                  Gap(50),
                  _submitButton()
                ],
              ),
            )),
      ),
    );
  }

  Widget _FAQFields() {
    return SingleChildScrollView(
        child: all20Pix(
            child: Column(
      children: [
        multiLineField(context,
            label: 'Question', controller: questionController),
        multiLineField(context, label: 'Answer', controller: answerController)
      ],
    )));
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: submitFAQEntry,
        child: all20Pix(child: Text('SUBMIT', style: buttonSweetCornStyle())));
  }
}
