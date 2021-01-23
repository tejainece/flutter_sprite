import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/format.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as imgtool;

class SpriteFrame {
  final ImageProvider image;

  final Point<num> anchor;

  final Duration interval;

  SpriteFrame(this.image, {Point<num> anchor, this.interval})
      : anchor = anchor ?? const Point<num>(0, 0);
}

class Sprite {
  final Duration interval;

  final Point<num> size;

  final Point<num> anchor;

  final List<SpriteFrame> frames;

  Sprite(this.interval, this.frames, this.size, this.anchor);

  static Future<Sprite> load(String specPath) async {
    final jsonStr = await rootBundle.loadString(specPath);
    final json = jsonDecode(jsonStr);
    final spec = SpriteSheetSpec.fromJson(json);

    final dir = p.dirname(specPath);

    final frames = <SpriteFrame>[];

    final cache = <String, imgtool.Image>{};

    for (final spriteSpec in spec.sprites) {
      final path = p.join(dir, spriteSpec.uri);

      ImageProvider image;
      if (spriteSpec.portion == null) {
        image = AssetImage(path);
      } else {
        imgtool.Image wholeImage = cache[path];
        if (wholeImage == null) {
          final data = await rootBundle.load(path);
          wholeImage = imgtool.decodeImage(data.buffer.asUint8List());
          cache[path] = wholeImage;
        }
        final portion = spriteSpec.portion;
        final img = imgtool.copyCrop(wholeImage, portion.offset.x,
            portion.offset.y, portion.size.x, portion.size.y);
        image = MemoryImage(Uint8List.fromList(imgtool.encodePng(img)));
      }
      image.resolve(ImageConfiguration.empty);
      frames.add(SpriteFrame(image,
          anchor: spriteSpec.anchor, interval: spriteSpec.interval));
    }

    return Sprite(spec.interval, frames, spec.size, spec.anchor);
  }
}
