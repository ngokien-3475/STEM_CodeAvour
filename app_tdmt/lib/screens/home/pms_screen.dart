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

      setState(() {
        pm10Value = (pm10Snapshot.value != null)
            ? double.tryParse(pm10Snapshot.value.toString()) ?? 0
            : 0;
        pm25Value = (pm25Snapshot.value != null)
            ? double.tryParse(pm25Snapshot.value.toString()) ?? 0
            : 0;
        pm01Value = (pm01Snapshot.value != null)
            ? double.tryParse(pm01Snapshot.value.toString()) ?? 0
            : 0;

        _updateQuality(pm10Value.toInt(), 'PM10');
        _updateQuality(pm25Value.toInt(), 'PM25');
        _updateQuality(pm01Value.toInt(), 'PM01');
      });
    } catch (error) {
      print("Error fetching data: $error");
      // Consider showing an error message to the user
    }
  }

  void _updateQuality(int value, String particleType) {
    String quality;
    Color color;

    if (value >= 0 && value <= 50) {
      quality = 'Good';
      color = Colors.green;
    } else if (value >= 51 && value <= 100) {
      quality = 'Satisfactory';
      color = Colors.yellow;
    } else if (value >= 101 && value <= 250) {
      quality = 'Moderate';
      color = Colors.orange;
    } else if (value >= 251 && value <= 350) {
      quality = 'Poor';
      color = Colors.red;
    } else if (value >= 351 && value <= 430) {
      quality = 'Very Poor';
      color = Colors.redAccent;
    } else {
      quality = 'Severe';
      color = Colors.brown;
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
                Row(
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
                    const SizedBox(width: 10),
                    StreamBuilder(
                      stream:
                          Stream.periodic(const Duration(seconds: 1), (count) {
                        return DateTime.now();
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final now = snapshot.data as DateTime;
                          final formattedDate =
                              "${now.day} ${_getMonthName(now.month)} ${now.year}";
                          final formattedTime =
                              "${now.hour}:${now.minute}:${now.second}";
                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '$formattedDate\n$formattedTime',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                const Text(
                  "PMS",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Image.asset(
                    AppImages.fab,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // PM Data Row
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _buildPmCard("PM 10 (µg/m³)", pm10Value.toStringAsFixed(0),
            //         pm10Quality, pm10Color, AppImages.pm10),
            //     _buildPmCard("PM 2.5 (µg/m³)", pm25Value.toStringAsFixed(0),
            //         pm25Quality, pm25Color, AppImages.pm25),
            //     _buildPmCard("PM 1.0 (µg/m³)", pm01Value.toStringAsFixed(0),
            //         pm01Quality, pm01Color, AppImages.pm01),
            //   ],
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                value: 100, // Giá trị hiển thị
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
                                      '100', // Giá trị đo AQI
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'AQI', // Thêm chữ AQI bên dưới
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
                                value: 100, // Giá trị hiển thị
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
                                      '100', // Giá trị đo AQI
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'AQI', // Thêm chữ AQI bên dưới
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
                              // GaugeRange(
                              //     startValue: 150,
                              //     endValue: 200,
                              //     color: Colors.red,
                              //     startWidth: 50,
                              //     endWidth: 50),
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
                                value: 100, // Giá trị hiển thị
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
                                      '100', // Giá trị đo AQI
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'AQI', // Thêm chữ AQI bên dưới
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
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
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
                            endValue: 30,
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
                                const Icon(Icons.wb_sunny,
                                    size: 120,
                                    color: Colors.orange), // Icon mặt trời
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
                  width: 300,
                  height: 300,
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
                            endValue: 30,
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
                                const Icon(Icons.water_drop,
                                    size: 120,
                                    color: Colors.blue), // Icon mặt trời
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
                  width: 300,
                  height: 300,
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
                            endValue: 30,
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
                                const Icon(Icons.wb_sunny,
                                    size: 120,
                                    color: Colors.orange), // Icon mặt trời
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
            // Footer Row
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Container(
            //       width: 324,
            //       height: 172,
            //       child: Text(
            //         "PM10 particles are coarse particles that can include dust, pollen, mold spores, and larger airborne particles. ",
            //         style: const TextStyle(
            //           fontSize: 22,
            //           color: Colors.white,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //     SizedBox(
            //       child: Image.asset(
            //         AppImages.level01,
            //         fit: BoxFit.contain,
            //         height: 146,
            //         width: 309,
            //       ),
            //     ),
            //     Container(
            //       height: 190,
            //       width: 328,
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           _buildWarningRow(AppImages.level02,
            //               "VERY POOR can aggravate existing respiratory conditions such as asthma or bronchitis."),
            //           _buildWarningRow(AppImages.level03,
            //               "SEVERE may contribute to chronic respiratory diseases and cardiovascular problems."),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ tạo card thông tin PM
  Widget _buildPmCard(String title, String value, String quality,
      Color qualityColor, String imag) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                child: Image.asset(
                  imag,
                  fit: BoxFit.contain,
                  width: 50,
                  height: 81,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quality,
            style: TextStyle(
              color: qualityColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hỗ trợ tạo hàng cảnh báo
  Widget _buildWarningRow(String imagePath, String text) {
    return Container(
      width: 327,
      height: 90,
      child: Row(
        children: [
          SizedBox(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: 50,
              height: 81,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: text.split(" ")[0],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " " + text.substring(text.indexOf(" ") + 1),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
