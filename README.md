# flutter_sprite

## Usage

### Spritesheet

Spritesheet can be loaded from the flutter assets. Make sure you put the spritesheet json spec and the images in the
assets directory.

### Loading the sprite

Use `Sprite.load` to load a sprite from the flutter assets.

```dart
Future<void> loadSprite() async {
  Sprite sprite = await Sprite.load('asset/swords_man/sprite.json');
}
```

### Displaying and animating the sprite

```dart
Widget build(BuildContext context) async {
  return SpriteWidget(sprite);
}
```

### Control the animation

The sprite playback can be paused and restarted at any time using `SpriteController`. `SpriteController` is obtained
using `onReady` callback.

```dart
Widget build(BuildContext context) async {
  return SpriteWidget(sprite, onReady: (controller) {
    Timer(Duration(seconds: 10), () {
      controller.pause();

      Timer(Duration(seconds: 10), () {
        controller.play();
      });
    });
  });
}
```

## TODO

+ [ ] Play from specific point
+ [ ] Animation controls to debug animations