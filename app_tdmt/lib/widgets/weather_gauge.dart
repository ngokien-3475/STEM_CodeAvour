import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WeatherGauge extends StatelessWidget {
  final double value;
  final String unit;
  final String imagePath;
  final Color startColor;
  final Color endColor;

  const WeatherGauge({
    super.key,
    required this.value,
    required this.unit,
    required this.imagePath,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            startAngle: 150,
            endAngle: 30,
            showLabels: false,
            showTicks: false,
            axisLineStyle:
                const AxisLineStyle(thickness: 12, color: Colors.grey),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: value,
                gradient: SweepGradient(colors: [startColor, endColor]),
                startWidth: 12,
                endWidth: 12,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(imagePath, width: 40, height: 40),
                    const SizedBox(height: 5),
                    Text(
                      '${value.toStringAsFixed(0)}$unit',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
