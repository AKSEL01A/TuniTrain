import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuni_train/models/trains/station.dart';
import 'package:tuni_train/models/trains/train.dart';
import 'package:tuni_train/models/trains/train_line.dart';
import 'package:tuni_train/models/trains/traintime.dart';

// ─── 1. SERVICE COMPLET POUR RFR LIGNE E ─────────────────────────────────────
class RfrLineEImporter {
  static Future<void> importEverything() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Timestamp now = Timestamp.now();
    const String lineId = "RFR_E";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. صب الـ STATIONS والـ TRAINLINE
    // ─────────────────────────────────────────────────────────────────────────
    final List<Station> lineEStations = [
      Station(
        id: "tunis_ville",
        name: "TUNIS VILLE",
        city: "Tunis",
        latitude: 36.7948,
        longitude: 10.1803,
        lineIds: [lineId, "RFR_D"],
        zoneNumber: 1,
        stopOrder: 1,
        isActive: true,
        hasParking: false,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "sayda_manoubia",
        name: "SAYDA MANOUBIA",
        city: "Tunis",
        latitude: 36.7864,
        longitude: 10.1652,
        lineIds: [lineId, "RFR_D"],
        zoneNumber: 1,
        stopOrder: 2,
        isActive: true,
        hasParking: false,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "ennajah",
        name: "ENNAJAH",
        city: "Tunis",
        latitude: 36.7821,
        longitude: 10.1450,
        lineIds: [lineId],
        zoneNumber: 1,
        stopOrder: 3,
        isActive: true,
        hasParking: false,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "etayarane",
        name: "ETAYARANE",
        city: "Tunis",
        latitude: 36.7845,
        longitude: 10.1280,
        lineIds: [lineId],
        zoneNumber: 1,
        stopOrder: 4,
        isActive: true,
        hasParking: false,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "ezzouhour_2",
        name: "EZZOUHOUR 2",
        city: "Tunis",
        latitude: 36.7872,
        longitude: 10.1115,
        lineIds: [lineId],
        zoneNumber: 1,
        stopOrder: 5,
        isActive: true,
        hasParking: false,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "elhrayria",
        name: "ELHRAYRIA",
        city: "Tunis",
        latitude: 36.7860,
        longitude: 10.0920,
        lineIds: [lineId],
        zoneNumber: 2,
        stopOrder: 6,
        isActive: true,
        hasParking: true,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
      Station(
        id: "bougatfa",
        name: "BOUGATFA",
        city: "Tunis",
        latitude: 36.7841,
        longitude: 10.0760,
        lineIds: [lineId],
        zoneNumber: 2,
        stopOrder: 7,
        isActive: true,
        hasParking: true,
        hasTicketOffice: true,
        hasAccessibility: true,
        activeTrainsNow: 0,
        imageUrl: "",
        updatedAt: now,
      ),
    ];

    final List<String> stationNames = lineEStations.map((s) => s.name).toList();

    final TrainLine rfrLineE = TrainLine(
      id: lineId,
      name: "Ligne E RFR",
      code: "RFR E",
      color: "#9B51E0", // اللون البنفسجي المميز لخط E
      category: "RFR",
      startStation: stationNames.first,
      endStation: stationNames.last,
      stations: stationNames,
      totalStations: stationNames.length,
      totalDistanceKm: 9.0,
      isActive: true,
      firstDeparture: "04:40",
      lastDeparture: "22:35",
      averageWaitMinutes: 15,
      mapImageUrl: "",
      activeTrains: 0,
      updatedAt: now,
    );

    WriteBatch firstBatch = firestore.batch();
    firstBatch.set(
      firestore.collection('trainLines').doc(lineId),
      rfrLineE.toMap(),
    );
    for (var station in lineEStations) {
      firstBatch.set(
        firestore.collection('stations').doc(station.id),
        station.toMap(),
      );
    }
    await firstBatch.commit();

    // ─────────────────────────────────────────────────────────────────────────
    // 2. معالجة بيانات الـ TRAINS والـ TRAINTIMES
    // ─────────────────────────────────────────────────────────────────────────
    final List<Map<String, dynamic>> rawImpair = _getRawImpairData();
    final List<Map<String, dynamic>> rawPaire = _getRawPaireData();

    int operationsCount = 0;
    WriteBatch chunkBatch = firestore.batch();

    // دالة مساعدة لزرق المعطيات وتفادي الـ 500 operation limit في الـ batch
    Future<void> addToBatch(
      DocumentReference ref,
      Map<String, dynamic> data,
    ) async {
      chunkBatch.set(ref, data);
      operationsCount++;
      if (operationsCount >= 400) {
        await chunkBatch.commit();
        // الحل: نادِ الـ batch() مباشرة من المتغير firestore اللي عرفته الفوق
        chunkBatch = firestore.batch();
        operationsCount = 0;
      }
    }

    // صب القطارات الفردية وأوقاتها (Tunis -> Bougatfa)
    for (var item in rawImpair) {
      final int trainNum = item['num'];
      final String trainDocId = "train_e_$trainNum";
      final List<String> times = List<String>.from(item['times']);

      final Train train = Train(
        id: trainDocId,
        trainNumber: trainNum.toString(),
        lineId: "RFR E",
        startStation: "TUNIS VILLE",
        endStation: "BOUGATFA",
        totalStops: 7,
        isActive: false,
        isDelayed: false,
        delayMinutes: 0,
        currentStation: "TUNIS VILLE",
        currentStopOrder: 1,
        currentSpeed: 0.0,
        totalCapacity: 450,
        occupiedSeats: 0,
        firstDeparture: times.first,
        lastDeparture: times.last,
        updatedAt: now,
      );
      await addToBatch(
        firestore.collection('trains').doc(trainDocId),
        train.toMap(),
      );

      for (int i = 0; i < stationNames.length; i++) {
        final String sName = stationNames[i];
        final String sId = sName.toLowerCase().replaceAll(' ', '_');
        final String timeDocId = "time_e_${trainNum}_$sId";

        final TrainTime timeSlot = TrainTime(
          id: timeDocId,
          trainId: trainNum,
          lineId: "RFR E",
          stationName: sName,
          stationId: sId,
          stopOrder: i + 1,
          arrivalTime: times[i],
          departureTime: times[i],
          dayType: item['day'],
        );
        await addToBatch(
          firestore.collection('trainTimes').doc(timeDocId),
          timeSlot.toMap(),
        );
      }
    }

    // صب القطارات الزوجية وأوقاتها (Bougatfa -> Tunis)
    final List<String> paireStationNamesOrder = stationNames.reversed.toList();
    for (var item in rawPaire) {
      final int trainNum = item['num'];
      final String trainDocId = "train_e_$trainNum";
      final List<String> times = List<String>.from(item['times']);

      final Train train = Train(
        id: trainDocId,
        trainNumber: trainNum.toString(),
        lineId: "RFR E",
        startStation: "BOUGATFA",
        endStation: "TUNIS VILLE",
        totalStops: 7,
        isActive: false,
        isDelayed: false,
        delayMinutes: 0,
        currentStation: "BOUGATFA",
        currentStopOrder: 1,
        currentSpeed: 0.0,
        totalCapacity: 450,
        occupiedSeats: 0,
        firstDeparture: times.first,
        lastDeparture: times.last,
        updatedAt: now,
      );
      await addToBatch(
        firestore.collection('trains').doc(trainDocId),
        train.toMap(),
      );

      for (int i = 0; i < paireStationNamesOrder.length; i++) {
        final String sName = paireStationNamesOrder[i];
        final String sId = sName.toLowerCase().replaceAll(' ', '_');
        final String timeDocId = "time_e_${trainNum}_$sId";

        final TrainTime timeSlot = TrainTime(
          id: timeDocId,
          trainId: trainNum,
          lineId: "RFR E",
          stationName: sName,
          stationId: sId,
          stopOrder: i + 1,
          arrivalTime: times[i],
          departureTime: times[i],
          dayType: item['day'],
        );
        await addToBatch(
          firestore.collection('trainTimes').doc(timeDocId),
          timeSlot.toMap(),
        );
      }
    }

    // عمل commit لما تبقى في الـ batch الأخير
    if (operationsCount > 0) {
      await chunkBatch.commit();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. الداتا الخام للقطارات الفردية والزوجية
  // ─────────────────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> _getRawImpairData() {
    return [
      {
        "num": 401,
        "day": "weekday",
        "times": [
          "04:40",
          "04:44",
          "04:46",
          "04:49",
          "04:51",
          "04:53",
          "04:55",
        ],
      },
      {
        "num": 403,
        "day": "weekday",
        "times": [
          "05:00",
          "05:04",
          "05:06",
          "05:09",
          "05:11",
          "05:13",
          "05:15",
        ],
      },
      {
        "num": 405,
        "day": "all_except_sunday",
        "times": [
          "05:20",
          "05:24",
          "05:26",
          "05:29",
          "05:31",
          "05:33",
          "05:35",
        ],
      },
      {
        "num": 407,
        "day": "sunday_and_holidays",
        "times": [
          "05:25",
          "05:29",
          "05:31",
          "05:34",
          "05:36",
          "05:38",
          "05:40",
        ],
      },
      {
        "num": 409,
        "day": "all_except_sunday",
        "times": [
          "05:40",
          "05:44",
          "05:46",
          "05:49",
          "05:51",
          "05:53",
          "05:55",
        ],
      },
      {
        "num": 411,
        "day": "weekday",
        "times": [
          "06:00",
          "06:04",
          "06:06",
          "06:09",
          "06:11",
          "06:13",
          "06:15",
        ],
      },
      {
        "num": 413,
        "day": "all_except_sunday",
        "times": [
          "06:20",
          "06:24",
          "06:26",
          "06:29",
          "06:31",
          "06:33",
          "06:35",
        ],
      },
      {
        "num": 415,
        "day": "sunday_and_holidays",
        "times": [
          "06:30",
          "06:34",
          "06:36",
          "06:39",
          "06:41",
          "06:43",
          "06:45",
        ],
      },
      {
        "num": 417,
        "day": "all_except_sunday",
        "times": [
          "06:40",
          "06:44",
          "06:46",
          "06:49",
          "06:51",
          "06:53",
          "06:55",
        ],
      },
      {
        "num": 419,
        "day": "weekday",
        "times": [
          "07:00",
          "07:04",
          "07:06",
          "07:09",
          "07:11",
          "07:13",
          "07:15",
        ],
      },
      {
        "num": 421,
        "day": "all_except_sunday",
        "times": [
          "07:20",
          "07:24",
          "07:26",
          "07:29",
          "07:31",
          "07:33",
          "07:35",
        ],
      },
      {
        "num": 423,
        "day": "sunday_and_holidays",
        "times": [
          "07:25",
          "07:29",
          "07:31",
          "07:34",
          "07:36",
          "07:38",
          "07:40",
        ],
      },
      {
        "num": 425,
        "day": "all_except_sunday",
        "times": [
          "07:40",
          "07:44",
          "07:46",
          "07:49",
          "07:51",
          "07:53",
          "07:55",
        ],
      },
      {
        "num": 427,
        "day": "weekday",
        "times": [
          "08:00",
          "08:04",
          "08:06",
          "08:09",
          "08:11",
          "08:13",
          "08:15",
        ],
      },
      {
        "num": 429,
        "day": "all_except_sunday",
        "times": [
          "08:20",
          "08:24",
          "08:26",
          "08:29",
          "08:31",
          "08:33",
          "08:35",
        ],
      },
      {
        "num": 431,
        "day": "sunday_and_holidays",
        "times": [
          "08:30",
          "08:34",
          "08:36",
          "08:39",
          "08:41",
          "08:43",
          "08:45",
        ],
      },
      {
        "num": 433,
        "day": "all_except_sunday",
        "times": [
          "08:40",
          "08:44",
          "08:46",
          "08:49",
          "08:51",
          "08:53",
          "08:55",
        ],
      },
      {
        "num": 435,
        "day": "weekday",
        "times": [
          "09:00",
          "09:04",
          "09:06",
          "09:09",
          "09:11",
          "09:13",
          "09:15",
        ],
      },
      {
        "num": 437,
        "day": "all_except_sunday",
        "times": [
          "09:20",
          "09:24",
          "09:26",
          "09:29",
          "09:31",
          "09:33",
          "09:35",
        ],
      },
      {
        "num": 439,
        "day": "sunday_and_holidays",
        "times": [
          "09:25",
          "09:29",
          "09:31",
          "09:34",
          "09:36",
          "09:38",
          "09:40",
        ],
      },
      {
        "num": 441,
        "day": "all_except_sunday",
        "times": [
          "09:40",
          "09:44",
          "09:46",
          "09:49",
          "09:51",
          "09:53",
          "09:55",
        ],
      },
      {
        "num": 443,
        "day": "weekday",
        "times": [
          "10:00",
          "10:04",
          "10:06",
          "10:09",
          "10:11",
          "10:13",
          "10:15",
        ],
      },
      {
        "num": 445,
        "day": "all_except_sunday",
        "times": [
          "10:20",
          "10:24",
          "10:26",
          "10:29",
          "10:31",
          "10:33",
          "10:35",
        ],
      },
      {
        "num": 447,
        "day": "sunday_and_holidays",
        "times": [
          "10:30",
          "10:34",
          "10:36",
          "10:39",
          "10:41",
          "10:43",
          "10:45",
        ],
      },
      {
        "num": 449,
        "day": "all_except_sunday",
        "times": [
          "10:40",
          "10:44",
          "10:46",
          "10:49",
          "10:51",
          "10:53",
          "10:55",
        ],
      },
      {
        "num": 451,
        "day": "weekday",
        "times": [
          "11:00",
          "11:04",
          "11:06",
          "11:09",
          "11:11",
          "11:13",
          "11:15",
        ],
      },
      {
        "num": 453,
        "day": "all_except_sunday",
        "times": [
          "11:20",
          "11:24",
          "11:26",
          "11:29",
          "11:31",
          "11:33",
          "11:35",
        ],
      },
      {
        "num": 455,
        "day": "sunday_and_holidays",
        "times": [
          "11:25",
          "11:29",
          "11:31",
          "11:34",
          "11:36",
          "11:38",
          "11:40",
        ],
      },
      {
        "num": 457,
        "day": "all_except_sunday",
        "times": [
          "11:40",
          "11:44",
          "11:46",
          "11:49",
          "11:51",
          "11:53",
          "11:55",
        ],
      },
      {
        "num": 459,
        "day": "weekday",
        "times": [
          "12:00",
          "12:04",
          "12:06",
          "12:09",
          "12:11",
          "12:13",
          "12:15",
        ],
      },
      {
        "num": 461,
        "day": "all_except_sunday",
        "times": [
          "12:20",
          "12:24",
          "12:26",
          "12:29",
          "12:31",
          "12:33",
          "12:35",
        ],
      },
      {
        "num": 463,
        "day": "sunday_and_holidays",
        "times": [
          "12:30",
          "12:34",
          "12:36",
          "12:39",
          "12:41",
          "12:43",
          "12:45",
        ],
      },
      {
        "num": 465,
        "day": "all_except_sunday",
        "times": [
          "12:40",
          "12:44",
          "12:46",
          "12:49",
          "12:51",
          "12:53",
          "12:55",
        ],
      },
      {
        "num": 467,
        "day": "weekday",
        "times": [
          "13:00",
          "13:04",
          "13:06",
          "13:09",
          "13:11",
          "13:13",
          "13:15",
        ],
      },
      {
        "num": 469,
        "day": "all_except_sunday",
        "times": [
          "13:20",
          "13:24",
          "13:26",
          "13:29",
          "13:31",
          "13:33",
          "13:35",
        ],
      },
      {
        "num": 471,
        "day": "sunday_and_holidays",
        "times": [
          "13:25",
          "13:29",
          "13:31",
          "13:34",
          "13:36",
          "13:38",
          "13:40",
        ],
      },
      {
        "num": 473,
        "day": "all_except_sunday",
        "times": [
          "13:40",
          "13:44",
          "13:46",
          "13:49",
          "13:51",
          "13:53",
          "13:55",
        ],
      },
      {
        "num": 475,
        "day": "weekday",
        "times": [
          "14:00",
          "14:04",
          "14:06",
          "14:09",
          "14:11",
          "14:13",
          "14:15",
        ],
      },
      {
        "num": 477,
        "day": "all_except_sunday",
        "times": [
          "14:20",
          "14:24",
          "14:26",
          "14:29",
          "14:31",
          "14:33",
          "14:35",
        ],
      },
      {
        "num": 479,
        "day": "sunday_and_holidays",
        "times": [
          "14:30",
          "14:34",
          "14:36",
          "14:39",
          "14:41",
          "14:43",
          "14:45",
        ],
      },
      {
        "num": 481,
        "day": "all_except_sunday",
        "times": [
          "14:40",
          "14:44",
          "14:46",
          "14:49",
          "14:51",
          "14:53",
          "14:55",
        ],
      },
      {
        "num": 483,
        "day": "weekday",
        "times": [
          "15:00",
          "15:04",
          "15:06",
          "15:09",
          "15:11",
          "15:13",
          "15:15",
        ],
      },
      {
        "num": 485,
        "day": "all_except_sunday",
        "times": [
          "15:20",
          "15:24",
          "15:26",
          "15:29",
          "15:31",
          "15:33",
          "15:35",
        ],
      },
      {
        "num": 487,
        "day": "sunday_and_holidays",
        "times": [
          "15:25",
          "15:29",
          "15:31",
          "15:34",
          "15:36",
          "15:38",
          "15:40",
        ],
      },
      {
        "num": 489,
        "day": "all_except_sunday",
        "times": [
          "15:40",
          "15:44",
          "15:46",
          "15:49",
          "15:51",
          "15:53",
          "15:55",
        ],
      },
      {
        "num": 491,
        "day": "weekday",
        "times": [
          "16:00",
          "16:04",
          "16:06",
          "16:09",
          "16:11",
          "16:13",
          "16:15",
        ],
      },
      {
        "num": 493,
        "day": "all_except_sunday",
        "times": [
          "16:20",
          "16:24",
          "16:26",
          "16:29",
          "16:31",
          "16:33",
          "16:35",
        ],
      },
      {
        "num": 495,
        "day": "sunday_and_holidays",
        "times": [
          "16:30",
          "16:34",
          "16:36",
          "16:39",
          "16:41",
          "16:43",
          "16:45",
        ],
      },
      {
        "num": 497,
        "day": "all_except_sunday",
        "times": [
          "16:40",
          "16:44",
          "16:46",
          "16:49",
          "16:51",
          "16:53",
          "16:55",
        ],
      },
      {
        "num": 499,
        "day": "weekday",
        "times": [
          "17:00",
          "17:04",
          "17:06",
          "17:09",
          "17:11",
          "17:13",
          "17:15",
        ],
      },
      {
        "num": 501,
        "day": "all_except_sunday",
        "times": [
          "17:20",
          "17:24",
          "17:26",
          "17:29",
          "17:31",
          "17:33",
          "17:35",
        ],
      },
      {
        "num": 503,
        "day": "sunday_and_holidays",
        "times": [
          "17:25",
          "17:29",
          "17:31",
          "17:34",
          "17:36",
          "17:38",
          "17:40",
        ],
      },
      {
        "num": 505,
        "day": "all_except_sunday",
        "times": [
          "17:40",
          "17:44",
          "17:46",
          "17:49",
          "17:51",
          "17:53",
          "17:55",
        ],
      },
      {
        "num": 507,
        "day": "weekday",
        "times": [
          "18:00",
          "18:04",
          "18:06",
          "18:09",
          "18:11",
          "18:13",
          "18:15",
        ],
      },
      {
        "num": 509,
        "day": "weekday",
        "times": [
          "18:30",
          "18:34",
          "18:36",
          "18:39",
          "18:41",
          "18:43",
          "18:45",
        ],
      },
      {
        "num": 511,
        "day": "weekday",
        "times": [
          "19:00",
          "19:04",
          "19:06",
          "19:09",
          "19:11",
          "19:13",
          "19:15",
        ],
      },
      {
        "num": 513,
        "day": "weekday",
        "times": [
          "19:30",
          "19:34",
          "19:36",
          "19:39",
          "19:41",
          "19:43",
          "19:45",
        ],
      },
      {
        "num": 515,
        "day": "weekday",
        "times": [
          "20:00",
          "20:04",
          "20:06",
          "20:09",
          "20:11",
          "20:13",
          "20:15",
        ],
      },
      {
        "num": 517,
        "day": "weekday",
        "times": [
          "20:30",
          "20:34",
          "20:36",
          "20:39",
          "20:41",
          "20:43",
          "20:45",
        ],
      },
      {
        "num": 519,
        "day": "weekday",
        "times": [
          "21:00",
          "21:04",
          "21:06",
          "21:09",
          "21:11",
          "21:13",
          "21:15",
        ],
      },
      {
        "num": 521,
        "day": "weekday",
        "times": [
          "21:30",
          "21:34",
          "21:36",
          "21:39",
          "21:41",
          "21:43",
          "21:45",
        ],
      },
      {
        "num": 523,
        "day": "weekday",
        "times": [
          "22:00",
          "22:04",
          "22:06",
          "22:09",
          "22:11",
          "22:13",
          "22:15",
        ],
      },
    ];
  }

  static List<Map<String, dynamic>> _getRawPaireData() {
    return [
      {
        "num": 402,
        "day": "weekday",
        "times": [
          "05:00",
          "05:02",
          "05:04",
          "05:07",
          "05:09",
          "05:11",
          "05:15",
        ],
      },
      {
        "num": 404,
        "day": "weekday",
        "times": [
          "05:20",
          "05:22",
          "05:24",
          "05:27",
          "05:29",
          "05:31",
          "05:35",
        ],
      },
      {
        "num": 406,
        "day": "all_except_sunday",
        "times": [
          "05:40",
          "05:42",
          "05:44",
          "05:47",
          "05:49",
          "05:51",
          "05:55",
        ],
      },
      {
        "num": 408,
        "day": "sunday_and_holidays",
        "times": [
          "05:50",
          "05:52",
          "05:54",
          "05:57",
          "05:59",
          "06:01",
          "06:05",
        ],
      },
      {
        "num": 410,
        "day": "all_except_sunday",
        "times": [
          "06:00",
          "06:02",
          "06:04",
          "06:07",
          "06:09",
          "06:11",
          "06:15",
        ],
      },
      {
        "num": 412,
        "day": "weekday",
        "times": [
          "06:20",
          "06:22",
          "06:24",
          "06:27",
          "06:29",
          "06:31",
          "06:35",
        ],
      },
      {
        "num": 414,
        "day": "all_except_sunday",
        "times": [
          "06:40",
          "06:42",
          "06:44",
          "06:47",
          "06:49",
          "06:51",
          "06:55",
        ],
      },
      {
        "num": 416,
        "day": "sunday_and_holidays",
        "times": [
          "06:50",
          "06:52",
          "06:54",
          "06:57",
          "06:59",
          "07:01",
          "07:05",
        ],
      },
      {
        "num": 418,
        "day": "all_except_sunday",
        "times": [
          "07:00",
          "07:02",
          "07:04",
          "07:07",
          "07:09",
          "07:11",
          "07:15",
        ],
      },
      {
        "num": 420,
        "day": "weekday",
        "times": [
          "07:20",
          "07:22",
          "07:24",
          "07:27",
          "07:29",
          "07:31",
          "07:35",
        ],
      },
      {
        "num": 422,
        "day": "all_except_sunday",
        "times": [
          "07:40",
          "07:42",
          "07:44",
          "07:47",
          "07:49",
          "07:51",
          "07:55",
        ],
      },
      {
        "num": 424,
        "day": "sunday_and_holidays",
        "times": [
          "07:50",
          "07:52",
          "07:54",
          "07:57",
          "07:59",
          "08:01",
          "08:05",
        ],
      },
      {
        "num": 426,
        "day": "all_except_sunday",
        "times": [
          "08:00",
          "08:02",
          "08:04",
          "08:07",
          "08:09",
          "08:11",
          "08:15",
        ],
      },
      {
        "num": 428,
        "day": "weekday",
        "times": [
          "08:20",
          "08:22",
          "08:24",
          "08:27",
          "08:29",
          "08:31",
          "08:35",
        ],
      },
      {
        "num": 430,
        "day": "all_except_sunday",
        "times": [
          "08:40",
          "08:42",
          "08:44",
          "08:47",
          "08:49",
          "08:51",
          "08:55",
        ],
      },
      {
        "num": 432,
        "day": "sunday_and_holidays",
        "times": [
          "08:50",
          "08:52",
          "08:54",
          "08:57",
          "08:59",
          "09:01",
          "09:05",
        ],
      },
      {
        "num": 434,
        "day": "all_except_sunday",
        "times": [
          "09:00",
          "09:02",
          "09:04",
          "09:07",
          "09:09",
          "09:11",
          "09:15",
        ],
      },
      {
        "num": 436,
        "day": "weekday",
        "times": [
          "09:20",
          "09:22",
          "09:24",
          "09:27",
          "09:29",
          "09:31",
          "09:35",
        ],
      },
      {
        "num": 438,
        "day": "all_except_sunday",
        "times": [
          "09:40",
          "09:42",
          "09:44",
          "09:47",
          "09:49",
          "09:51",
          "09:55",
        ],
      },
      {
        "num": 440,
        "day": "sunday_and_holidays",
        "times": [
          "09:50",
          "09:52",
          "09:54",
          "09:57",
          "09:59",
          "10:01",
          "10:05",
        ],
      },
      {
        "num": 442,
        "day": "all_except_sunday",
        "times": [
          "10:00",
          "10:02",
          "10:04",
          "10:07",
          "10:09",
          "10:11",
          "10:15",
        ],
      },
      {
        "num": 444,
        "day": "weekday",
        "times": [
          "10:20",
          "10:22",
          "10:24",
          "10:27",
          "10:29",
          "10:31",
          "10:35",
        ],
      },
      {
        "num": 446,
        "day": "all_except_sunday",
        "times": [
          "10:40",
          "10:42",
          "10:44",
          "10:47",
          "10:49",
          "10:51",
          "10:55",
        ],
      },
      {
        "num": 448,
        "day": "sunday_and_holidays",
        "times": [
          "10:50",
          "10:52",
          "10:54",
          "10:57",
          "10:59",
          "11:01",
          "11:05",
        ],
      },
      {
        "num": 450,
        "day": "all_except_sunday",
        "times": [
          "11:00",
          "11:02",
          "11:04",
          "11:07",
          "11:09",
          "11:11",
          "11:15",
        ],
      },
      {
        "num": 452,
        "day": "weekday",
        "times": [
          "11:20",
          "11:22",
          "11:24",
          "11:27",
          "11:29",
          "11:31",
          "11:35",
        ],
      },
      {
        "num": 454,
        "day": "all_except_sunday",
        "times": [
          "11:40",
          "11:42",
          "11:44",
          "11:47",
          "11:49",
          "11:51",
          "11:55",
        ],
      },
      {
        "num": 456,
        "day": "sunday_and_holidays",
        "times": [
          "11:50",
          "11:52",
          "11:54",
          "11:57",
          "11:59",
          "12:01",
          "12:05",
        ],
      },
      {
        "num": 458,
        "day": "all_except_sunday",
        "times": [
          "12:00",
          "12:02",
          "12:04",
          "12:07",
          "12:09",
          "12:11",
          "12:15",
        ],
      },
      {
        "num": 460,
        "day": "weekday",
        "times": [
          "12:20",
          "12:22",
          "12:24",
          "12:27",
          "12:29",
          "12:31",
          "12:35",
        ],
      },
      {
        "num": 462,
        "day": "all_except_sunday",
        "times": [
          "12:40",
          "12:42",
          "12:44",
          "12:47",
          "12:49",
          "12:51",
          "12:55",
        ],
      },
      {
        "num": 464,
        "day": "sunday_and_holidays",
        "times": [
          "12:50",
          "12:52",
          "12:54",
          "12:57",
          "12:59",
          "13:01",
          "13:05",
        ],
      },
      {
        "num": 466,
        "day": "all_except_sunday",
        "times": [
          "13:00",
          "13:02",
          "13:04",
          "13:07",
          "13:09",
          "13:11",
          "13:15",
        ],
      },
      {
        "num": 468,
        "day": "weekday",
        "times": [
          "13:20",
          "13:22",
          "13:24",
          "13:27",
          "13:29",
          "13:31",
          "13:35",
        ],
      },
      {
        "num": 470,
        "day": "all_except_sunday",
        "times": [
          "13:40",
          "13:42",
          "13:44",
          "13:47",
          "13:49",
          "13:51",
          "13:55",
        ],
      },
      {
        "num": 472,
        "day": "sunday_and_holidays",
        "times": [
          "13:50",
          "13:52",
          "13:54",
          "13:57",
          "13:59",
          "14:01",
          "14:05",
        ],
      },
      {
        "num": 474,
        "day": "all_except_sunday",
        "times": [
          "14:00",
          "14:02",
          "14:04",
          "14:07",
          "14:09",
          "14:11",
          "14:15",
        ],
      },
      {
        "num": 476,
        "day": "weekday",
        "times": [
          "14:20",
          "14:22",
          "14:24",
          "14:27",
          "14:29",
          "14:31",
          "14:35",
        ],
      },
      {
        "num": 478,
        "day": "all_except_sunday",
        "times": [
          "14:40",
          "14:42",
          "14:44",
          "14:47",
          "14:49",
          "14:51",
          "14:55",
        ],
      },
      {
        "num": 480,
        "day": "sunday_and_holidays",
        "times": [
          "14:50",
          "14:52",
          "14:54",
          "14:57",
          "14:59",
          "15:01",
          "15:05",
        ],
      },
      {
        "num": 482,
        "day": "all_except_sunday",
        "times": [
          "15:00",
          "15:02",
          "15:04",
          "15:07",
          "15:09",
          "15:11",
          "15:15",
        ],
      },
      {
        "num": 484,
        "day": "weekday",
        "times": [
          "15:20",
          "15:22",
          "15:24",
          "15:27",
          "15:29",
          "15:31",
          "15:35",
        ],
      },
      {
        "num": 486,
        "day": "all_except_sunday",
        "times": [
          "15:40",
          "15:42",
          "15:44",
          "15:47",
          "15:49",
          "15:51",
          "15:55",
        ],
      },
      {
        "num": 488,
        "day": "sunday_and_holidays",
        "times": [
          "15:50",
          "15:52",
          "15:54",
          "15:57",
          "15:59",
          "16:01",
          "16:05",
        ],
      },
      {
        "num": 490,
        "day": "all_except_sunday",
        "times": [
          "16:00",
          "16:02",
          "16:04",
          "16:07",
          "16:09",
          "16:11",
          "16:15",
        ],
      },
      {
        "num": 492,
        "day": "weekday",
        "times": [
          "16:20",
          "16:22",
          "16:24",
          "16:27",
          "16:29",
          "16:31",
          "16:35",
        ],
      },
      {
        "num": 494,
        "day": "all_except_sunday",
        "times": [
          "16:40",
          "16:42",
          "16:44",
          "16:47",
          "16:49",
          "16:51",
          "16:55",
        ],
      },
      {
        "num": 496,
        "day": "sunday_and_holidays",
        "times": [
          "16:50",
          "16:52",
          "16:54",
          "16:57",
          "16:59",
          "17:01",
          "17:05",
        ],
      },
      {
        "num": 498,
        "day": "all_except_sunday",
        "times": [
          "17:00",
          "17:02",
          "17:04",
          "17:07",
          "17:09",
          "17:11",
          "17:15",
        ],
      },
      {
        "num": 500,
        "day": "weekday",
        "times": [
          "17:20",
          "17:22",
          "17:24",
          "17:27",
          "17:29",
          "17:31",
          "17:35",
        ],
      },
      {
        "num": 502,
        "day": "all_except_sunday",
        "times": [
          "17:40",
          "17:42",
          "17:44",
          "17:47",
          "17:49",
          "17:51",
          "17:55",
        ],
      },
      {
        "num": 504,
        "day": "sunday_and_holidays",
        "times": [
          "17:50",
          "17:52",
          "17:54",
          "17:57",
          "17:59",
          "18:01",
          "18:05",
        ],
      },
      {
        "num": 506,
        "day": "all_except_sunday",
        "times": [
          "18:00",
          "18:02",
          "18:04",
          "18:07",
          "18:09",
          "18:11",
          "18:15",
        ],
      },
      {
        "num": 508,
        "day": "weekday",
        "times": [
          "18:20",
          "18:22",
          "18:24",
          "18:27",
          "18:29",
          "18:31",
          "18:35",
        ],
      },
      {
        "num": 510,
        "day": "weekday",
        "times": [
          "18:50",
          "18:52",
          "18:54",
          "18:57",
          "18:59",
          "19:01",
          "19:05",
        ],
      },
      {
        "num": 512,
        "day": "weekday",
        "times": [
          "19:20",
          "19:22",
          "19:24",
          "19:27",
          "19:29",
          "19:31",
          "19:35",
        ],
      },
      {
        "num": 514,
        "day": "weekday",
        "times": [
          "19:50",
          "19:52",
          "19:54",
          "19:57",
          "19:59",
          "20:01",
          "20:05",
        ],
      },
      {
        "num": 516,
        "day": "weekday",
        "times": [
          "20:20",
          "20:22",
          "20:24",
          "20:27",
          "20:29",
          "20:31",
          "20:35",
        ],
      },
      {
        "num": 518,
        "day": "weekday",
        "times": [
          "20:50",
          "20:52",
          "20:54",
          "20:57",
          "20:59",
          "21:01",
          "21:05",
        ],
      },
      {
        "num": 520,
        "day": "weekday",
        "times": [
          "21:20",
          "21:22",
          "21:24",
          "21:27",
          "21:29",
          "21:31",
          "21:35",
        ],
      },
      {
        "num": 522,
        "day": "weekday",
        "times": [
          "21:50",
          "21:52",
          "21:54",
          "21:57",
          "21:59",
          "22:01",
          "22:05",
        ],
      },
      {
        "num": 524,
        "day": "weekday",
        "times": [
          "22:20",
          "22:22",
          "22:24",
          "22:27",
          "22:29",
          "22:31",
          "22:35",
        ],
      },
    ];
  }
}

// ─── 2. WIDGET CARD POUR PAGE ACCUEIL ────────────────────────────────────────
class RfrLineEImportCard extends StatefulWidget {
  const RfrLineEImportCard({super.key});

