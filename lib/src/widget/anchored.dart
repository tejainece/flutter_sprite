import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/model/sprite.dart';

class Anchored extends StatelessWidget {
  final Size? size;

  final double? scale;

  final Offset anchor;

  final Sprite sprite;

  final Widget child;

  final bool left;

  final bool top;

  const Anchored(this.sprite,
      {this.size,
      this.scale,
      required this.anchor,
      required this.child,
      this.left = true,
      this.top = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size?.width,
      height: size?.height,
      left: left ? (anchor.dx - sprite.anchor.dx * (scale ?? 1)) : null,
      right: left
          ? null
          : (anchor.dx - (sprite.size.width - sprite.anchor.dx) * (scale ?? 1)),
      top: top ? (anchor.dy - sprite.anchor.dy * (scale ?? 1)) : null,
      bottom: top
          ? null
          : (anchor.dy -
              (sprite.size.height - sprite.anchor.dy) * (scale ?? 1)),
      child: child,
    );
  }
}
