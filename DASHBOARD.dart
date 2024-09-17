import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Generated file for Firebase configurations

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(EarthingSystemMonitorApp());
}

class EarthingSystemMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthing System Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Set Poppins as the default font
      ),
      home: EarthingSystemMonitorScreen(),
    );
  }
}

class EarthingSystemMonitorScreen extends StatefulWidget {
  @override
  _EarthingSystemMonitorScreenState createState() =>
      _EarthingSystemMonitorScreenState();
}

class _EarthingSystemMonitorScreenState
    extends State<EarthingSystemMonitorScreen> {
  double leakageCurrent = 5.0;
  double earthResistance = 1.5;
  double voltage = 220;
  double soilMoisture = 30.0;
  bool isMoistureAboveThreshold = false;

  // Hover states for each box
  List<bool> isHoveredList = [false, false, false, false];

  // Define Firebase Database reference
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    // Set up listener to get real-time updates
    database.child('earthingSystem/').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          leakageCurrent = (data['leakageCurrent'] as num?)?.toDouble() ?? 0.0;
          earthResistance = (data['earthResistance'] as num?)?.toDouble() ?? 0.0;
          voltage = (data['voltage'] as num?)?.toDouble() ?? 0.0;
          soilMoisture = (data['soilMoisture'] as num?)?.toDouble() ?? 0.0;
          isMoistureAboveThreshold = soilMoisture > 50;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realtime Monitoring of Earthing System'),
      ),
      body: Container(
        color: Colors.blue[900],
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildInteractiveDataCard(0, 'Leakage Current', leakageCurrent.toStringAsFixed(2)),
            buildInteractiveDataCard(1, 'Earth Resistance', earthResistance.toStringAsFixed(2)),
            buildInteractiveDataCard(2, 'Voltage', voltage.toStringAsFixed(2)),
            buildInteractiveDataCard(3, 'Soil Moisture', soilMoisture.toStringAsFixed(2)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Health of Earthing System: ',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Icon(
                  isMoistureAboveThreshold ? Icons.error : Icons.check_circle,
                  color: isMoistureAboveThreshold ? Colors.red : Colors.green,
                  size: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display interactive data cards with individual hover animation
  Widget buildInteractiveDataCard(int index, String label, String value) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHoveredList[index] = true),
      onExit: (_) => setState(() => isHoveredList[index] = false),
      child: AnimatedContainer(
        width: 200,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: isHoveredList[index]
            ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isHoveredList[index] ? Colors.blue[300] : Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: isHoveredList[index]
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ]
              : [],
        ),
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
