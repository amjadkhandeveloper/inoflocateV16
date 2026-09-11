import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

Color _shimmerBase(BuildContext context) =>
    AppUi.isDark(context) ? AppUi.cardDark : Colors.grey.shade200;

Color _shimmerHighlight(BuildContext context) =>
    AppUi.isDark(context) ? AppUi.lineDark : Colors.grey.shade100;

class DasboardShimmerEffect extends StatelessWidget {
  const DasboardShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppUi.pageBg(context),
      child: Column(
        children: [
          10.h.height,
          const Expanded(flex: 3, child: AlertShimmerContainer()),
          const Expanded(flex: 3, child: ShimmerContainer()),
          const Expanded(flex: 3, child: PinCardShimmer()),
          const Expanded(flex: 3, child: PinCardShimmer()),
        ],
      ),
    );
  }
}

class ListShimmerEffect extends StatelessWidget {
  final bool isAlert;
  final bool isDynamicStatus;
  const ListShimmerEffect(
      {super.key, this.isAlert = false, this.isDynamicStatus = false});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppUi.pageBg(context),
      child: Column(
      children: [
        const SizedBox(
          height: 14,
        ),
        isAlert
            ? const SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(flex: 8, child: ShimmerContainer()),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(flex: 2, child: ShimmerContainer()),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.all(8),
                height: 85,
                child: const ShimmerContainer(),
              ),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return SizedBox(
                  height: 150,
                  child: isDynamicStatus
                      ? const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: DynamicStatusShimmer(),
                        )
                      : const PinCardShimmer());
            },
          ),
        ),
      ],
      ),
    );
  }
}

class DynamicStatusShimmer extends StatelessWidget {
  const DynamicStatusShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase(context),
      highlightColor: _shimmerHighlight(context),
      child: const DynamicStatusSkeleton(),
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase(context),
      highlightColor: _shimmerHighlight(context),
      child: Container(
        margin: const EdgeInsets.all(14),
        width: 100.w,
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AlertShimmerContainer extends StatelessWidget {
  const AlertShimmerContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: _shimmerBase(context),
        highlightColor: _shimmerHighlight(context),
        child: const AlertSkeleton());
  }
}

class PinCardShimmer extends StatelessWidget {
  const PinCardShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: _shimmerBase(context),
        highlightColor: _shimmerHighlight(context),
        child: const PinCardSkeleton());
  }
}

class AlertSkeleton extends StatelessWidget {
  const AlertSkeleton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(14),
          width: 40.w,
          color: Colors.white,
        ),
        Container(
          margin: const EdgeInsets.all(14),
          width: 40.w,
          color: Colors.white,
        ),
      ],
    );
  }
}

class PinCardSkeleton extends StatelessWidget {
  const PinCardSkeleton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                width: 30.w,
                height: 24,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(4),
                width: 40.w,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(
                width: 12,
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(4),
            width: 70.w,
            height: 24,
            color: Colors.white,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 8, right: 8, bottom: 8, left: 4),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DynamicStatusSkeleton extends StatelessWidget {
  const DynamicStatusSkeleton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                width: 30.w,
                height: 26,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(4),
                width: 40.w,
                height: 28,
                color: Colors.white,
              ),
              const SizedBox(
                width: 12,
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Container(
            margin: const EdgeInsets.all(4),
            width: 50.w,
            height: 28,
            color: Colors.white,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 8, right: 8, bottom: 8, left: 4),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 22.w,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
