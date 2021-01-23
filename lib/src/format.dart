import 'dart:math';

class SpriteSheetPortion {
  final Point<num> offset;

  final Point<num> size;

  SpriteSheetPortion(this.offset, this.size);

  Map<String, dynamic> toJson() => {
        'offset': offset.toJson(),
        'size': size.toJson(),
      };

  static SpriteSheetPortion fromJson(Map m) {
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
    return SpriteSheetPortion(
        _PointExt.fromJson(m['offset']), _PointExt.fromJson(m['size']));
  }
}

class SpriteSheetSprite {
  final String uri;

  final Point<num> anchor;

  final SpriteSheetPortion portion;

  final Duration interval;

  SpriteSheetSprite(this.uri, {Point<num> anchor, this.portion, this.interval})
      : anchor = anchor ?? Point<num>(0, 0);

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      if (anchor != null) 'anchor': anchor.toJson(),
      if (portion != null) 'portion': portion.toJson(),
      if (interval != null) 'interval': interval.inMilliseconds,
    };
  }

  static SpriteSheetSprite fromJson(Map map, {Point<num> defaultAnchor}) {
    if (map == null) {
      return null;
    }
    return SpriteSheetSprite(
      map['uri'],
      anchor: _PointExt.fromJson(map['anchor']) ?? defaultAnchor,
      portion: SpriteSheetPortion.fromJson(map['portion']),
    );
  }
}

class SpriteSheetSpec {
  final Duration interval;

  final Point<num> size;

  final Point<num> anchor;

  final List<SpriteSheetSprite> sprites;

  SpriteSheetSpec(this.sprites, this.interval, this.size, Point<num> anchor)
      : anchor = anchor ?? Point(0, 0);

  Map<String, dynamic> toJson() => {
        'interval': interval.inMilliseconds,
        'sprites': sprites.map((e) => e.toJson()).toList(),
      };

  static SpriteSheetSpec fromJson(Map map) {
    if (map == null) {
      return null;
    }

    // Validate sprites
    if (map['sprites'] == null) {
      throw Exception('sprites is mandatory');
    } else if (map['sprites'] is! List) {
      throw Exception('sprites should be a list');
    }

    // Validate interval
    if (map['interval'] == null) {
      throw Exception('interval is mandatory');
    } else if (map['interval'] is! int) {
      throw Exception('interval should be milliseconds');
    } else if ((map['interval'] as int) <= 0) {
      throw Exception('interval should be positive integer');
    }

    // TODO Validate size

    final anchor = _PointExt.fromJson(map['anchor']) ?? Point<num>(0, 0);

    return SpriteSheetSpec(
        (map['sprites'] as List)
            .cast<Map>()
            .map((e) => SpriteSheetSprite.fromJson(e, defaultAnchor: anchor))
            .toList(),
        Duration(milliseconds: map['interval']),
        _PointExt.fromJson(map['size']),
        anchor);
  }
}

extension _PointExt on Point<num> {
  String toJson() => '$x:$y';

  static Point<num> fromJson(String str) {
    if (str == null) {
      return null;
    }

    final parts = str.split(':').map(num.tryParse).toList();
    if (parts.length != 2) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    } else if (parts.any((element) => element == null)) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    }

    return Point<num>(parts[0], parts[1]);
  }
}
