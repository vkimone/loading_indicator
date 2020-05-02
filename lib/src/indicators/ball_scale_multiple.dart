import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallScaleMultiple.
class BallScaleMultiple extends StatefulWidget {
  @override
  _BallScaleMultipleState createState() => _BallScaleMultipleState();
}

class _BallScaleMultipleState extends State<BallScaleMultiple>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [0, 200, 400];

  List<AnimationController> _animationControllers = List(3);
  List<Animation<double>> _scaleAnimations = List(3);
  List<Animation<double>> _opacityAnimations = List(3);
  List<CancelableOperation<int>> _delayFeatures = List(3);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _animationControllers[i] = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));

      _scaleAnimations[i] = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));
      _opacityAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 95),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));

      _delayFeatures[i] = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
      }));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f.cancel());
    _animationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List(3);
    for (int i = 0; i < 3; i++) {
      widgets[i] = ScaleTransition(
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.circle),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widgets,
    );
  }
}