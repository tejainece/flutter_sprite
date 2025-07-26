import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_sprite/flutter_sprite.dart';
import 'package:path/path.dart' as p;

class SpriteFrame {
  final ui.Image image;

  final ImagePortion portion;

  final Offset anchor;

  final Offset translate;

  final Duration? interval;

  SpriteFrame(
    this.image, {
    required this.anchor,
    required this.translate,
    this.interval,
    ImagePortion? portion,
  }) : portion = portion ??
            ImagePortion(Point(0, 0), Point(image.width, image.height));

  Rectangle<num> get rectangle => portion.rectangle;

  Offset calcOffset(Sprite sprite, Offset offset, Offset worldAnchor,
      double scale, Size size) {
    if (sprite.flip) {
      worldAnchor = Offset(size.width - worldAnchor.dx, worldAnchor.dy);
    }

    Offset o = offset + worldAnchor - sprite.anchor * scale + translate * scale;
    return o;
  }

  ui.Rect calcRect(Sprite sprite, Offset offset, Offset worldAnchor,
      double scale, Size size) {
    return calcOffset(sprite, offset, worldAnchor, scale, size) &
        portion.size.s * scale;
  }
}

class Sprite {
  final Duration interval;

  final Size size;

  final Offset anchor;

  final List<SpriteFrame> frames;

  final int? refScale;

  final bool flip;

  final Map<String, dynamic> data;

  Sprite(
      {required this.interval,
      required this.frames,
      required this.size,
      required this.anchor,
      this.refScale,
      this.flip = false,
      required this.data});

  late final Duration duration =
      frames.fold(Duration(), (p, e) => p + (e.interval ?? interval));

  Offset calcPoint(
      {required Offset offset,
      required Offset worldAnchor,
      required double scale,
      required Size size,
      required Offset point}) {
    // point = anchor - point;
    if (flip) {
      worldAnchor = Offset(size.width - worldAnchor.dx, worldAnchor.dy);
      point = this.size.o - point;
    }

    Offset o = offset + worldAnchor - anchor * scale + point * scale;
    return o;
  }

  static Future<Sprite> load(String specPath, {SpriteLoader? loader}) async {
    loader ??= AssetSpriteLoader();
    final jsonStr = await loader.loadString(specPath);
    final json = jsonDecode(jsonStr);
    final spec = SpriteSpec.fromJson(json)!;
    final dir = p.dirname(specPath);
    final frames = <SpriteFrame>[];
    final cache = <String, ui.Image>{};

    Offset anchor = spec.anchor;
    if (spec.flip) {
      anchor = Offset(spec.size.width - spec.anchor.dx, spec.anchor.dy);
    }

    for (final frameSpec in spec.frames) {
      final path = '$dir/${frameSpec.uri}';

      ui.Image image;
      if (!cache.containsKey(path)) {
        image = await loader.loadImage(path);
        cache[path] = image;
      } else {
        image = cache[path]!;
      }
      final portion = frameSpec.portion ??
          ImagePortion(Point(0, 0), Point(image.width, image.height));

      Offset translate = Offset(0, 0);
      if (frameSpec.anchor != null) {
        translate = anchor - frameSpec.anchor!.o;
      }

      frames.add(SpriteFrame(image,
          translate: translate,
          anchor: frameSpec.anchor?.o ?? spec.anchor,
          interval: frameSpec.interval,
          portion: portion));
    }

    return Sprite(
      interval: spec.interval,
      frames: frames,
      size: spec.size,
      anchor: anchor,
      refScale: spec.refScale,
      flip: spec.flip,
      data: spec.data,
    );
  }
}

mixin SpriteLoader {
  Future<List<int>> loadBytes(String path);

  Future<String> loadString(String path, {Encoding decoder = utf8}) async {
    final bytes = await loadBytes(path);
    return utf8.decoder.convert(bytes);
  }

  Future<ui.Image> loadImage(String path) async {
    final codec = await ui
        .instantiateImageCodec(Uint8List.fromList(await loadBytes(path)));
    return (await codec.getNextFrame()).image;
  }

  Future<Sprite> loadSprite(String specPath) async =>
      await Sprite.load(specPath, loader: this);
}

class AssetSpriteLoader with SpriteLoader {
  const AssetSpriteLoader();

  @override
  Future<List<int>> loadBytes(String path) async =>
      (await rootBundle.load(path)).buffer.asUint8List();
}
