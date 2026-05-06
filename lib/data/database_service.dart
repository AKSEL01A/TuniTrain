import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // 1. 👈 لازم تكون هنا باش الـ Functions الكل يشوفوها
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- صب القطارات (Trains) ---
  Future<void> uploadSahelTrains() async {
    // الأرقام اللي طلعناهم من image_5d076c.png و image_5d0713.png
    List<int> trainIds = [
      // التصويرة الأولى (الأرقام الفردية)
      501,
      503,
      505,
      507,
      509,
      511,
      513,
      515,
      517,
      519,
      521,
      523,
      525,
      527,
      529,
      531,
      533,
      535,
      // التصويرة الثانية (الأرقام الزوجية)
      504,
      506,
      508,
      510,
      512,
      514,
      516,
      518,
      520,
      522,
      524,
      526,
      528,
      530,
      532,
      534,
      536,
      538,
    ];

    try {
      WriteBatch batch = _db.batch();

      for (int id in trainIds) {
        DocumentReference trainRef = _db
            .collection('trains')
            .doc(id.toString());

        // فردي يمشي للمهدية، زوجي يخرج منها (افتراضياً)
        String startPos = (id % 2 != 0) ? "SOUSSE BAB JEDID" : "MAHDIA";

        batch.set(trainRef, {
          'id': id,
          'lineId': 'banlieue_sahel',
          'currentPosition': startPos,
          'capacity': 300,
          'trainStatus': true,
          'currentSpeed': 0.0,
        });
      }

      await batch.commit();
      print("✅ Trains (501-538) uploaded!");
    } catch (e) {
      print("❌ Error uploading trains: $e");
    }
  }

  // --- صب الأوقات (Train Times) ---
  Future<void> uploadTrainTimesSahel() async {
    Map<String, Map<String, String>> sahelTimes = {
      '510': {
        'MAHDIA': '06:40',
        'EZZAHRA': '06:45',
        'BORJ EL ARIF': '06:48',
        'SIDI MESSOUD': '06:51',
        'MAHDIA ZONE TOURISTIQUE': '06:55',
        'BAGHDADI': '07:01',
        'BEKALTA': '07:10',
        'TEBOULBA': '07:14',
        'MOKNINE': '07:26',
        'MONASTIR': '08:08',
        'SOUSSE BAB JEDID': '08:40',
      },
      '528': {
        'MAHDIA ZONE TOURISTIQUE': '15:30',
        'BAGHDADI': '15:36',
        'BEKALTA': '15:42',
        'MOKNINE': '15:56',
        'MONASTIR': '16:40',
        'SOUSSE BAB JEDID': '17:12',
      },
      // زيد الرحلات الأخرى هنا...
    };

    try {
      WriteBatch batch = _db.batch();
      sahelTimes.forEach((trainNumber, schedule) {
        schedule.forEach((stationName, time) {
          String timeDocId =
              "${trainNumber}_${stationName.replaceAll(' ', '_')}";
          DocumentReference timeRef = _db
              .collection('trainTimes')
              .doc(timeDocId);

          batch.set(timeRef, {
            'trainId': trainNumber,
            'lineId': 'banlieue_sahel',
            'stationName': stationName,
            'arrivalTime': time,
            'departureTime': time,
            'dayType': 'Daily',
          });
        });
      });
      await batch.commit();
      print("✅ Train Times uploaded!");
    } catch (e) {
      print("❌ Error uploading times: $e");
    }
  }
}
