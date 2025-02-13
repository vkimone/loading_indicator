import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallBeat.
class BallBeat extends StatefulWidget {
  const BallBeat({Key? key}) : super(key: key);

  @override
  _BallBeatState createState() => _BallBeatState();
}

class _BallBeatState extends State<BallBeat> with TickerProviderStateMixin {
  static const _beginTimes = [350, 0, 350];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];
  final List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700)));
      _scaleAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _beginTimes[i])).then((t) {
        _animationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    for (var f in _delayFeatures) {
      f.cancel();
    }
    for (var f in _animationControllers) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      List<Widget> widgets = List.filled(5, Container());
      for (int i = 0; i < 5; i++) {
        if (i.isEven) {
          widgets[i] = Expanded(
            child: FadeTransition(
              opacity: _opacityAnimations[i ~/ 2],
              child: ScaleTransition(
                scale: _scaleAnimations[i ~/ 2],
                child: IndicatorShapeWidget(
                  shape: Shape.circle,
                  index: i ~/ 2,
                ),
              ),
            ),
          );
        } else {
          widgets[i] = const SizedBox(width: 2);
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      );
    });
  }
}
