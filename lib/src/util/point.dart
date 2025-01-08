import 'dart:math';
import 'dart:ui';

extension PointExt on Point<num> {
  Point<int> get toInt => Point(x.toInt(), y.toInt());

  Point<double> get toDouble => Point(x.toDouble(), y.toDouble());

  Size get s => Size(x.toDouble(), y.toDouble());

  Offset get o => Offset(x.toDouble(), y.toDouble());

  Radius get r => Radius.elliptical(x.toDouble(), y.toDouble());

  Point<double> operator /(other) {
    if (other == null) {
      throw ArgumentError.notNull('other');
    }

    if (other is Point) {
      return Point<double>(x / other.x, y / other.y);
    } else if (other is num) {
      return Point<double>(x / other, y / other);
    }

    throw ArgumentError.value(
        other, 'other', 'cannot divide a point with ${other.runtimeType}');
  }

  String toJson() => '$x:$y';

  static Point<num>? fromJson(String? str) {
    if (str == null) return null;

    final parts = str.split(':').map(num.tryParse).toList();
    if (parts.length != 2) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    } else if (parts.any((element) => element == null)) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    }

    return Point<num>(parts[0]!, parts[1]!);
  }
}

extension SizeExt on Size {
  Size operator /(num other) => Size(width / 2, height / 2);

  Point<double> get p => Point<double>(width, height);

  Offset get o => Offset(width, height);

  Size sub(other) {
    if (other is num) {
      return Size(width - other, height - other);
    } else if (other is Size) {
      return Size(width - other.width, height - other.height);
    } else if (other is Offset) {
      return Size(width - other.dx, height - other.dy);
    } else {
      throw ArgumentError.value(
          other, 'other', 'cannot subtract a size with ${other.runtimeType}');
    }
  }

  Size multiply(num other) => Size(width * other, height * other);

  Size divide(num other) => Size(width / other, height / other);

  String toJson() => '$width:$height';

  static Size? fromJson(String? str) {
    if (str == null) return null;

    final parts = str.split(':').map(double.tryParse).toList();
    if (parts.length != 2) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    } else if (parts.any((element) => element == null)) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    }

    return Size(parts[0]!, parts[1]!);
  }
}

extension OffsetExt on Offset {
  static Offset parse(String s) {
    final parts = s.split(':');
    if (parts.length != 2) {
      throw ArgumentError.value(s, 's', 'invalid offset');
    }
    return Offset(double.parse(parts[0]), double.parse(parts[1]));
  }

  Point<double> get p => Point<double>(dx, dy);

  Offset mul(other) {
    if (other is num) {
      return Offset(dx * other, dy * other);
    } else if (other is Offset) {
      return Offset(dx * other.dx, dy * other.dy);
    } else if (other is Size) {
      return Offset(dx * other.width, dy * other.height);
    } else {
      throw ArgumentError.value(other, 'other',
          'cannot multiply an offset with ${other.runtimeType}');
    }
  }

  String toJson() => '$dx:$dy';

  static Offset? fromJson(String? str) {
    if (str == null) return null;

    final parts = str.split(':').map(double.tryParse).toList();
    if (parts.length != 2) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    } else if (parts.any((element) => element == null)) {
      throw ArgumentError.value(str, 'v', 'invalid JSON Point format');
    }

    return Offset(parts[0]!, parts[1]!);
  }
}

extension RectangleExt on Rectangle<num> {
  Iterable<Point<int>> get positions sync* {
    for (int x = left.toInt(); x <= right; x++) {
      for (int y = top.toInt(); y <= bottom; y++) {
        yield Point<int>(x, y);
      }
    }
  }

  Rect get rect => Rect.fromLTWH(
      left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());
}
