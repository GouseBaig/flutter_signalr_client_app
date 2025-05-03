import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signalr_client_app/core/base/utils/app_logger.dart';
import 'package:flutter_signalr_client_app/core/config/config.dart';
import 'package:flutter_signalr_client_app/core/model/system_status_message.dart';
import 'package:flutter_signalr_client_app/core/services/signalr_service.dart';

class SignalRClientState {
  final bool isDown;
  final SystemStatusMessage? message;
  SignalRClientState({
    this.isDown = false,
    this.message,
  });

  SignalRClientState copyWith({
    SystemStatusMessage? message,
    bool? isDown,
  }) {
    return SignalRClientState(
      isDown: isDown ?? this.isDown,
      message: message ?? this.message,
    );
  }
}

final signalRProvider =
    StateNotifierProvider<FailoverNotifier, SignalRClientState>(
  (ref) => FailoverNotifier(ref),
);

class FailoverNotifier extends StateNotifier<SignalRClientState> {
  final Ref ref;
  late final SignalRService _signalRService;

  // For simulation purposes
  Timer? _toggleTimer;
  bool _currentIsDown = false;

  FailoverNotifier(this.ref) : super(SignalRClientState()) {
    _connectToSignalR(); // Uncomment this line to simulate SignalR connection
    //_init(); // Initialize SignalR connection
  }

  void _init() {
    _signalRService = SignalRService(
      hubUrl: "${kEnvironment.kSignalRUrl}/notificationStatusHub",
      onMessageReceived: (Map<String, dynamic> data) {
        final message = SystemStatusMessage.fromJson(data);
        state = state.copyWith(
          message: message,
          isDown: message.isDown,
        );
        AppLogger.i("Updated System Status state: isDown=${message.isDown}");
      },
    );

    _signalRService.start();
  }

  // Simulation method to toggle the failover state
  void _connectToSignalR() async {
    AppLogger.i("Failover simulation started");
    _toggleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _currentIsDown = !_currentIsDown; // toggle value
      updateDowntimeStatus(_currentIsDown);
      AppLogger.i("Simulated downtime toggled: isDown=$_currentIsDown");
    });
  }

  void updateDowntimeStatus(bool isDown) {
    state = state.copyWith(
      isDown: isDown,
      message: state.message,
    );
  }

  @override
  void dispose() {
    _signalRService.stop();
    super.dispose();
  }
}
