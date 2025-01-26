import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceMessage extends StatefulWidget {
  final int duration;
  final String waveform;
  final String url;
  final bool isMe;

  const VoiceMessage({
    Key? key,
    required this.duration,
    required this.waveform,
    required this.url,
    required this.isMe,
  }) : super(key: key);

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..addListener(() {
        setState(() {
          _progress = _controller.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  List<double> _getWaveformData() {
    return widget.waveform.split(',').map((e) => double.parse(e)).toList();
  }

  String _formatDuration(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final waveformData = _getWaveformData();
    final primaryColor = widget.isMe ? Colors.white : Theme.of(context).colorScheme.primary;
    final backgroundColor = widget.isMe ? Colors.white.withOpacity(0.3) : Theme.of(context).dividerColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: primaryColor,
          ),
          onPressed: _togglePlay,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: CustomPaint(
                  painter: WaveformPainter(
                    waveform: waveformData,
                    progress: _progress,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isMe ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveform.length;
    final progressX = size.width * progress;

    for (var i = 0; i < waveform.length; i++) {
      final x = i * barWidth;
      final barHeight = waveform[i] * size.height;
      final center = size.height / 2;
      
      paint.color = x < progressX ? primaryColor : backgroundColor;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, center),
            width: math.max(1, barWidth - 1),
            height: barHeight,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}