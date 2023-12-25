import 'dart:math';
import 'dart:ui';
import 'package:flutter_sprite/flutter_sprite.dart';

class ImagePortion {
  final Point<num> offset;

  final Point<num> size;

  ImagePortion(this.offset, this.size);

  Map<String, dynamic> toJson() => {
        'offset': offset.toJson(),
        'size': size.toJson(),
      };

  bool operator ==(other) {
    if (other is ImagePortion) {
      return offset == other.offset && size == other.size;
    }
    return false;
  }

  Rectangle<num> get rectangle => Rectangle<num>.fromPoints(offset, size);

  @override
  int get hashCode => Object.hash(offset.x, offset.y, size.x, size.y);

  static ImagePortion? fromJson(Map? m) {
    if (m == null) {
      return null;
    }

    if (m['offset'] == null) {
      throw Exception('offset is mandatory');
    } else if (m['offset'] is! String) {
      throw Exception('invalid offset');
    }
    if (m['size'] == null) {
      throw Exception('size is mandatory');
    } else if (m['size'] is! String) {
      throw Exception('invalid size');
    }
    return ImagePortion(
        PointExt.fromJson(m['offset'])!, PointExt.fromJson(m['size'])!);
  }
}

class SpriteFrameSpec {
  final String uri;

  final Offset? anchor;

  final ImagePortion? portion;

  final Duration? interval;

  SpriteFrameSpec(this.uri,
      {required this.anchor, this.portion, this.interval});

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      if (anchor != null) 'anchor': anchor!.toJson(),
      if (portion != null) 'portion': portion!.toJson(),
      if (interval != null) 'interval': interval!.inMilliseconds,
    };
  }

  static SpriteFrameSpec? fromJson(Map? map) {
    if (map == null) {
      return null;
    }
    return SpriteFrameSpec(
      map['uri'],
      anchor: OffsetExt.fromJson(map['anchor']),
      portion: ImagePortion.fromJson(map['portion']),
      interval: map['interval'] != null
          ? Duration(milliseconds: map['interval'])
          : null,
    );
  }
}

class SpriteSpec {
  final Duration interval;

  final Size size;

  final Offset anchor;

  final List<SpriteFrameSpec> frames;

  final bool flip;

  final int? refScale;

  final Map<String, dynamic> data;

  SpriteSpec(
      {required this.frames,
      required this.interval,
      required this.size,
      Offset? anchor,
      required this.flip,
      this.refScale,
      required this.data})
      : anchor = anchor ?? Offset(0, 0);

  Map<String, dynamic> toJson() => {
        'interval': interval.inMilliseconds,
        'frames': frames.map((e) => e.toJson()).toList(),
        'size': size.toJson(),
        if (anchor != Point<num>(0, 0)) 'anchor': anchor.toJson(),
        if (flip) 'flip': flip,
        if (refScale != null) 'refScale': refScale,
        if (data.isNotEmpty) 'data': data,
      };

  static SpriteSpec? fromJson(Map? map) {
    if (map == null) {
      return null;
    }

    // Validate sprites
    if (map['frames'] == null) {
      throw Exception('frames is mandatory');
    } else if (map['frames'] is! List) {
      throw Exception('frames should be a list');
    }

    // Validate interval
    if (map['interval'] == null) {
      throw Exception('interval is mandatory');
    } else if (map['interval'] is! int) {
      throw Exception('interval should be milliseconds');
    } else if ((map['interval'] as int) <= 0) {
      throw Exception('interval should be positive integer');
    }

    if (map['size'] == null || map['size'] is! String) {
      throw Exception('missing or invalid size property on sprite sheet');
    }

    final anchor = OffsetExt.fromJson(map['anchor']);

    return SpriteSpec(
      interval: Duration(milliseconds: map['interval']),
      size: SizeExt.fromJson(map['size'])!,
      anchor: anchor,
      flip: map['flip'] ?? false,
      refScale: map['refScale'],
      data: map['data'] ?? {},
      frames: (map['frames'] as List)
          .cast<Map>()
          .map((e) => SpriteFrameSpec.fromJson(e)!)
          .toList(),
    );
  }
}
