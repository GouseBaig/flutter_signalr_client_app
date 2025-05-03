import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signalr_client_app/core/base/utils/app_logger.dart';
import 'package:flutter_signalr_client_app/core/config/size_config.dart';
import 'package:flutter_signalr_client_app/core/shared_widgets/components.dart';
import 'package:flutter_signalr_client_app/core/state/signalr_client_notifier_provider.dart';
import 'package:flutter_signalr_client_app/core/theme/app_colors.dart';

void main() {
  final container = ProviderContainer(
    overrides: [],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        AppLogger.d("LayoutBuilder - constraints: $constraints");
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            AppLogger.d("Orientation: $orientation");
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: const MyHomePage(title: 'SignalR Client Demo Page'),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;
  bool isFailOverPopupShown = false; // Prevent multiple popups

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _showFailoverPopup(BuildContext context) {
    showDownTimeDialog(
      title: "Warning",
      context: context,
      barrierDismissible: false,
      content: WillPopScope(
        onWillPop: () async {
          return false; // Prevent back navigation
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "The system is currently down. Please try again later.",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () {
                  if (isFailOverPopupShown) {
                    isFailOverPopupShown = false;
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SuisseIntl',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      showCloseButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.read(signalRProvider.notifier); // force initialization
    ref.listen<SignalRClientState>(signalRProvider, (prev, next) {
      AppLogger.d("Homepage - signalRProvider: ${next.isDown}");
      if (next.isDown && (prev?.isDown != true)) {
        if (!isFailOverPopupShown) {
          isFailOverPopupShown = true; // Prevent multiple popups
          _showFailoverPopup(context);
        }
      } else if (!next.isDown && (prev?.isDown == true)) {
        if (isFailOverPopupShown) {
          Navigator.of(context, rootNavigator: true).pop(); // Close popup
          isFailOverPopupShown = false; // Reset the flag
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, _) {
                final isDown = ref.watch(signalRProvider).isDown;

                return ElevatedButton(
                  onPressed: isDown
                      ? null
                      : () {
                          setState(() {
                            _counter = 0;
                          });
                        },
                  child: const Text('Reset'),
                );
              },
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 50),
            Consumer(
              builder: (context, ref, _) {
                final isDown = ref.watch(signalRProvider).isDown;

                return !isDown
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.appRedColor,
                            width: 2,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.appRedColor,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'System is not operational',
                              style: TextStyle(
                                color: AppColors.appRedColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final isDown = ref.watch(signalRProvider).isDown;
          return FloatingActionButton(
            onPressed: isDown ? null : _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
