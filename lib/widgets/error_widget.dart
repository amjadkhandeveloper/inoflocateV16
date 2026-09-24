import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_lifecycle.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:lottie/lottie.dart';

/// Full-screen error state when [NotifierState.error] (e.g. API failure on list screens).
///
/// Auto-retries every 30 seconds while this screen is visible. Manual Refresh
/// remains available and resets the same countdown.
class CustomErrorWidget extends StatefulWidget {
  final String? errorMsg;
  final void Function()? onPressed;
  const CustomErrorWidget({super.key, this.errorMsg, required this.onPressed});

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget> {
  static const int _retrySeconds = 30;
  Timer? _timer;
  int _secondsLeft = _retrySeconds;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = _retrySeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!AppLifecycleTracker.instance.isResumed) return;
      if (_busy) return;
      if (_secondsLeft <= 1) {
        _retry();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _retry() async {
    if (_busy || widget.onPressed == null) return;
    setState(() {
      _busy = true;
      _secondsLeft = _retrySeconds;
    });
    try {
      widget.onPressed!();
    } finally {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _busy = false);
      _startCountdown();
    }
  }

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
            child: Text(widget.errorMsg ?? 'Oops! something went wrong'),
          ),
          Text(
            LocaliazationKey.retrying_in_seconds.tr(
              namedArgs: {'seconds': '$_secondsLeft'},
            ),
            style: TextStyle(
              color: AppUi.muted(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy ? null : _retry,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(LocaliazationKey.refresh.tr()),
          ),
        ]),
      ),
    );
  }
}

class Lottie {}
