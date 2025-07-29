import 'dart:math';
import 'dart:ui';
import 'package:flutter_sprite/flutter_sprite.dart';

sealed class ISpriteFrameSpec {
  List<SpriteFrameSpec> get frames;

  Map<String, dynamic> toJson();

  static ISpriteFrameSpec? fromJson(Map? map) {
    if (map == null) return null;
    switch (map['type']) {
      case 'grid':
        return SpriteFrameGridSpec.fromJson(map);
      case null || 'single':
        return SpriteFrameSpec.fromJson(map);
      default:
        throw Exception('invalid sprite frame type: ${map['type']}');
    }
  }
}

class SpriteFrameGridSpec implements ISpriteFrameSpec {
  final String uri;
  final int rows;
  final int columns;
  final Point<int> gridOffset;
  final Point<int> size;
  final Point<int>? anchor;
  final Duration? interval;

  SpriteFrameGridSpec(
    this.uri, {
    required this.rows,
    required this.columns,
    required this.gridOffset,
    required this.size,
    required this.anchor,
    required this.interval,
  });

  @override
  late final List<SpriteFrameSpec> frames = () {
    final frames = <SpriteFrameSpec>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        frames.add(
          SpriteFrameSpec(
            uri,
            anchor: anchor,
            interval: interval,
            portion: ImagePortion(
              gridOffset + Point(c * size.x, r * size.y),
              size,
            ),
          ),
        );
      }
    }
    return frames;
  }();

  @override
  Map<String, dynamic> toJson() => {
    'type': 'grid',
    'uri': uri,
    'rows': rows,
    'cols': columns,
    'gridOffset': ?(gridOffset == Point<int>(0, 0)
        ? null
        : gridOffset.toJson()),
    'size': size.toJson(),
    'anchor': ?anchor?.toJson(),
    'interval': ?interval?.inMilliseconds,
  };

  static SpriteFrameGridSpec? fromJson(Map? map) {
    if (map == null) return null;
    return SpriteFrameGridSpec(
      map['uri'],
      rows: map['rows'],
      columns: map['cols'],
      gridOffset:
          PointIntExt.fromNullJson(map['gridOffset']) ?? Point<int>(0, 0),
      size: PointIntExt.fromJson(map['size']),
      anchor: PointIntExt.fromNullJson(map['anchor']),
      interval: map['interval'] != null
          ? Duration(milliseconds: map['interval'])
          : null,
    );
  }
}

class SpriteFrameSpec implements ISpriteFrameSpec {
  final String uri;

  final Point<int>? anchor;

  final ImagePortion? portion;

  final Duration? interval;

  SpriteFrameSpec(
    this.uri, {
    required this.anchor,
    this.portion,
    this.interval,
  });

  @override
  late final List<SpriteFrameSpec> frames = [this];

  @override
  Map<String, dynamic> toJson() => {
    'type': 'single',
    'uri': uri,
    'anchor': ?anchor?.toJson(),
    'portion': ?portion?.toJson(),
    'interval': ?interval?.inMilliseconds,
  };

  static SpriteFrameSpec? fromJson(Map? map) {
    if (map == null) return null;
    return SpriteFrameSpec(
      map['uri'],
      anchor: PointIntExt.fromNullJson(map['anchor']),
      portion: ImagePortion.fromNullJson(map['portion']),
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

  final List<ISpriteFrameSpec> framePtr;

  final bool flip;

  final int? refScale;

  final Map<String, dynamic> data;

  SpriteSpec({
    required this.framePtr,
    required this.interval,
    required this.size,
    Offset? anchor,
    required this.flip,
    this.refScale,
    required this.data,
  }) : anchor = anchor ?? Offset(0, 0);

  Iterable<SpriteFrameSpec> get frames sync* {
    for (final frame in framePtr) {
      yield* frame.frames;
    }
  }

  Map<String, dynamic> toJson() => {
    'interval': interval.inMilliseconds,
    'frames': framePtr.map((e) => e.toJson()).toList(),
    'size': size.toJson(),
    if (anchor != Offset(0, 0)) 'anchor': anchor.toJson(),
    if (flip) 'flip': flip,
    if (refScale != null) 'refScale': refScale,
    if (data.isNotEmpty) 'data': data,
  };

  static SpriteSpec? fromJson(Map? map) {
    if (map == null) return null;

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

    final anchor = OffsetExt.fromNullJson(map['anchor']);

    return SpriteSpec(
      interval: Duration(milliseconds: map['interval']),
      size: SizeExt.fromNullJson(map['size'])!,
      anchor: anchor,
      flip: map['flip'] ?? false,
      refScale: map['refScale'],
      data: map['data'] ?? {},
      framePtr: (map['frames'] as List)
          .cast<Map>()
          .map((e) => ISpriteFrameSpec.fromJson(e)!)
          .toList(),
    );
  }
}

class ImagePortion {
  final Point<num> offset;

  final Point<num> size;

  ImagePortion(this.offset, this.size);

  Map<String, dynamic> toJson() => {
    'offset': offset.toJson(),
    'size': size.toJson(),
  };

  @override
  bool operator ==(other) {
    if (other is ImagePortion) {
      return offset == other.offset && size == other.size;
    }
    return false;
  }

  Rectangle<num> get rectangle =>
      Rectangle<num>(offset.x, offset.y, size.x, size.y);

  @override
  int get hashCode => Object.hash(offset.x, offset.y, size.x, size.y);

  static ImagePortion? fromNullJson(Map? m) {
    if (m == null) return null;
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
      PointExt.fromNullJson(m['offset'])!,
      PointExt.fromNullJson(m['size'])!,
    );
  }
}
