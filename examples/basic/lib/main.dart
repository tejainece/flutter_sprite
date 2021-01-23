import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_sprite/flutter_sprite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sprite1 = await Sprite.load('asset/swords_man/sprite.json');
  final sprite2 = await Sprite.load('asset/spritesheet/sheet.json');

  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        children: [
          SpriteWidget(sprite1, onReady: (controller) {
            Timer(Duration(seconds: 10), () {
              controller.pause();

              Timer(Duration(seconds: 10), () {
                controller.play();
              });
            });
          }),
          SpriteWidget(sprite2, onReady: (controller) {
            Timer(Duration(seconds: 10), () {
              controller.pause();

              Timer(Duration(seconds: 10), () {
                controller.play();
              });
            });
          }),
        ],
      ),
    ),
  );
}
