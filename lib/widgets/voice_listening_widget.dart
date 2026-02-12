import 'package:flutter/material.dart';

class VoiceListeningWidget extends StatelessWidget {
  final bool isListening;
  final VoidCallback onToggle;

  const VoiceListeningWidget({
    Key? key,
    required this.isListening,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: isListening ? Colors.red : Colors.green,
      child: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
      ),
    );
  }
}
