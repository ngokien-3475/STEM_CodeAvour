import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_tdmt/screens/home/home_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../res/images/app_images.dart'; // Make sure this path is correct

class PmsScreen extends StatefulWidget {
  const PmsScreen({super.key});

  @override
  State<PmsScreen> createState() => _PmsScreenState();
}

class _PmsScreenState extends State<PmsScreen> {
  double pm10Value = 0;
  double pm25Value = 0;
  double pm01Value = 0;
  double tempValue = 0;
  double humiValue = 0;
  double coValue = 0;
  String pm10Quality = 'Loading...';
  String pm25Quality = 'Loading...';
  String pm01Quality = 'Loading...';

  Color pm10Color = Colors.grey;
  Color pm25Color = Colors.grey;
  Color pm01Color = Colors.grey;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _getDataFromFirebase();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getDataFromFirebase(); // Refresh data every 5 seconds
    });
  }

  Future<void> _getDataFromFirebase() async {
    try {
      DataSnapshot pm10Snapshot =
          await _databaseReference.child('monitor/moniPM10').get();
      DataSnapshot pm25Snapshot =
          await _databaseReference.child('monitor/moniPM25').get();
      DataSnapshot pm01Snapshot =
          await _databaseReference.child('monitor/moniPM01').get();
      DataSnapshot tempSnapshot =
          await _databaseReference.child('monitor/moniTemp').get();
      DataSnapshot humiSnapshot =
          await _databaseReference.child('monitor/moniHumi').get();
      DataSnapshot coSnapshot =
          await _databaseReference.child('monitor/moniCo').get();

      setState(() {
        pm10Value = double.tryParse(pm10Snapshot.value.toString()) ?? 0;
        pm25Value = double.tryParse(pm25Snapshot.value.toString()) ?? 0;
        pm01Value = double.tryParse(pm01Snapshot.value.toString()) ?? 0;
        tempValue = double.tryParse(tempSnapshot.value.toString()) ?? 0;
        humiValue = double.tryParse(humiSnapshot.value.toString()) ?? 0;
        coValue = double.tryParse(coSnapshot.value.toString()) ?? 0;

        _updateQuality(pm10Value.toInt(), 'PM10');
        _updateQuality(pm25Value.toInt(), 'PM25');
        _updateQuality(pm01Value.toInt(), 'PM01');
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _updateQuality(int value, String particleType) {
    String quality;
    Color color;

    if (particleType == 'PM10') {
      if (value >= 0 && value <= 54) {
        quality = 'Good';
        color = Colors.green;
      } else if (value <= 154) {
        quality = 'Satisfactory';
        color = Colors.yellow;
      } else if (value <= 254) {
        quality = 'Moderate';
        color = Colors.orange;
      } else if (value <= 354) {
        quality = 'Very Poor';
        color = Colors.purple;
      } else {
        quality = 'Severe';
        color = Colors.brown;
      }
    } else if (particleType == 'PM25') {
      if (value >= 0 && value <= 12) {
        quality = 'Good';
        color = Colors.green;
      } else if (value <= 35) {
        quality = 'Satisfactory';
        color = Colors.yellow;
      } else if (value <= 55) {
        quality = 'Moderate';
        color = Colors.orange;
      } else if (value <= 150) {
        quality = 'Very Poor';
        color = Colors.purple;
      } else {
        quality = 'Severe';
        color = Colors.brown;
      }
    } else if (particleType == 'PM01') {
      if (value >= 0 && value <= 6) {
        quality = 'Good';
        color = Colors.green;
      } else if (value <= 10) {
        quality = 'Satisfactory';
        color = Colors.yellow;
      } else if (value <= 15) {
        quality = 'Moderate';
        color = Colors.orange;
      } else if (value <= 35) {
        quality = 'Very Poor';
        color = Colors.purple;
      } else {
        quality = 'Severe';
        color = Colors.brown;
      }
    } else {
      return; // Không xử lý loại hạt khác
    }

    setState(() {
      if (particleType == 'PM10') {
        pm10Quality = 'Quality – $quality';
        pm10Color = color;
      } else if (particleType == 'PM25') {
        pm25Quality = 'Quality – $quality';
        pm25Color = color;
      } else if (particleType == 'PM01') {
        pm01Quality = 'Quality – $quality';
        pm01Color = color;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: IconButton(
                    icon: Image.asset(
                      AppImages.home,
                      fit: BoxFit.contain,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                  ),
                ),
                Text(
                  "Thông số theo dõi môi trường",
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
                  stream: Stream.periodic(const Duration(seconds: 1), (count) {
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
                          borderRadius:
                              BorderRadius.circular(12.0), // Bo góc đẹp hơn
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
                                color:
                                    Colors.orangeAccent.shade200, // Màu cam nhẹ
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2, // Khoảng cách giữa các chữ
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Image.asset(
                    AppImages.logo2,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 500,
                                showLabels: false,
                                showTicks: false,
                                axisLineStyle: const AxisLineStyle(
                                  thickness: 10,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color: Colors.white,
                                ),
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                      startValue: 0,
                                      endValue: 54,
                                      color: Colors.green,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 54,
                                      endValue: 154,
                                      color: Colors.yellow,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 154,
                                      endValue: 254,
                                      color: Colors.orange,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 254,
                                      endValue: 354,
                                      color: Colors.purple,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 354,
                                      endValue: 500,
                                      color: Colors.brown,
                                      startWidth: 50,
                                      endWidth: 50),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                    value: pm10Value, // Giá trị hiển thị
                                    enableAnimation:
                                        true, // Hiệu ứng chuyển động
                                    needleLength:
                                        0.6, // Độ dài kim (từ 0.0 đến 1.0)
                                    needleStartWidth: 0.5, // Đầu kim rất mỏng
                                    needleEndWidth:
                                        12, // Đuôi kim rộng hơn để tạo hình mũi tên
                                    needleColor: Colors.red, // Màu kim
                                    knobStyle: const KnobStyle(
                                      color: Colors.red, // Màu trung tâm kim
                                      borderColor: Colors
                                          .white, // Viền ngoài của tâm kim
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
                                          '$pm10Value(um/m3)', // Giá trị đo AQI
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          'PM10', // Thêm chữ AQI bên dưới
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                        Text(
                          pm10Quality,
                          style: TextStyle(
                            color: pm10Color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 200,
                                showLabels: false,
                                showTicks: false,
                                axisLineStyle: const AxisLineStyle(
                                  thickness: 10,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color: Colors.white,
                                ),
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                      startValue: 0,
                                      endValue: 12,
                                      color: Colors.green,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 12,
                                      endValue: 35,
                                      color: Colors.yellow,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 35,
                                      endValue: 55,
                                      color: Colors.orange,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 55,
                                      endValue: 150,
                                      color: Colors.purple,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 150,
                                      endValue: 300,
                                      color: Colors.brown,
                                      startWidth: 50,
                                      endWidth: 50),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                    value: pm25Value, // Giá trị hiển thị
                                    enableAnimation:
                                        true, // Hiệu ứng chuyển động
                                    needleLength:
                                        0.6, // Độ dài kim (từ 0.0 đến 1.0)
                                    needleStartWidth: 0.5, // Đầu kim rất mỏng
                                    needleEndWidth:
                                        12, // Đuôi kim rộng hơn để tạo hình mũi tên
                                    needleColor: Colors.red, // Màu kim
                                    knobStyle: const KnobStyle(
                                      color: Colors.red, // Màu trung tâm kim
                                      borderColor: Colors
                                          .white, // Viền ngoài của tâm kim
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
                                          '$pm25Value(um/m3)', // Giá trị đo AQI
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          'PM2.5', // Thêm chữ AQI bên dưới
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                        Text(
                          pm25Quality,
                          style: TextStyle(
                            color: pm25Color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 50,
                                showLabels: false,
                                showTicks: false,
                                axisLineStyle: const AxisLineStyle(
                                  thickness: 10,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color: Colors.white,
                                ),
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                      startValue: 0,
                                      endValue: 6,
                                      color: Colors.green,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 6,
                                      endValue: 10,
                                      color: Colors.yellow,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 10,
                                      endValue: 15,
                                      color: Colors.orange,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 15,
                                      endValue: 35,
                                      color: Colors.purple,
                                      startWidth: 50,
                                      endWidth: 50),
                                  GaugeRange(
                                      startValue: 35,
                                      endValue: 50,
                                      color: Colors.brown,
                                      startWidth: 50,
                                      endWidth: 50),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                    value: pm01Value, // Giá trị hiển thị
                                    enableAnimation:
                                        true, // Hiệu ứng chuyển động
                                    needleLength:
                                        0.6, // Độ dài kim (từ 0.0 đến 1.0)
                                    needleStartWidth: 0.5, // Đầu kim rất mỏng
                                    needleEndWidth:
                                        12, // Đuôi kim rộng hơn để tạo hình mũi tên
                                    needleColor: Colors.red, // Màu kim
                                    knobStyle: const KnobStyle(
                                      color: Colors.red, // Màu trung tâm kim
                                      borderColor: Colors
                                          .white, // Viền ngoài của tâm kim
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
                                          '$pm01Value(um/m3)', // Giá trị đo AQI
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          'PM1.0', // Thêm chữ AQI bên dưới
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                        Text(
                          pm01Quality,
                          style: TextStyle(
                            color: pm01Color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 270,
                  height: 270,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        startAngle: 0,
                        endAngle: 360,
                        showLabels: false,
                        showTicks: false,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 25,
                          color: Colors.blueGrey, // Đường tròn nền
                        ),
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 0,
                            endValue: tempValue,
                            gradient: const SweepGradient(
                              colors: [
                                Colors.yellow,
                                Colors.orange,
                                Colors.red,
                              ],
                            ),
                            startWidth: 25,
                            endWidth: 25,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Nhiệt độ",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                                const Icon(Icons.wb_sunny,
                                    size: 90, color: Colors.orange),
                                Text("$tempValue°C",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 24)),
                                // Icon mặt trời
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 270,
                  height: 270,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        startAngle: 0,
                        endAngle: 360,
                        showLabels: false,
                        showTicks: false,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 25,
                          color: Colors.blueGrey, // Đường tròn nền
                        ),
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 0,
                            endValue: humiValue,
                            gradient: const SweepGradient(
                              colors: [
                                Colors.yellow,
                                Colors.orange,
                                Colors.red,
                              ],
                            ),
                            startWidth: 25,
                            endWidth: 25,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Độ ẩm",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                                const Icon(Icons.water_drop,
                                    size: 90, color: Colors.blue),
                                Text("$humiValue%",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24)), // Icon mặt trời
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 270,
                  height: 270,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        startAngle: 0,
                        endAngle: 360,
                        showLabels: false,
                        showTicks: false,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 25,
                          color: Colors.blueGrey, // Đường tròn nền
                        ),
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 0,
                            endValue: coValue,
                            gradient: const SweepGradient(
                              colors: [
                                Colors.yellow,
                                Colors.orange,
                                Colors.red,
                              ],
                            ),
                            startWidth: 25,
                            endWidth: 25,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("CO",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                                const Icon(Icons.air,
                                    size: 90, color: Colors.orange),
                                Text(
                                  "$coValue ppm",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ) // Icon mặt trời
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Hàm lấy tên tháng
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
}
