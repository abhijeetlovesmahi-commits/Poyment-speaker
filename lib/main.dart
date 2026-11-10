import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Speaker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  String _lastNotification = "Koi payment notification nahi aayi hai.";

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkPermissions();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _checkPermissions() async {
    bool status = await NotificationListenerService.isPermissionGranted();
    if (!status) {
      await NotificationListenerService.requestPermission();
    }
    var perm = await Permission.notification.status;
    if (!perm.isGranted) {
      await Permission.notification.request();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    NotificationListenerService.notificationsStream.listen((event) {
      if (event.packageName != null && 
         (event.packageName!.contains("paytm") || 
          event.packageName!.contains("phonepe") || 
          event.packageName!.contains("google.android.apps.nbu.p2.user"))) {
        
        String? content = event.content;
        if (content != null && (content.toLowerCase().contains("received") || content.toLowerCase().contains("prapt") || content.toLowerCase().contains("rs") || content.toLowerCase().contains("₹"))) {
          setState(() {
            _lastNotification = "Payment Received: $content";
          });
          _speakPayment(content);
        }
      }
    });
  }

  Future<void> _speakPayment(String text) async {
    String speechText = "Aapko payment prapt hui. $text";
    await flutterTts.speak(speechText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Payment Speaker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.volume_up : Icons.volume_off,
              size: 80,
              color: _isListening ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isListening ? "Speaker Service Active Hai..." : "Speaker Service Band Hai",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isListening ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startListening,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: const Text("Start Speaker Service", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 40),
            const Text("Last Detected Notification:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Text(_lastNotification, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
