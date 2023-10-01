import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/widget/image_clipper.dart';
import 'package:flutter_sprite/src/model/sprite.dart';

typedef SpriteWidgetReady = void Function(SpriteController controller);

class SpriteWidget extends StatefulWidget {
  final Sprite sprite;

  final double? scale;

  final bool play;

  final bool loop;

  final SpriteWidgetReady? onReady;

  final VoidCallback? onFinish;

  SpriteWidget(this.sprite,
      {this.play = true,
      this.scale,
      this.loop = true,
      this.onReady,
      this.onFinish,
      Key? key})
      : super(key: key);

  @override
  _SpriteWidgetState createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  late SpriteController spriteController;

  Timer? _timer;

  int _index = 0;

  bool loop = true;

  double? get scale => widget.scale;

  @override
  void initState() {
    super.initState();

    spriteController = SpriteController(this);
    widget.onReady?.call(spriteController);

    loop = widget.loop;

    if (widget.play) {
      play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sprite;

    double width = sheet.size.x.toDouble();
    double height = sheet.size.y.toDouble();

    if (scale != null) {
      width *= scale!;
      height *= scale!;
    }

    if (sheet.frames.isEmpty) {
      return Container(
        width: width,
        height: height,
      );
    }

    final frame = sheet.frames[_index];
    Widget child = ClippedImage(image: frame.image, portion: frame.portion);

    Matrix4? transform;

    if (scale != null) {
      transform = Matrix4.identity().scaled(scale!, scale!, 1);
    }

    if (frame.flip) {
      child = Transform(
        transform: (transform ?? Matrix4.identity())..rotateY(pi),
        child: child,
      );
    } else if (transform != null) {
      child = Transform(
        transform: transform,
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: frame.translate.x.toDouble() * (scale ?? 1),
            top: frame.translate.y.toDouble() * (scale ?? 1),
            child: child,
          ),
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
      _timer!.cancel();
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
    if (_timer == null && widget.onFinish != null) {
      widget.onFinish!();
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
