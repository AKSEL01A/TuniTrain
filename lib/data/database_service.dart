import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> uploadTrainTimes() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final WriteBatch batch = firestore.batch();
  final CollectionReference collection = firestore.collection('traintime');

  // El data elli aatithali
  final List<Map<String, dynamic>> trainData = [
    // ==========================================
    // الـ TRAINS PAIRES (من قُبّاعة المدينة إلى تونس)
    // ==========================================
    {
      "trainId": 602,
      "lineId": "RFR D",
      "stationName": "GOBAA VILLE",
      "stopOrder": 1,
      "arrivalTime": "04:45",
      "departureTime": "04:45",
      "dayType": "weekday",
    },
  ];
  try {
    for (var data in trainData) {
      // Na3mlou Document ID unique (TrainID + StopOrder) bech ma yet3awedch
      String docId = "${data['trainId']}_${data['stopOrder']}";
      DocumentReference docRef = collection.doc(docId);
      batch.set(docRef, data);
    }

    await batch.commit();
    debugPrint("Mriguel! El data tsobbet lkol.");
  } catch (e) {
    debugPrint("Famma mochkla: $e");
  }
}
