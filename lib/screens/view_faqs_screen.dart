import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class ViewFAQsScreen extends StatefulWidget {
  const ViewFAQsScreen({super.key});

  @override
  State<ViewFAQsScreen> createState() => _ViewFAQsScreenState();
}

class _ViewFAQsScreenState extends State<ViewFAQsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> allFAQs = [];
  bool isAdmin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllFAQs();
  }

  void getAllFAQs() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData =
          await getThisUserData(FirebaseAuth.instance.currentUser!.uid);
      isAdmin = userData['userType'] == 'ADMIN';
      final faqs = await FirebaseFirestore.instance.collection('faqs').get();
      allFAQs = faqs.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all FAQs: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteThisFAQ(String FAQID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance.collection('faqs').doc(FAQID).delete();
      getAllFAQs();
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error deleting FAQs: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: comicNeueText(
            label: 'FAQs',
            color: CustomColors.sweetCorn,
            fontWeight: FontWeight.bold),
        actions: [
          if (isAdmin)
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(NavigatorRoutes.addFAQ),
                icon: Icon(Icons.add))
        ],
      ),
      body: switchedLoadingContainer(
          _isLoading,
          SafeArea(
              child: SingleChildScrollView(
                  child: allFAQs.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: allFAQs.length,
                          itemBuilder: (context, index) {
                            final FAQData =
                                allFAQs[index].data() as Map<dynamic, dynamic>;
                            String question = FAQData['question'];
                            String answer = FAQData['answer'];
                            return vertical10Pix(
                                child: FAQEntry(context,
                                    FAQID: allFAQs[index].id,
                                    question: question,
                                    answer: answer,
                                    isAdmin: isAdmin,
                                    onDelete: () =>
                                        deleteThisFAQ(allFAQs[index].id)));
                          })
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: comicNeueText(
                                label: 'NO FAQS CREATED',
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center),
                          ),
                        )))),
    );
  }
}
