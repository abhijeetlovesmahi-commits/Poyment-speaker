import 'package:flutter/material.dart';
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
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var perm = await Permission.notification.status;
    if (!perm.isGranted) {
      await Permission.notification.request();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Speaker')),
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
          ],
        ),
      ),
    );
  }
}
