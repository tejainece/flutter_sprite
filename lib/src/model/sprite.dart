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

  final Point<num> anchor;

  final Duration? interval;

  final bool flip;

  SpriteFrame(this.image,
      {this.anchor = const Point<num>(0, 0),
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

  final int? refScale;

  Sprite(
      {required this.interval,
      required this.frames,
      required this.size,
      required this.anchor,
      this.refScale});

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


        Point<num> frameAnchor = frameSpec.anchor ?? Point(0, 0);
        if (flip) {
          frameAnchor = Point(spec.size.x - (spec.anchor.x - frameAnchor.x),
              spec.anchor.y - frameAnchor.y);
        } else {
          frameAnchor = spec.anchor - frameAnchor;
        }

      frames.add(SpriteFrame(image,
          anchor: frameAnchor,
          interval: frameSpec.interval,
          portion: portion,
          flip: flip));
    }

    return Sprite(
        interval: spec.interval,
        frames: frames,
        size: spec.size,
        anchor: spec.anchor,
        refScale: spec.refScale);
  }
}
