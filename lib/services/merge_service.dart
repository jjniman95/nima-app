import 'dart:async';
import 'package:flutter/foundation.dart';

class MergeService {
  MergeService._();

  static final MergeService instance = MergeService._();

  static const Duration mergeDuration = Duration(minutes: 10);

  Timer? _timer;

  Duration _remaining = mergeDuration;

  final StreamController<Duration> _countdownController =
      StreamController.broadcast();

  Stream<Duration> get countdownStream => _countdownController.stream;

  Duration get remaining => _remaining;

  void start({
    required VoidCallback onExpired,
  }) {
    _timer?.cancel();

    _remaining = mergeDuration;
    _countdownController.add(_remaining);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _remaining -= const Duration(seconds: 1);

        _countdownController.add(_remaining);

        if (_remaining.inSeconds <= 0) {
          timer.cancel();
          onExpired();
        }
      },
    );
  }

  void reset() {
    _remaining = mergeDuration;
    _countdownController.add(_remaining);
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _countdownController.close();
  }
}
