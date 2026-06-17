import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuni_train/models/admin.dart';

class AddTestAdminCard extends StatefulWidget {
  const AddTestAdminCard({super.key});

  @override
  State<AddTestAdminCard> createState() => _AddTestAdminCardState();
}

class _AddTestAdminCardState extends State<AddTestAdminCard> {
  bool _isCreating = false;

  Future<void> _saveAdminToFirestore() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      String adminUid = "MH2TI09ND2RKRbybQSli3Emaajh1";
      String testEmail = "admin@tunitrain.tn";

      Admin newAdmin = Admin(
        id: adminUid,
        firstName: "Mohamed Salah",
        lastName: "Ben Hnia",
        email: testEmail,
        phone: "53125475",
        createdAt: DateTime.now(),
        isActive: true,
        role: "admin",
        permissions: const [
          // ── Train Lines & Stations ──
          "add_line", "update_line", "delete_line",
          "add_station", "update_station", "delete_station",

          // ── Trains & Schedules (Times) ──
          "add_train", "update_train", "delete_train",
          "add_train_time", "update_train_time", "delete_train_time",

          // ── System Management ──
          "import_data", "manage_services", "manage_locations",
          "manage_controllers", "manage_users",

          // 🌟 صلاحية مطلقة احتياطية إذا كنت تستعمل فيها في الكود
          "all_access", "*",
        ],
      );
      await db
          .collection('administrateurs')
          .doc(adminUid)
          .set(newAdmin.toMap());

      if (mounted) {
        Get.snackbar(
          "Succès 🚀",
          "",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
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
              "Enregistrer l'Admin dans Firestore",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isCreating ? null : _saveAdminToFirestore,
                child: _isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Lier l'Admin au Firestore",
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



