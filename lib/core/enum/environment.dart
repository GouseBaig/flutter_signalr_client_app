import 'package:flutter_signalr_client_app/core/constants/constants.dart';

enum Environment {
  development(
    Constants.devBaseUrl,
    Constants.devSignalRUrl,
    'development',
  ),
  testing(
    Constants.testingBaseUrl,
    Constants.testingSignalRUrl,
    'testing',
  ),
  production(
    Constants.prodBaseUrl,
    Constants.prodSignalRUrl,
    'production',
  );

  final String name;
  final String kBaseUrl;

  final String kSignalRUrl;
  const Environment(
    this.kBaseUrl,
    this.kSignalRUrl,
    this.name,
  );
}
