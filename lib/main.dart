import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/data/database_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tuni Train Setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      // الصفحة هذي هي اللي باش تقعد فيها
      home: const AdminUploadScreen(),
    );
  }
}

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  bool _isUploading = false;
  String _statusMessage = "Ready to upload data...";
  Color _messageColor = Colors.grey;

  void _runMigration() async {
    setState(() {
      _isUploading = true;
      _statusMessage = "Processing... Please wait.";
      _messageColor = Colors.blue;
    });

    try {
      final ds = DatabaseService();

      // 1. صب القطارات (501 -> 538)
      await ds.uploadSahelTrains();

      // 2. صب أوقات الساحل
      await ds.uploadTrainTimesSahel();

      setState(() {
        _statusMessage = "✅ Success! All Sahel data uploaded.";
        _messageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: ${e.toString()}";
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Admin Tool"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الزر في الوسط
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _runMigration,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("UPLOAD ALL DATA"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 20,
                        ),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 40),

              // الـ Message يطلع تحت الزر
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _messageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _messageColor),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _messageColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
