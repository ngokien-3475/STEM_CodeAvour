import 'package:flutter/material.dart';
import 'package:app_tdmt/screens/home/pms_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../res/images/app_images.dart';
// import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double aqiValue = 0;
  String aqiDescription = '';
  String pollutant = 'AQI';
  Color aqiColor = Colors.green;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> _getDataFromFirebase() async {
    try {
      DataSnapshot aqiSnapshot =
          await _databaseReference.child('monitor/moniAQI').get();

      print("AQI Snapshot: ${aqiSnapshot.value}");

      setState(() {
        aqiValue = (aqiSnapshot.value != null)
            ? double.tryParse(aqiSnapshot.value.toString()) ?? 0
            : 0;
        _updateAQIInfo(aqiValue.toInt());
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _updateAQIInfo(int aqi) {
    if (aqi >= 0 && aqi <= 50) {
      aqiDescription = 'Tốt';
      aqiColor = Colors.green;
    } else if (aqi >= 51 && aqi <= 100) {
      aqiDescription = 'Vừa phải';
      aqiColor = Colors.yellow;
    } else if (aqi >= 101 && aqi <= 150) {
      aqiDescription = 'Kém';
      aqiColor = Colors.orange;
    } else if (aqi >= 151 && aqi <= 200) {
      aqiDescription = 'Rất Kém';
      aqiColor = Colors.redAccent;
    } else if (aqi >= 201 && aqi <= 300) {
      aqiDescription = 'Nguy hại';
      aqiColor = Colors.brown;
    } else {
      aqiDescription = 'Không xác định';
      aqiColor = Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataFromFirebase();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getDataFromFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.11,
                        child: Image.asset(
                          AppImages.logo1,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "Giám sát môi trường",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5, // Giãn chữ giúp dễ đọc hơn
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(2, 2),
                            ),
                          ],
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFF00FFCC), // Xanh ngọc
                                Color(0xFF0099FF), // Xanh biển
                              ],
                            ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1),
                            (count) {
                          return DateTime.now();
                        }),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final now = snapshot.data as DateTime;
                            final formattedDate =
                                " ${now.day} ${_getMonthName(now.month)} ${now.year}";
                            final formattedTime =
                                "${now.hour.toString().padLeft(2, '0')}:"
                                "${now.minute.toString().padLeft(2, '0')}:"
                                "${now.second.toString().padLeft(2, '0')}";

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.5), // Màu nền nhẹ nhàng
                                borderRadius: BorderRadius.circular(
                                    12.0), // Bo góc đẹp hơn
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 3,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: Colors
                                          .orangeAccent.shade200, // Màu cam nhẹ
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing:
                                          1.2, // Khoảng cách giữa các chữ
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5.0,
                                          color: Colors.black.withOpacity(0.6),
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          AppImages.back,
                          width: 50,
                          height: 50,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PmsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 450,
                        height: 450,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 500,
                              showLabels: false,
                              showTicks: false,
                              axisLineStyle: const AxisLineStyle(
                                thickness: 60,
                                cornerStyle: CornerStyle.bothCurve,
                                color: Colors.white,
                              ),
                              ranges: <GaugeRange>[
                                GaugeRange(
                                    startValue: 0,
                                    endValue: 50,
                                    color: Colors.green,
                                    startWidth: 50,
                                    endWidth: 50),
                                GaugeRange(
                                    startValue: 50,
                                    endValue: 100,
                                    color: Colors.yellow,
                                    startWidth: 50,
                                    endWidth: 50),
                                GaugeRange(
                                    startValue: 100,
                                    endValue: 150,
                                    color: Colors.orange,
                                    startWidth: 50,
                                    endWidth: 50),
                                GaugeRange(
                                    startValue: 150,
                                    endValue: 200,
                                    color: Colors.red,
                                    startWidth: 50,
                                    endWidth: 50),
                                GaugeRange(
                                    startValue: 200,
                                    endValue: 300,
                                    color: Colors.purple,
                                    startWidth: 50,
                                    endWidth: 50),
                                GaugeRange(
                                    startValue: 300,
                                    endValue: 500,
                                    color: Colors.brown,
                                    startWidth: 50,
                                    endWidth: 50),
                              ],
                              pointers: <GaugePointer>[
                                NeedlePointer(
                                  value: aqiValue, // Giá trị hiển thị
                                  enableAnimation: true, // Hiệu ứng chuyển động
                                  needleLength:
                                      0.6, // Độ dài kim (từ 0.0 đến 1.0)
                                  needleStartWidth: 0.5, // Đầu kim rất mỏng
                                  needleEndWidth:
                                      12, // Đuôi kim rộng hơn để tạo hình mũi tên
                                  needleColor: Colors.red, // Màu kim
                                  knobStyle: const KnobStyle(
                                    color: Colors.red, // Màu trung tâm kim
                                    borderColor:
                                        Colors.white, // Viền ngoài của tâm kim
                                    borderWidth: 2, // Độ dày viền tâm kim
                                    sizeUnit: GaugeSizeUnit.factor,
                                    knobRadius:
                                        0.0000, // Điều chỉnh tâm kim lớn hơn để cân đối với kim
                                  ),
                                ),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$aqiValue', // Giá trị đo AQI
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'AQI', // Thêm chữ AQI bên dưới
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '$aqiDescription',
                                        style: TextStyle(
                                          color: aqiColor,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  angle: 90,
                                  positionFactor: 0.5,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 100),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset(
                          AppImages.fab,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FlexColumnWidth(),
                      4: FlexColumnWidth(),
                      5: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildAQICell('Tốt\n(0-50)', Colors.green),
                          _buildAQICell('Trung bình\n(51-100)', Colors.yellow),
                          _buildAQICell('Vừa phải\n(101-150)', Colors.orange),
                          _buildAQICell('Kém\n(151-200)', Colors.redAccent),
                          _buildAQICell('Rất kém\n(201-300)', Colors.purple),
                          _buildAQICell('Nguy hại\n(300+)', Colors.brown),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Tháng 1';
      case 2:
        return 'Tháng 2';
      case 3:
        return 'Tháng 3';
      case 4:
        return 'Tháng 4';
      case 5:
        return 'Tháng 5';
      case 6:
        return 'Tháng 6';
      case 7:
        return 'Tháng 7';
      case 8:
        return 'Tháng 8';
      case 9:
        return 'Tháng 9';
      case 10:
        return 'Tháng 10';
      case 11:
        return 'Tháng 11';
      case 12:
        return 'Tháng 12';
      default:
        return '';
    }
  }

  Widget _buildAQICell(String text, Color color) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
