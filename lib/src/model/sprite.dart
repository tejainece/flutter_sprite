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

  SpriteFrame(
    this.image, {
    required this.translate,
    this.interval,
    ImagePortion? portion,
  }) : portion = portion ??
            ImagePortion(Point(0, 0), Point(image.width, image.height));

  Rectangle<num> get rectangle => portion.rectangle;
}

class Sprite {
  final Duration interval;

  final Point<num> size;

  final Point<num> anchor;

  final List<SpriteFrame> frames;

  final int? refScale;

  final bool flip;

  Sprite(
      {required this.interval,
      required this.frames,
      required this.size,
      required this.anchor,
      this.refScale,
      this.flip = false});

  static Future<Sprite> load(String specPath) async {
    final jsonStr = await rootBundle.loadString(specPath, cache: false);
    final json = jsonDecode(jsonStr);
    final spec = SpriteSpec.fromJson(json)!;
    final dir = p.dirname(specPath);
    final frames = <SpriteFrame>[];
    final cache = <String, ui.Image>{};

    Point<num> anchor = spec.anchor;
    if (spec.flip) {
      anchor = Point(spec.size.x - spec.anchor.x, spec.anchor.y);
    }

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

      // Point<num> frameAnchor = spec.anchor - (spec.anchor - frameSpec.anchor);
      Point<num> translate = Point<num>(0, 0);
      if (frameSpec.anchor != null) {
        translate = spec.anchor - frameSpec.anchor!;
        if (spec.flip) {
          translate = Point(-translate.x, translate.y);
        }
      }

      frames.add(SpriteFrame(image,
          translate: translate,
          interval: frameSpec.interval,
          portion: portion));
    }

    return Sprite(
        interval: spec.interval,
        frames: frames,
        size: spec.size,
        anchor: anchor,
        refScale: spec.refScale,
        flip: spec.flip);
  }
}
