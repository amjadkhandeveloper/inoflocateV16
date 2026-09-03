import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerEffect extends StatelessWidget {
  const CustomShimmerEffect({super.key, required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade200
            : Theme.of(context).cardColor,
        highlightColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade100
            : Colors.grey.shade500,
        child: Container(
          // width: 300,
          // height: 400,
          color: Colors.green,
          child: child ?? Container(),
        ));
  }
}
