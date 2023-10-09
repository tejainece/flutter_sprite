import 'dart:math';

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
        _PointExt.fromJson(m['offset'])!, _PointExt.fromJson(m['size'])!);
  }
}

class SpriteFrameSpec {
  final String uri;

  final Point<num>? anchor;

  final ImagePortion? portion;

  final Duration? interval;

  final bool? flip;

  SpriteFrameSpec(this.uri,
      {this.anchor, this.portion, this.interval, this.flip});

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      if (anchor != null) 'anchor': anchor!.toJson(),
      if (portion != null) 'portion': portion!.toJson(),
      if (interval != null) 'interval': interval!.inMilliseconds,
      if (flip != null) 'flip': flip,
    };
  }

  static SpriteFrameSpec? fromJson(Map? map) {
    if (map == null) {
      return null;
    }
    return SpriteFrameSpec(
      map['uri'],
      anchor: _PointExt.fromJson(map['anchor']),
      portion: ImagePortion.fromJson(map['portion']),
      interval: map['interval'] != null
          ? Duration(milliseconds: map['interval'])
          : null,
      flip: map['flip'],
    );
  }
}

class SpriteSpec {
  final Duration interval;

  final Point<num> size;

  final Point<num> anchor;

  final List<SpriteFrameSpec> frames;

  final bool? flip;

  final int? refScale;

  SpriteSpec(
      {required this.frames,
      required this.interval,
      required this.size,
      Point<num>? anchor,
      this.flip,
      this.refScale})
      : anchor = anchor ?? Point<num>(0, 0);

  Map<String, dynamic> toJson() => {
        'interval': interval.inMilliseconds,
        'frames': frames.map((e) => e.toJson()).toList(),
        'size': size.toJson(),
        if (anchor != Point<num>(0, 0)) 'anchor': anchor.toJson(),
        if (flip != null) 'flip': flip,
        if (refScale != null) 'refScale': refScale,
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

    final anchor = _PointExt.fromJson(map['anchor']);

    return SpriteSpec(
      interval: Duration(milliseconds: map['interval']),
      size: _PointExt.fromJson(map['size'])!,
      anchor: anchor,
      flip: map['flip'],
      refScale: map['refScale'],
      frames: (map['frames'] as List)
          .cast<Map>()
          .map((e) => SpriteFrameSpec.fromJson(e)!)
          .toList(),
    );
  }
}

extension _PointExt on Point<num> {
  String toJson() => '$x:$y';

  static Point<num>? fromJson(String? str) {
    if (str == null) {
      return null;
    }

    final parts = str.split(':').map(num.tryParse).toList();
    if (parts.length != 2) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    } else if (parts.any((element) => element == null)) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    }

    return Point<num>(parts[0]!, parts[1]!);
  }
}
