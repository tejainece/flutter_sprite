import 'package:flutter/material.dart';

import 'package:flutter_sprite/flutter_sprite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sprite2 = await Sprite.loadFromAsset('asset/mirrored/sprite.json');

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        children: [
          Container(color: Colors.blue, child: SpriteWidget(sprite2, scale: 1)),
          SizedBox.fromSize(size: const Size(10, 10)),
          Container(
              color: Colors.blue, child: SpriteWidget(sprite2, scale: 2.0)),
          SizedBox.fromSize(size: const Size(10, 10)),
          Container(
              color: Colors.blue, child: SpriteWidget(sprite2, scale: 0.5)),
        ],
      ),
    ),
  );
}
