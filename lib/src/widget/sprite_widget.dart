import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_sprite/src/widget/image_clipper.dart';
import 'package:flutter_sprite/src/model/sprite.dart';

typedef SpriteWidgetReady = void Function(SpriteController controller);

class SpriteWidget extends StatefulWidget {
  final Sprite sprite;

  final double? scale;

  final double? width;

  final bool play;

  final bool loop;

  final SpriteWidgetReady? onReady;

  final VoidCallback? onFinish;

  final bool syncAnimationOnSpriteChange;

  SpriteWidget(this.sprite,
      {this.play = true,
      this.scale,
      this.width,
      this.loop = true,
      this.onReady,
      this.onFinish,
      this.syncAnimationOnSpriteChange = true,
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

  double get scale {
    if (widget.scale != null) return widget.scale!;
    if (widget.width != null) return widget.width! / sprite.size.width;
    return 1;
  }

  Sprite get sprite => widget.sprite;

  @override
  void initState() {
    super.initState();

    spriteController = SpriteController(this);
    widget.onReady?.call(spriteController);
    spriteController._sizeChangeController.add(Size(width, height));

    loop = widget.loop;

    if (widget.play) {
      play();
    }
  }

  @override
  void didUpdateWidget(SpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool sizeChanged = widget.scale != oldWidget.scale ||
        widget.sprite != oldWidget.sprite ||
        widget.width != oldWidget.width;
    if (widget.sprite != sprite) {
      if (!widget.syncAnimationOnSpriteChange ||
          _index >= sprite.frames.length) {
        _index = 0;
      }
    }

    if (sizeChanged) {
      spriteController._sizeChangeController.add(Size(width, height));
    }
  }

  double get width => sprite.size.width.toDouble() * scale;

  double get height => sprite.size.height.toDouble() * scale;

  @override
  Widget build(BuildContext context) {
    double width = this.width;
    double height = this.height;

    if (sprite.frames.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
      );
    }

    final frame = sprite.frames[_index];
    Widget child = ClippedImage(
        image: frame.image, portion: frame.portion, size: Size(width, height));

    if (sprite.flip) {
      child = Transform(
        transform: Matrix4.identity()..rotateY(pi),
        child: child,
      );
    }

    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned(
              /* TODO left: frame.anchor.x.toDouble() * (scale ?? 1),
            top: frame.anchor.y.toDouble() * (scale ?? 1),*/
              child: child,
            ),
            SizedBox(width: width, height: height),
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
    spriteController.dispose();
    super.dispose();
  }
}

class SpriteController {
  final _SpriteWidgetState _state;

  final _sizeChangeController = StreamController<Size>.broadcast();

  SpriteController(this._state);

  Stream<Size> get onSizeChange => _sizeChangeController.stream;

  Sprite get sprite => _state.sprite;

  void play() => _state.play();

  void pause() => _state.pause();

  bool get loop => _state.loop;

  set loop(bool value) => _state.loop = value;

  Size get size => Size(_state.width, _state.height);

  void dispose() {
    _sizeChangeController.close();
  }
}
