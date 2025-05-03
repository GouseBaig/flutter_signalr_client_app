import 'dart:async';

import 'package:flutter_signalr_client_app/core/base/utils/app_logger.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);

class SignalRService {
  final String hubUrl;
  final MessageCallback onMessageReceived;

  late final HubConnection _connection;
  Timer? _reconnectTimer;
  int _retryCount = 0;

  SignalRService({
    required this.hubUrl,
    required this.onMessageReceived,
  }) {
    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            // Optional: Set the transport type according to your needs
            // transport: HttpTransportType
            //     .WebSockets, // or HttpTransportType.longPolling
            logger: Logger('SignalR - transport'),
          ),
        )
        .withAutomaticReconnect() // Enables built-in reconnection
        .configureLogging(Logger('SignalR - hub'))
        .build();

    _registerHandlers();
  }

  void _registerHandlers() {
    _connection.on('SystemStatus', (arguments) {
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
        try {
          final message = Map<String, dynamic>.from(arguments[0] as Map);
          AppLogger.i('SystemStatus: $message');
          onMessageReceived(message);
        } catch (e) {
          AppLogger.e('❌ Error parsing message: $e');
        }
      }
    });

    _connection.onclose(({error}) {
      AppLogger.w('⚠️ SignalR disconnected. Error: $error');
      _startReconnecting(); // retry with backoff
    });

    _connection.onreconnecting(({error}) {
      AppLogger.w('🔁 SignalR reconnecting... Error: $error');
    });

    _connection.onreconnected(({connectionId}) {
      AppLogger.i('✅ SignalR reconnected! Connection ID: $connectionId');
      _retryCount = 0;
      _reconnectTimer?.cancel();
    });
  }

  void _startReconnecting() async {
    try {
      await _connection.start();
      AppLogger.i('✅ SignalR reconnected successfully!');
      //_retryCount = 0;
    } catch (e) {
      AppLogger.e('❌ Reconnect attempt $_retryCount failed: $e');
      _startReconnecting(); // try again recursively
    }
  }

  Future<void> start() async {
    try {
      AppLogger.i('✅ SignalR is connecting to $hubUrl');
      await _connection.start();
      AppLogger.i('✅ SignalR connected to $hubUrl');
    } catch (e) {
      AppLogger.e('❌ Initial connection failed: $e');
    }
  }

  Future<void> stop() async {
    await _connection.stop();
    AppLogger.i('🛑 SignalR disconnected');
  }
}
