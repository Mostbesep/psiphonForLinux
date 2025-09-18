import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/services/psiphon_setup_service.dart';
import '../models/psiphon_notice_model.dart';

// Abstract class to define the contract for our data source.
// This is good practice for testing and dependency inversion.
abstract class PsiphonLocalDataSource {
  /// A stream of parsed notices from the Psiphon process.
  Stream<PsiphonNotice> get notices;

  /// Starts the Psiphon process.
  /// Throws an exception if it fails to start.
  Future<void> start(PsiphonPaths paths);

  /// Stops the Psiphon process.
  Future<void> stop();
}


class PsiphonLocalDataSourceImpl implements PsiphonLocalDataSource {
  Process? _process;
  final _noticeStreamController = StreamController<PsiphonNotice>.broadcast();

  @override
  Stream<PsiphonNotice> get notices => _noticeStreamController.stream;

  @override
  Future<void> start(PsiphonPaths paths) async {
    if (_process != null) {
      print("A process is already running. Please stop it first.");
      return;
    }
    try {
      _process = await Process.start(
        paths.binaryPath,
        ['-config', paths.configPath],
        workingDirectory: paths.appDocsDirectory,
      );

      // --- THE FIX: Listen to stderr instead of stdout ---
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
          // Psiphon outputs its notices to the standard error stream.
          print("Psiphon stderr: $line");
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            final notice = PsiphonNotice.fromJson(json);
            _noticeStreamController.add(notice);
          } catch (e) {
            print("Failed to parse JSON line from stderr: $line, Error: $e");
          }
        },
      );

      // We can still listen to stdout, just in case.
      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => print("Psiphon stdout: $line"));


      _process!.exitCode.then((code) {
        print("Psiphon process exited with code: $code");
        _process = null;
        if (!_noticeStreamController.isClosed) {
          _noticeStreamController.add(const ExitingNotice());
        }
      });

    } catch (e) {
      print("Failed to start Psiphon process: $e");
      _process = null;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_process != null) {
      print("Stopping Psiphon process...");
      final killed = _process!.kill(ProcessSignal.sigint); // Graceful shutdown
      print("Process kill signal sent. Result: $killed");
      _process = null;
    }
  }

  // It's good practice to have a dispose method to clean up resources.
  void dispose() {
    _noticeStreamController.close();
  }
}
