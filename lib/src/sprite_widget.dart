import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/sprite.dart';

typedef SpriteWidgetReady = void Function(SpriteController controller);

class SpriteWidget extends StatefulWidget {
  final Sprite sprite;

  final SpriteWidgetReady onReady;

  SpriteWidget(this.sprite, {this.onReady, Key key}) : super(key: key);

  @override
  _SpriteWidgetState createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  SpriteController spriteController;

  AnimationController _animController;

  @override
  void initState() {
    super.initState();

    spriteController = SpriteController(this);
    if (widget.onReady != null) {
      widget.onReady(spriteController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  bool _shouldPlay = true;

  void play() {
    if (_shouldPlay) {
      return;
    }
    _shouldPlay = true;
    _animController.forward();
  }

  void pause() {
    if (!_shouldPlay) {
      return;
    }
    _shouldPlay = false;
    _animController.stop();
  }
}

class SpriteController {
  final _SpriteWidgetState _state;

  SpriteController(this._state);

  void play() => _state.play();

  void pause() => _state.pause();
}
