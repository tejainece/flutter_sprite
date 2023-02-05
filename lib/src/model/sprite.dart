import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_sprite/src/model/format.dart';
import 'package:flutter_sprite/src/widget/image_clipper.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class SpriteFrame {
  final ui.Image image;

  final SpriteSheetPortion portion;

  final Point<num> translate;

  final Duration? interval;

  final bool flip;

  SpriteFrame(this.image,
      {this.translate = const Point<num>(0, 0),
      this.interval,
      SpriteSheetPortion? portion,
      this.flip = false})
      : portion = portion ??
            SpriteSheetPortion(Point(0, 0), Point(image.width, image.height));
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
    final spec = SpriteSheetSpec.fromJson(json)!;

    final dir = p.dirname(specPath);

    final frames = <SpriteFrame>[];

    final cache = <String, ui.Image>{};

    for (final spriteSpec in spec.sprites) {
      final path = p.join(dir, spriteSpec.uri);

      ui.Image image;
      if (!cache.containsKey(path)) {
        image = await loadImage(path);
        cache[path] = image;
      } else {
        image = cache[path]!;
      }
      final portion = spriteSpec.portion ??
          SpriteSheetPortion(Point(0, 0), Point(image.width, image.height));
      bool flip = spriteSpec.flip ?? spec.flip ?? false;

      Point<num> offset = spriteSpec.translate ?? Point<num>(0, 0);
      if (spriteSpec.anchor != null) {
        Point<num> spriteAnchor = spriteSpec.anchor!;
        if (flip) {
          spriteAnchor = Point(spec.size.x - (spec.anchor.x - spriteAnchor.x),
              spec.anchor.y - spriteAnchor.y);
        } else {
          spriteAnchor = spec.anchor - spriteAnchor;
        }
        offset = offset + spriteAnchor;
      }

      frames.add(SpriteFrame(image,
          translate: offset,
          interval: spriteSpec.interval,
          portion: portion,
          flip: flip));
    }

    return Sprite(spec.interval, frames, spec.size, spec.anchor);
  }
}
