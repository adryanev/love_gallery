import 'package:flutter/material.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/widgets/audio_control.dart';

class DoodleScreen extends StatefulWidget {
  const DoodleScreen({super.key});

  @override
  State<DoodleScreen> createState() => _DoodleScreenState();
}

class _DoodleScreenState extends State<DoodleScreen> {
  Color _selectedColor = AppTheme.roseQuartz;
  double _brushSize = 10;
  final List<DrawnLine> _lines = <DrawnLine>[];
  DrawnLine? _currentLine;
  final GlobalKey _canvasKey = GlobalKey();

  final List<Color> _colors = [
    AppTheme.roseQuartz,
    AppTheme.dustyMauve,
    AppTheme.goldWash,
    AppTheme.petalPink,
    AppTheme.warmCharcoal,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doodle Together'),
        backgroundColor: AppTheme.petalPink,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: AudioControl(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearCanvas,
            tooltip: 'Clear Canvas',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Canvas background
          Container(color: AppTheme.blushPink.withValues(alpha: 0.8)),

          // Drawing area
          GestureDetector(
            key: _canvasKey,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: DoodlePainter(lines: _lines, currentLine: _currentLine),
              size: Size.infinite,
              isComplex: true,
            ),
          ),

          // Color and brush controls
          Positioned(bottom: 20, left: 0, right: 0, child: _buildControls()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          // Brush size slider
          Row(
            children: [
              const Icon(Icons.brush, color: AppTheme.dustyMauve),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: _brushSize,
                  min: 1,
                  max: 30,
                  activeColor: _selectedColor,
                  onChanged: (value) {
                    setState(() {
                      _brushSize = value;
                    });
                  },
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedColor.withValues(alpha: 0.6),
                ),
                child: Center(
                  child: Container(
                    width: _brushSize / 2,
                    height: _brushSize / 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Color palette
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _selectedColor == color
                                  ? AppTheme.warmCharcoal
                                  : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _currentLine = DrawnLine(
        points: [point],
        color: _selectedColor,
        width: _brushSize,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      final List<Offset> points = List.from(_currentLine!.points)..add(point);
      _currentLine = DrawnLine(
        points: points,
        color: _selectedColor,
        width: _brushSize,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _lines.add(_currentLine!);
      _currentLine = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      _lines.clear();
    });
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({required this.points, required this.color, required this.width});
}

class DoodlePainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DoodlePainter({required this.lines, this.currentLine});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all completed lines
    for (final line in lines) {
      _drawLine(canvas, line);
    }

    // Draw current line being drawn
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    final paint =
        Paint()
          ..color = line.color.withValues(
            alpha: 0.7,
          ) // Add transparency for watercolor effect
          ..strokeWidth = line.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..blendMode = BlendMode.srcOver; // Watercolor blending

    final shadowPaint =
        Paint()
          ..color = line.color.withValues(alpha: 0.3)
          ..strokeWidth = line.width + 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            2,
          ); // Soft edges

    // Draw shadow for watercolor effect
    if (line.points.length > 1) {
      final path = Path();
      path.moveTo(line.points.first.dx, line.points.first.dy);

      for (int i = 1; i < line.points.length; i++) {
        final p1 = line.points[i - 1];
        final p2 = line.points[i];

        // Smooth curve between points
        path.quadraticBezierTo(
          p1.dx,
          p1.dy,
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
      }

      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, paint);
    } else if (line.points.length == 1) {
      // Just a dot
      canvas.drawCircle(line.points.first, line.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DoodlePainter oldDelegate) {
    return oldDelegate.lines != lines || oldDelegate.currentLine != currentLine;
  }
}
