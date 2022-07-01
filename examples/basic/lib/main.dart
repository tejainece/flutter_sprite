import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_sprite/flutter_sprite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sprite1 = await Sprite.load('asset/swords_man/sprite.json');
  final sprite2 = await Sprite.load('asset/spritesheet/sheet.json');
  final mangoTree = await Sprite.load('asset/mangotree/sheet.json');
  final turkey = await Sprite.load('asset/turkey/sheet.json');

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        children: [
          Container(child: SpriteWidget(sprite2), color: Colors.blue),
          Container(child: SpriteWidget(sprite1), color: Colors.blue),
          SpriteWidget(sprite2, onReady: (controller) {
            Timer(Duration(seconds: 10), () {
              controller.pause();

              Timer(Duration(seconds: 10), () {
                controller.play();
              });
            });
          }),
          Container(child: SpriteWidget(mangoTree), color: Colors.blue),
          Container(child: SpriteWidget(turkey), color: Colors.blue),
        ],
      ),
    ),
  );
}
