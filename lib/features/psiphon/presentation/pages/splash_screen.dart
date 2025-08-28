import 'package:flutter/material.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../../../../injection_container.dart' as di;
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // A future that will complete when the app is initialized.
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  /// This method runs the setup service and initializes dependencies.
  Future<void> _initializeApp() async {
    try {
      // Step 1: Run the setup service to check/download files.
      final psiphonPaths = await PsiphonSetupService().checkAndPrepare();
      print('Psiphon setup complete.');

      // Step 2: Initialize dependency injection with the required paths.
      await di.init(psiphonPaths);
    } catch (e) {
      // If any error occurs, rethrow it to be caught by the FutureBuilder.
      print('A critical error occurred during setup: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        // Check the state of the future
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // If initialization failed, show a persistent error message.
            return const ErrorPage(
              message: 'Failed to initialize the application.\nPlease restart the app.',
            );
          } else {
            // If successful, navigate to the HomePage after the build is complete.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            });
          }
        }

        // While waiting for the future, or during the brief navigation period,
        // show the loading UI.
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Preparing application, please wait...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A simple widget to display an error message.
class ErrorPage extends StatelessWidget {
  final String message;
  const ErrorPage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}