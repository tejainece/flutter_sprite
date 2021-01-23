import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/sprite.dart';

typedef SpriteWidgetReady = void Function(SpriteController controller);

class SpriteWidget extends StatefulWidget {
  final Sprite sprite;

  final bool play;

  final bool loop;

  final SpriteWidgetReady onReady;

  SpriteWidget(this.sprite,
      {this.play = true, this.loop = true, this.onReady, Key key})
      : super(key: key);

  @override
  _SpriteWidgetState createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  SpriteController spriteController;

  Timer _timer;

  int _index = 0;

  final _cache = <int, Widget>{};

  bool loop = true;

  @override
  void initState() {
    super.initState();

    spriteController = SpriteController(this);
    if (widget.onReady != null) {
      widget.onReady(spriteController);
    }
    
    loop = widget.loop;

    if (widget.play) {
      play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sprite;

    if (sheet.frames.isEmpty) {
      return Container();
    }

    Widget image = _cache[_index];
    if (image == null) {
      final sprite = sheet.frames[_index];
      final offset = sheet.anchor - sprite.anchor;
      image = Positioned(
        child: Image(image: sprite.image),
        left: offset.x,
        top: offset.y,
      );
      _cache[_index] = image;
    }

    return Container(
      width: sheet.size.x,
      height: sheet.size.y,
      child: Stack(
        children: [
          image,
        ],
      ),
    );
  }

  Duration _getNextDuration() {
    final frameInterval = widget.sprite.frames[_index].interval;
    if (frameInterval != null) {
      return frameInterval;
    } else {
      return widget.sprite.interval;
    }
  }

  void _pause() {
    // TODO keep track of elapsed duration?
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = null;
  }

  void _start() {
    if (_index == widget.sprite.frames.length - 1) {
      setState(() {
        _index = 0;
      });
    }
    Duration duration = _getNextDuration();
    _timer = Timer(duration, _next);
  }

  void _next() {
    _timer = null;
    if (loop || _index < widget.sprite.frames.length - 1) {
      setState(() {
        _index++;
        _index = _index % widget.sprite.frames.length;
      });
      _timer = Timer(_getNextDuration(), _next);
    }
  }

  void play() {
    if (_timer != null) {
      return;
    }

    _start();
  }

  void pause() {
    _pause();
  }

  @override
  void dispose() {
    _pause();
    super.dispose();
  }
}

class SpriteController {
  final _SpriteWidgetState _state;

  SpriteController(this._state);

  void play() => _state.play();

  void pause() => _state.pause();

  bool get loop => _state.loop;

  set loop(bool value) => _state.loop = value;
}