  @override
  State<RfrLineEImportCard> createState() => _RfrLineEImportCardState();
}

class _RfrLineEImportCardState extends State<RfrLineEImportCard> {
  bool _isLoading = false;

  void _runImport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await RfrLineEImporter.importEverything();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم صب خط RFR E بالكامل (المحطات، 118 قطار و826 توقيت) بنجاح! 🚀💜',
            ),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الصب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "RFR Ligne E (Tunis - Bougatfa)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Générer la ligne, les 7 stations, 118 trains et la grille complète de 826 temps de passages.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF9B51E0,
                  ), // اللون البنفسجي لخط E
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _runImport,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Importer Réseau RFR Ligne E",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  /*// ── Station data ──────────────────────────────────────────────
  static const List<String> grandesLignes = [
    'AIN MESRIA',
    'AIN GHELAL',
    'AIN RAHMA',
    'AOUINET',
    'BIR BOUREGBA',
    'BIR MCHERGUA',
    'BOUGOUBRINE',
    'BEJA',
    'BELLI',
    'BEN BECHIR',
    'BIR KASSAA',
    'BIZERTE',
    'BORJ ETTOUM',
    'BOUARADA',
    'BOUARKOUB',
    'BOUFICHA',
    'SIDI BOUROUIS',
    'BOU SALEM',
    'CHAAL',
    'CHAOUAT',
    'CHEYLUS',
    'DAHMANI',
    'DEPIENNE',
    'DOKHANE',
    'EL AGUILA',
    'EL AKHOUAT',
    'EL AROUSSA',
    'EL FEJIJ',
    'EL GUETAR',
    'EL HAMADA',
    'EL HERI',
    'EL JEM',
    'EL OUDIANE',
    'ENFIDHA',
    'FEJ TAMEUR',
    'FONDOUK JEDID',
    'FOUNI',
    'FRIGUIA PARK',
    'GABES',
    'GAAFOUR',
    'GAFSA',
    'GARGOUR',
    'GHANNOUCH',
    'GHARDIMAOU',
    'GOURAIA',
    'GHRAIBA',
    'GROMBALIA',
    'HAMMAM LIF',
    'HAMMAMET',
    'JEBEL JELLOUD',
    'JENDOUBA',
    'JEDEIDA',
    'JERISSA',
    'KALAA KEBIRA',
    'KALAA KHASBA',
    'KALAA SGHIRA',
    'KERKER',
    'KHANGUET',
    'LA HENCHA',
    'LA PECHERIE',
    'LE KEF',
    'LE KRIB',
    'LE KRIZ',
    'LE SERS',
    'LES SALINES',
    'MANZEL BOUZAIAN',
    'MAHDIA',
    'MAHRES',
    'MAKNASSY',
    'MANOUBA',
    'MASTOUTA',
    'MATEUR',
    'MDHILLA',
    'MEJEZ ELBAB',
    'METLAOUI',
    'MEZZOUNA',
    'MONASTIR',
    'MOULARES',
    'MSAKEN',
    'NABEUL',
    'NAASSEN',
    'OMAR KHAYEM',
    'OUDHNA',
    'OUED MELIZ',
    'OUED SARRAT',
    'OUED ZARGA',
    'PONT DU FAHS',
    'REDEYEF',
    'SAKIET EZZIT',
    'SEGUI',
    'SELJA',
    'SENED',
    'SFAX',
    'SIDI ABID',
    'SIDI AYED',
    'SIDI BOU ALI',
    'SIDI MHIMECH',
    'SIDI MTIR',
    'SIDI OTHMAN',
    'SIDI SALAH',
    'SIDI SMAIL',
    'SKHIRA',
    'SOUSSE',
    'TABEDITT',
    'TAJEROUINE',
    'TEBOURBA',
    'TINJA',
    'TOZEUR',
    'TRIKA',
    'TUNIS',
    'TURKI',
    'ZANNOUCH',
    'LES ZOUARINES',
  ];

  static const List<String> banlieueTunis = [
    'TUNIS',
    'JEBEL JELLOUD',
    'MEGRINE RIADH',
    'MEGRINE',
    'SIDI REZIG',
    'LYCEE RADES',
    'RADES',
    'RADES MELIANE',
    'EZZAHRA',
    'LYCEE EZZAHRA',
    'BOUKORNINE',
    'HAMMAM LIF',
    'ARRET DU STADE',
    'TAHAR SFAR',
    'HAMMAM CHATT',
    'BIR EL BEY',
    'BORJ CEDRIA',
    'ERRIADH',
  ];

  static const List<String> banlieueSahel = [
    'SOUSSE BAB JEDID',
    'SOUSSE MED V',
    'SOUSSE SUD',
    'SOUSSE ZONE INDUSTRIELLE',
    'SAHLINE',
    'SAHLINE SEBKHA',
    'LES HOTELS',
    "L'AEROPORT",
    'LA FACULTE',
    'MONASTIR',
    'LA FACULTE 2',
    'MONASTIR ZONE INDUSTRIELLE',
    'FRINA',
    'KHENISS BEMBLA',
    'KSIBET MEDIOUNI BENANE',
    'BOUHJAR',
    'LAMTA',
    'SAYADA',
    'KSAR HELLAL ZONE INDUSTRIELLE',
    'KSAR HELLAL',
    'MOKNINE GRIBAA',
    'MOKNINE',
    'MOKNINE ZONE INDUSTRIELLE',
    'TEBOULBA ZONE INDUSTRIELLE',
    'TEBOULBA',
    'BEKALTA',
    'BAGHDADI',
    'MAHDIA ZONE TOURISTIQUE',
    'SIDI MESSOUD',
    'BORJ EL ARIF',
    'EZZAHRA',
    'MAHDIA',
  ];

  static const List<String> rfr = [
    '[E] TUNIS-BARCELONE',
    '[E] SAIDA MANOUBIA',
    '[E] ENNAJAH',
    '[E] ETTAYARAN - EZZOUHOUR 1',
    '[E] EZZOUHOUR 2',
    '[E] EL HRAIRIA',
    '[E] BOUGATFA - SIDI HASSINE',
    '[D] TUNIS-BARCELONE',
    '[D] MELLASSINE',
    '[D] ERRAOUDHA',
    '[D] LE BARDO',
    '[D] BORTAL',
    '[D] MANOUBA',
    '[D] EL-BORTOKAL',
    '[D] GOBAA',
    '[A] TUNIS-BARCELONE',
    '[A] SIDI FATHALLAH',
    '[A] JEBEL JELLOUD',
    '[A] MEGRINE',
    '[A] BEN AROUS',
    '[A] RADES',
    '[A] EZZAHRA',
    '[A] HAMMAM LIF',
    '[A] BORJ CEDRIA',
  ];

  static const List<String> international = [
    'TUNIS-VILLE (BARCELONE)',
    'BEJA',
    'JENDOUBA',
    'GHARDIMAOU (FRONTIERE TN)',
    'SOUK AHRAS (FRONTIERE DZ)',
    'ANNABA',
    'CONSTANTINE',
    'SETIF',
    'BORDJ BOU ARRERIDJ',
    "ALGER (GARE D'AGHA)",
  ];
}
*/



