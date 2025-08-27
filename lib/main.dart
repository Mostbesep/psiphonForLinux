import 'package:flutter/material.dart';
import 'core/services/psiphon_setup_service.dart';
import 'features/psiphon/presentation/pages/home_page.dart';
import 'injection_container.dart' as di; // Import with a prefix

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the setup service
  final setupService = PsiphonSetupService();
  try {
    final psiphonPaths = await setupService.checkAndPrepare();
    print('Psiphon setup complete.');

    // Initialize dependency injection with the paths
    await di.init(psiphonPaths);

    runApp(const MyApp());

  } catch (e) {
    print('A critical error occurred during setup: $e');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psiphon Flutter',
      theme: ThemeData.dark(),
      home: const HomePage(), // Set HomePage as the main screen
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize the application.'),
        ),
      ),
    );
  }
}