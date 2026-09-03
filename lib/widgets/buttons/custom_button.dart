import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  CustomButton(
      {super.key,
      this.title,
      required this.onPressed,
      this.buttonColor,
      this.textColor,
      this.icon});
  final String? title;
  Color? buttonColor;
  Color? textColor;
  IconData? icon;
  final VoidCallback onPressed;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return NeumorphicEffect(
    //     child: TextButton(
    //   onPressed: () {},
    //   child: const Text('Login'),
    //   style: ElevatedButton.styleFrom(
    //       minimumSize: Size(100.w, 5.h),
    //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //       elevation: 0,
    //       foregroundColor: textColor,
    //       backgroundColor: buttonColor),
    // ));
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 0.7,
      ).animate(_controller),
      child: ElevatedButton(
        key: widget.key,
        onPressed: () {
          _controller.forward();
          Future.delayed(const Duration(milliseconds: 200), () {
            _controller.reverse().then((value) => widget.onPressed());
          });
        },
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100.w, 6.h),
            elevation: 0,
            // shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            foregroundColor: widget.textColor,
            backgroundColor: widget.buttonColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Icon(widget.icon),
                  )
                : Container(),
            Flexible(
              child: Text(
                widget.title ?? '',
                style: AppStyles.textStyle4(context: context, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
