import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class EditFAQScreen extends StatefulWidget {
  final String FAQID;
  const EditFAQScreen({super.key, required this.FAQID});

  @override
  State<EditFAQScreen> createState() => _EditFAQScreenState();
}

class _EditFAQScreenState extends State<EditFAQScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  final questionController = TextEditingController();
  final answerController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getThisFAQEntry();
  }

  void getThisFAQEntry() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final faq = await getThisFAQ(widget.FAQID);
      questionController.text = faq['question'];
      answerController.text = faq['answer'];
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting this FAQ: $error')));
      navigator.pop();
    }
  }

  void editFAQEntry() async {
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
      await FirebaseFirestore.instance
          .collection('faqs')
          .doc(widget.FAQID)
          .update({
        'question': questionController.text.trim(),
        'answer': answerController.text.trim()
      });
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully edited this FAQ.')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.viewFAQs);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this FAQ: $error')));
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
        body: SafeArea(
            child: stackedLoadingContainer(
                context,
                _isLoading,
                SafeArea(
                    child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(
                    children: [
                      midnightBGHeaderText(context, label: 'New FAQ'),
                      _FAQFields(),
                      Gap(50),
                      _submitButton()
                    ],
                  )),
                )))),
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
        onPressed: editFAQEntry,
        child: all20Pix(child: Text('SUBMIT', style: buttonSweetCornStyle())));
  }
}
