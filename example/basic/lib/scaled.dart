import 'package:flutter/material.dart';

import 'package:flutter_sprite/flutter_sprite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sprite2 = await Sprite.loadFromAsset('asset/swords_man/sprite.json');

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        children: [
          Container(child: SpriteWidget(sprite2), color: Colors.blue),
          SizedBox.fromSize(size: Size(10, 10)),
          Container(
              child: SpriteWidget(sprite2, scale: 2.0), color: Colors.blue),
          SizedBox.fromSize(size: Size(10, 10)),
          Container(
              child: SpriteWidget(sprite2, scale: 0.5), color: Colors.blue),
        ],
      ),
    ),
  );
}
