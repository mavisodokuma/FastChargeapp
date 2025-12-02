import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const FastChargeCompanion());
}

class FastChargeCompanion extends StatelessWidget {
  const FastChargeCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastCharge Companion',
      theme: ThemeData.dark(),
      home: const BatterySyncPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BatterySyncPage extends StatefulWidget {
  const BatterySyncPage({super.key});

  @override
  State<BatterySyncPage> createState() => _BatterySyncPageState();
}

class _BatterySyncPageState extends State<BatterySyncPage> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  String _status = "Waiting...";

  // ✅ YOUR REAL DATA
  final String token = "93bdc79ffb0a1861";
  final int deviceId = 2;

  // ✅ your server
  final String serverUrl = "https://felica-sombrous-tawanna.ngrok-free.dev/api/update_device_battery";

  @override
  void initState() {
    super.initState();
    startBatterySync();
  }

  void startBatterySync() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await sendBattery();
    });
  }

  Future<void> sendBattery() async {
    try {
      final level = await _battery.batteryLevel;

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "token": token,
          "device_id": deviceId,
          "battery": level
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _batteryLevel = level;
          _status = "✅ Synced successfully";
        });
      } else {
        setState(() {
          _status = "❌ Server error";
        });
      }
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.battery_charging_full, size: 80, color: Colors.greenAccent),
            const SizedBox(height: 20),
            Text("$_batteryLevel%",
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Live Battery Level"),
            const SizedBox(height: 10),
            Text(_status, style: const TextStyle(color: Colors.greenAccent)),
          ],
        ),
      ),
    );
  }
}