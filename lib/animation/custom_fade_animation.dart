import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CustomFadeScaleTransition extends StatefulWidget {
  const CustomFadeScaleTransition(
      {super.key,
      required this.child,
      this.duration = const Duration(seconds: 2)});
  final Widget? child;
  final Duration duration;

  @override
  State<CustomFadeScaleTransition> createState() =>
      _CustomFadeScaleTransitionState();
}

class _CustomFadeScaleTransitionState extends State<CustomFadeScaleTransition>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    startAnimation();
    super.initState();
  }

  startAnimation() {
    if (!controller.isAnimating) controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return
            // SlideTransition(
            //   position: Tween<Offset>(
            //     begin: const Offset(-1, 0),
            //     end: Offset(0, 0),
            //   ).animate(animation),
            //   child: widget.child ?? Container(),
            // );
            FadeScaleTransition(
          animation: animation,
          child: widget.child ?? Container(),
        );
      },
    );
  }
}
