import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/model/format.dart';
import 'dart:ui' as ui;

class ClippedImage extends StatelessWidget {
  final ui.Image image;
  final ImagePortion portion;

  const ClippedImage({Key? key, required this.image, required this.portion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(portion.size.x.toDouble(), portion.size.y.toDouble()),
      painter: _RawPartImagePainter(
        image: image,
        portion: portion,
      ),
    );
  }
}

Future<ui.Image> loadImage(String path) async {
  final ByteData assetImageByteData = await rootBundle.load(path);
  final codec =
      await ui.instantiateImageCodec(assetImageByteData.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}

class _RawPartImagePainter extends CustomPainter {
  final ui.Image image;
  // TODO final double scale;
  ImagePortion portion;

  final painter = Paint();

  _RawPartImagePainter({required this.image, required this.portion});

  @override
  void paint(Canvas canvas, Size size) {
    final src =
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
