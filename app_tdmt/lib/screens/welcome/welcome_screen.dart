import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_tdmt/screens/home/home_screen.dart';
import '../../res/images/app_images.dart';
import '../../app/app_routers.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _texts = [
    {
      "title": "Tận hưởng không khí trong lành",
      "subtitle":
          "Nắm bắt chất lượng không khí xung quanh bạn mọi lúc, mọi nơi với nguồn dữ liệu đáng tin cậy nhất."
    },
    {
      "title": "Theo dõi mức độ ô nhiễm",
      "subtitle":
          "Biết được bạn đang tiếp xúc với ô nhiễm như thế nào trong sinh hoạt hằng ngày và tìm cách giảm thiểu rủi ro"
    },
    {
      "title": "Giảm thiểu tác động từ ô nhiễm",
      "subtitle":
          "Chủ động bảo vệ sức khỏe bằng cách theo dõi và giảm thiểu mức độ tiếp xúc với không khí ô nhiễm."
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < _texts.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Image.asset(
                AppImages.bgWelcome,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            // Indicator (đưa lên trên chữ)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _texts.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 30 : 10,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _texts.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _texts[_currentIndex]["title"]!,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        child: Text(
                          _texts[_currentIndex]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 21, color: Colors.grey),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize:
                      const Size(240, 80), // Chiều rộng 200, chiều cao 100
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
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
