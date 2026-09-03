import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
          height: 60,
          child: Image.asset('assets/animation/wait_loader.gif', height: 40)),
    );
  }
}
