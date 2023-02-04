import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/model/sprite.dart';

class Anchored extends StatelessWidget {
  final Size? size;

  final Offset anchor;

  final Sprite sprite;

  final Widget child;

  final bool left;

  final bool top;

  const Anchored(this.sprite,
      {this.size,
      required this.anchor,
      required this.child,
      this.left = true,
      this.top = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size?.width,
      height: size?.height,
      left: left ? anchor.dx - sprite.anchor.x : null,
      right: left ? null : anchor.dx - (sprite.size.x - sprite.anchor.x),
      top: top ? anchor.dy - sprite.anchor.y : null,
      bottom: top ? null : anchor.dy - (sprite.size.y - sprite.anchor.y),
      child: child,
    );
  }
}
