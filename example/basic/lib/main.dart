import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_sprite/flutter_sprite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sprite1 = await Sprite.load('asset/swords_man/sprite.json');
  final mirror = await Sprite.load('asset/mirrored/sprite.json');
  final sprite2 = await Sprite.load('asset/spritesheet/sheet.json');
  final mangoTree = await Sprite.load('asset/mangotree/sheet.json');
  final turkey = await Sprite.load('asset/turkey/sheet.json');

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        children: [
          Container(color: Colors.blue, child: SpriteWidget(sprite2)),
          Container(color: Colors.blue, child: SpriteWidget(mirror)),
          Container(color: Colors.blue, child: SpriteWidget(sprite1)),
          SpriteWidget(sprite2, onReady: (controller) {
            Timer(const Duration(seconds: 10), () {
              controller.pause();

              Timer(const Duration(seconds: 10), () {
                controller.play();
              });
            });
          }),
          Container(color: Colors.blue, child: SpriteWidget(mangoTree)),
          Container(color: Colors.blue, child: SpriteWidget(turkey)),
          Container(
              color: Colors.blue,
              child: SpriteWidget(
                turkey,
                loop: false,
                onFinish: () {
                  debugPrint('finished!');
                },
              )),
        ],
      ),
    ),
  );
}
