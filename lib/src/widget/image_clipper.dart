import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sprite/src/model/format.dart';
import 'dart:ui' as ui;

class ClippedImage extends StatelessWidget {
  final ui.Image image;
  final ImagePortion portion;
  final Size size;

  const ClippedImage(
      {Key? key,
      required this.image,
      required this.portion,
      required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final size = Size(portion.size.x.toDouble(), portion.size.y.toDouble());
    return CustomPaint(
      size: size,
      painter: _RawPartImagePainter(
        image: image,
        portion: portion,
      ),
    );
  }
}

class _RawPartImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePortion portion;

  final painter = Paint();

  _RawPartImagePainter({required this.image, required this.portion});

  @override
  void paint(Canvas canvas, Size size) {
    Rect src =
        Offset(portion.offset.x.toDouble(), portion.offset.y.toDouble()) &
            Size(portion.size.x.toDouble(), portion.size.y.toDouble());
    final dst = Offset.zero & size;

    canvas.drawImageRect(image, src, dst, painter);
  }

  @override
  bool shouldRepaint(covariant _RawPartImagePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.portion != portion;
  }
}
