import 'dart:math';
import 'package:flutter/material.dart';

class AmbientVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const AmbientVisualizer({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  @override
  State<AmbientVisualizer> createState() => _AmbientVisualizerState();
}

class _AmbientVisualizerState extends State<AmbientVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4)) // Slower, deeper breath
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant AmbientVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      // Don't stop abruptly, let it finish or slow down? 
      // For now, let's keep it simple: stop.
      // Or better: animateTo(0) to reset smoothly?
      // Let's just keep it running for ambient effect even when paused?
      // User requested "moves with rhythm", so maybe slow down when paused.
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VisualizerPainter(
        animation: _controller,
        isPlaying: widget.isPlaying,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: widget.child,
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isPlaying;
  final Color color;

  _VisualizerPainter({
    required this.animation,
    required this.isPlaying,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    // Assume child is circleavatar radius approx 80%? 
    // We want waves OUTSIDE the child.
    
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 3 wave layers
    for (int i = 0; i < 3; i++) {
        _drawWave(canvas, center, radius, i, paint);
    }
  }

  void _drawWave(Canvas canvas, Offset center, double baseRadius, int waveIndex, Paint basePaint) {
    final path = Path();
    final time = animation.value * 2 * pi;
    final waveOffset = waveIndex * (2 * pi / 3); // Phase shift
    
    // Dynamic radius expansion
    // Provide a "breathing" base expansion
    final breath = sin(time + waveIndex) * 10; 

    for (double i = 0; i <= 360; i += 5) {
      final angle = i * (pi / 180);
      
      // Calculate wave variance
      // This creates the "bumpy" circle effect
      // speed factor: time * 2
      // frequency: 8 bumps
      final waveAmplitude = 15.0;
      final variance = sin(angle * 8 + time * 2 + waveOffset) * waveAmplitude;
      
      // Base distance from center
      // Start slightly outside the child widget?
      // Let's assume child radius is baseRadius * 0.8
      final r = (baseRadius * 0.85) + 20.0 + variance + breath;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Fade out outer waves or just random opacity?
    basePaint.color = color.withOpacity(0.4 / (waveIndex + 1));
    basePaint.strokeWidth = 3.0 - waveIndex; 
    
    canvas.drawPath(path, basePaint);
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) => true;
}
