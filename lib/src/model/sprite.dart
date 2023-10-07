import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_sprite/src/model/format.dart';
import 'package:flutter_sprite/src/widget/image_clipper.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class SpriteFrame {
  final ui.Image image;

  final ImagePortion portion;

  final Point<num> translate;

  final Duration? interval;

  final bool flip;

  SpriteFrame(this.image,
      {this.translate = const Point<num>(0, 0),
      this.interval,
      ImagePortion? portion,
      this.flip = false})
      : portion = portion ??
            ImagePortion(Point(0, 0), Point(image.width, image.height));

  Rectangle<num> get rectangle => portion.rectangle;
}

class Sprite {
  final Duration interval;

  final Point<num> size;

  final Point<num> anchor;

  final List<SpriteFrame> frames;

  Sprite(this.interval, this.frames, this.size, this.anchor);

  static Future<Sprite> load(String specPath) async {
    final jsonStr = await rootBundle.loadString(specPath, cache: false);
    final json = jsonDecode(jsonStr);
    final spec = SpriteSpec.fromJson(json)!;

    final dir = p.dirname(specPath);

    final frames = <SpriteFrame>[];

    final cache = <String, ui.Image>{};

    for (final frameSpec in spec.frames) {
      final path = p.join(dir, frameSpec.uri);

      ui.Image image;
      if (!cache.containsKey(path)) {
        image = await loadImage(path);
        cache[path] = image;
      } else {
        image = cache[path]!;
      }
      final portion = frameSpec.portion ??
          ImagePortion(Point(0, 0), Point(image.width, image.height));
      bool flip = frameSpec.flip ?? spec.flip ?? false;

      Point<num> translate = Point<num>(0, 0);
      if (frameSpec.anchor != null) {
        Point<num> spriteAnchor = frameSpec.anchor!;
        if (flip) {
          spriteAnchor = Point(spec.size.x - (spec.anchor.x - spriteAnchor.x),
              spec.anchor.y - spriteAnchor.y);
        } else {
          spriteAnchor = spec.anchor - spriteAnchor;
        }
        translate = translate + spriteAnchor;
      }

      frames.add(SpriteFrame(image,
          translate: translate,
          interval: frameSpec.interval,
          portion: portion,
          flip: flip));
    }

    return Sprite(spec.interval, frames, spec.size, spec.anchor);
  }
}
