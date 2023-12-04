import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<dynamic, dynamic>> getCurrentUserData() async {
  return await getThisUserData(FirebaseAuth.instance.currentUser!.uid);
}

Future<Map<dynamic, dynamic>> getThisUserData(String userID) async {
  final user =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  return user.data() as Map<dynamic, dynamic>;
}

Future<Map<dynamic, dynamic>> getThisTransaction(String transactionID) async {
  final transaction = await FirebaseFirestore.instance
      .collection('transactions')
      .doc(transactionID)
      .get();
  return transaction.data() as Map<dynamic, dynamic>;
}

Future<Map<dynamic, dynamic>> getThisFAQ(String faqID) async {
  final transaction =
      await FirebaseFirestore.instance.collection('faqs').doc(faqID).get();
  return transaction.data() as Map<dynamic, dynamic>;
}

Future<Map<dynamic, dynamic>> getThisEvent(String eventID) async {
  final transaction =
      await FirebaseFirestore.instance.collection('events').doc(eventID).get();
  return transaction.data() as Map<dynamic, dynamic>;
}
