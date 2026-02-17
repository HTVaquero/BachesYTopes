import 'package:flutter/material.dart';
import '../models/hazard.dart';

class QuickReportWidget extends StatelessWidget {
  final Function(HazardType) onReport;

  const QuickReportWidget({super.key, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildReportButton(
          context,
          HazardType.pothole,
          null,
          'Bache',
          Colors.orange,
          Image.asset('assets/bache.png', width: 96, height: 96),
          Colors.white,
        ),
        _buildReportButton(
          context,
          HazardType.speedBump,
          null,
          'Tope',
          Colors.blue,
          Image.asset('assets/tope.png', width: 96, height: 96),
          Colors.white,
        ),
      ],
    );
  }

  Widget _buildReportButton(
    BuildContext context,
    HazardType type,
    IconData? icon,
    String label,
    Color color,
    Widget? customIcon,
    Color textColor,
  ) {
    return ElevatedButton(
      onPressed: () => onReport(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: customIcon ?? Icon(icon, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _BumpStripe extends StatelessWidget {
  const _BumpStripe();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.yellowAccent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
