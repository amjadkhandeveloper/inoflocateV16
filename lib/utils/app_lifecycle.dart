import 'package:flutter/widgets.dart';

/// Tracks whether InfoLocate is in the foreground.
///
/// Switching apps sends [AppLifecycleState.inactive] then [paused].
/// Timers that fire in that window (or in the first second after [resumed])
/// must not treat a DNS blip as a real offline failure.
class AppLifecycleTracker with WidgetsBindingObserver {
  AppLifecycleTracker._();
  static final AppLifecycleTracker instance = AppLifecycleTracker._();

  AppLifecycleState state = AppLifecycleState.resumed;
  DateTime? _resumedAt;
  bool _attached = false;
  final List<VoidCallback> _resumeListeners = [];

  static const Duration resumeSettleDelay = Duration(milliseconds: 1200);

  bool get isResumed => state == AppLifecycleState.resumed;

  /// True once the app has been [resumed] long enough for radios/DNS to recover.
  bool get isStableForeground {
    if (!isResumed) return false;
    if (_resumedAt == null) return true;
    return DateTime.now().difference(_resumedAt!) >= resumeSettleDelay;
  }

  void ensureAttached() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
    _resumedAt = DateTime.now();
  }

  void addResumeListener(VoidCallback callback) {
    if (!_resumeListeners.contains(callback)) {
      _resumeListeners.add(callback);
    }
  }

  void removeResumeListener(VoidCallback callback) {
    _resumeListeners.remove(callback);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final previous = this.state;
    this.state = state;
    if (state != AppLifecycleState.resumed) {
      return;
    }
    if (previous == AppLifecycleState.resumed) return;
    _resumedAt = DateTime.now();
    Future<void>.delayed(resumeSettleDelay, () {
      if (!isResumed) return;
      for (final callback in List<VoidCallback>.from(_resumeListeners)) {
        callback();
      }
    });
  }
}
