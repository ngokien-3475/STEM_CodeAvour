import 'package:flutter/material.dart';
import 'package:app_tdmt/screens/home/pms_screen.dart';
import '../../res/images/app_images.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double tempValue = 0;
  double humiValue = 0;
  double coValue = 0;
  double aqiValue = 0;
  String aqiDescription = '';
  String pollutant = 'AQI';
  Color aqiColor = Colors.green;

  // Add a variable to hold the rotation angle of the arrow
  double arrowRotationAngle = 0;

  // Add a variable to hold the CO level description
  String coLevelDescription = '';
  Color coLevelColor = Colors.green;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> _getDataFromFirebase() async {
    try {
      DataSnapshot tempSnapshot =
          await _databaseReference.child('monitor/moniTemp').get();
      DataSnapshot humiSnapshot =
          await _databaseReference.child('monitor/moniHumi').get();
      DataSnapshot coSnapshot =
          await _databaseReference.child('monitor/moniCo').get();
      DataSnapshot aqiSnapshot =
          await _databaseReference.child('monitor/moniAQI').get();

      print("Temp Snapshot: ${tempSnapshot.value}");
      print("Humi Snapshot: ${humiSnapshot.value}");
      print("CO Snapshot: ${coSnapshot.value}");
      print("AQI Snapshot: ${aqiSnapshot.value}");

      setState(() {
        tempValue = (tempSnapshot.value != null)
            ? double.tryParse(tempSnapshot.value.toString()) ?? 0
            : 0;
        humiValue = (humiSnapshot.value != null)
            ? double.tryParse(humiSnapshot.value.toString()) ?? 0
            : 0;
        coValue = (coSnapshot.value != null)
            ? double.tryParse(coSnapshot.value.toString()) ?? 0
            : 0;
        aqiValue = (aqiSnapshot.value != null)
            ? double.tryParse(aqiSnapshot.value.toString()) ?? 0
            : 0;
        _updateAQIInfo(aqiValue.toInt());
        _updateCOInfo(coValue); // Update CO level description and color

        // Update arrow rotation after getting aqiValue
        arrowRotationAngle = _calculateArrowRotationAngle(aqiValue.toInt());
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  // Function to calculate the rotation angle based on AQI value
  double _calculateArrowRotationAngle(int aqi) {
    // Normalize AQI to a 0-1 range, clamping to the range [0, 500]
    double normalizedAqi = (aqi.clamp(0, 400) / 400.0);
    // Map the normalized AQI to an angle range of 0 to pi.
    // This assumes that the semicircle gauge starts at 0 and ends at pi.
    double angle = pi * normalizedAqi;

    // return angle - 1 * pi / 6;
    return angle - pi / 2;
  }

  void _updateAQIInfo(int aqi) {
    if (aqi >= 0 && aqi <= 50) {
      aqiDescription = 'Tốt';
      aqiColor = Colors.green;
    } else if (aqi >= 51 && aqi <= 100) {
      aqiDescription = 'Trung bình';
      aqiColor = Colors.lightGreen;
    } else if (aqi >= 101 && aqi <= 219) {
      aqiDescription = 'Vừa phải';
      aqiColor = Colors.yellow;
    } else if (aqi >= 201 && aqi <= 300) {
      aqiDescription = 'Kém';
      aqiColor = Colors.orange;
    } else if (aqi >= 301 && aqi <= 400) {
      aqiDescription = 'Rất Kém';
      aqiColor = Colors.redAccent;
    } else if (aqi >= 401 && aqi <= 500) {
      aqiDescription = 'Nguy hại';
      aqiColor = Colors.brown;
    } else {
      aqiDescription = 'Không xác định';
      aqiColor = Colors.grey;
    }
  }

  void _updateCOInfo(double coValue) {
    if (max(coValue - 219, 0) >= 0 && max(coValue - 219, 0) <= 9) {
      coLevelDescription = 'Mức bình thường, không gây hại';
      coLevelColor = Colors.green;
    } else if (max(coValue - 219, 0) >= 10 && max(coValue - 219, 0) <= 35) {
      coLevelDescription =
          'Có thể gây ra các triệu chứng nhẹ như đau đầu, mệt mỏi nếu tiếp xúc lâu dài';
      coLevelColor = Colors.yellow;
    } else if (max(coValue - 219, 0) >= 36 && max(coValue - 219, 0) <= 100) {
      coLevelDescription = 'Đau đầu dữ dội, chóng mặt, buồn nôn sau vài giờ';
      coLevelColor = Colors.orange;
    } else if (max(coValue - 219, 0) > 100) {
      coLevelDescription =
          'Nguy hiểm đến tính mạng, có thể gây mất ý thức và tử vong';
      coLevelColor = Colors.red;
    } else {
      coLevelDescription = 'Không xác định';
      coLevelColor = Colors.grey;
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
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.11,
                            child: Image.asset(
                              AppImages.fab,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1),
                                (count) {
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
                        "Giám sát môi trường",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Đồ thị AQI
                      Expanded(
                        flex: 2, // Chiếm 2 phần không gian
                        child: SizedBox(
                          height: 400, // Chiều cao cố định
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(360, 180),
                                painter: AQIGaugePainter(),
                              ),
                              Positioned(
                                top: 178,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      aqiValue.toStringAsFixed(0),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Transform.rotate(
                                        angle: arrowRotationAngle,
                                        child: Positioned(
                                          // bottom: 1000000,
                                          child: Image.asset(
                                            AppImages.muiten,
                                            width: 100,
                                            height: 100,
                                          ),
                                        )),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Chất lượng - $aqiDescription',
                                      style: TextStyle(
                                        color: aqiColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Chất ô nhiễm chính : $pollutant',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bảng thông số
                      Expanded(
                        flex: 3, // Chiếm 3 phần không gian
                        child: Container(
                          padding: const EdgeInsets.only(top: 100),
                          height: 400, // Chiều cao cố định
                          child: Table(
                            border:
                                TableBorder.all(color: Colors.green, width: 3),
                            columnWidths: const {
                              0: FixedColumnWidth(
                                  150), // Điều chỉnh độ rộng cột
                              1: FixedColumnWidth(
                                  150), // Điều chỉnh độ rộng cột
                            },
                            children: [
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'Nhiệt độ',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        '${tempValue.toStringAsFixed(1)}°C',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'Độ ẩm',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        '${humiValue.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'CO',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${max(coValue - 219, 0).toStringAsFixed(1)} ppm',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            coLevelDescription,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: coLevelColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
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

class AQIGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height * 2;
    final center = Offset(width / 2, size.height);

    final colors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.purple,
      Colors.brown,
      Colors.brown,
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi;
    double sweepAngle = pi / colors.length;

    for (var color in colors) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCenter(center: center, width: width, height: height),
        startAngle,
        sweepAngle + pi / 180,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
