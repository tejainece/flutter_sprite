import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/sprite.dart';

class Anchored extends StatelessWidget {
  final Size? size;

  final Offset anchor;

  final Sprite sprite;

  final Widget child;

  const Anchored(this.sprite,
      {this.size, required this.anchor, required this.child, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size?.width,
      height: size?.height,
      left: anchor.dx - sprite.anchor.x,
      top: anchor.dy - sprite.anchor.y,
      child: child,
    );
  }
}
