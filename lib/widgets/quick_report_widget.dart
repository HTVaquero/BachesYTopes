import 'package:flutter/material.dart';
import '../models/hazard.dart';

class QuickReportWidget extends StatelessWidget {
  final Function(HazardType) onReport;

  const QuickReportWidget({Key? key, required this.onReport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildReportButton(
          context,
          HazardType.pothole,
          Icons.warning,
          'Pothole',
          Colors.orange,
        ),
        _buildReportButton(
          context,
          HazardType.speedBump,
          Icons.speed,
          'Speed Bump',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildReportButton(
    BuildContext context,
    HazardType type,
    IconData icon,
    String label,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () => onReport(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
