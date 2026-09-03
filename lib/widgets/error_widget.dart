import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Full-screen error state when [NotifierState.error] (e.g. API failure on list screens).
class CustomErrorWidget extends StatelessWidget {
  final String? errorMsg;
  final void Function()? onPressed;
  const CustomErrorWidget({super.key, this.errorMsg, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          LottieBuilder.asset(
            'assets/animation/error_lottie.json',
            width: 200,
            height: 200,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(errorMsg ?? 'Oops! something went wrong'),
          ),
          TextButton(onPressed: onPressed, child: const Text('Refresh'))
        ]),
      ),
    );
  }
}

class Lottie {}
