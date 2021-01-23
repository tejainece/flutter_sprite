import 'dart:convert';
import 'dart:math';

import 'package:flutter_sprite/src/format.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SpriteFrame {
  final ImageProvider image;

  final Point<num> anchor;

  SpriteFrame(this.image, {Point<num> anchor})
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

    for (final spriteSpec in spec.sprites) {
      final path = p.join(dir, spriteSpec.uri);

      ImageProvider image;
      if (spriteSpec.portion == null) {
        image = AssetImage(path);
      } else {
        final bytes = rootBundle.load(path);
        // TODO
      }
      frames.add(SpriteFrame(image, anchor: spriteSpec.anchor));
    }

    return Sprite(spec.interval, frames, spec.size, spec.anchor);
  }
}
