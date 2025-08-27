// lib/features/psiphon/data/repositories/psiphon_repository_impl.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/repositories/psiphon_repository.dart';
import '../datasources/psiphon_local_datasource.dart';
import '../models/psiphon_notice_model.dart';

class PsiphonRepositoryImpl implements PsiphonRepository {
  final PsiphonLocalDataSource localDataSource;
  StreamSubscription? _noticeSubscription;

  // Use BehaviorSubject to hold the latest status and emit it to new listeners.
  // We seed it with the initial disconnected state.
  final _statusStreamController =
  BehaviorSubject<ConnectionStatus>.seeded(const ConnectionStatus());

  PsiphonRepositoryImpl({required this.localDataSource}) {
    // Start listening to notices as soon as the repository is created
    _listenToNotices();
  }

  void _listenToNotices() {
    _noticeSubscription = localDataSource.notices.listen((notice) {
      // Get the last known status from the BehaviorSubject's value
      final lastStatus = _statusStreamController.value;
      // Calculate the new status
      final newStatus = _mapNoticeToStatus(notice, lastStatus);
      // Add the new status to our public stream
      _statusStreamController.add(newStatus);
    });
  }

  @override
  Stream<ConnectionStatus> getStatusStream() {
    // Simply return the stream. BehaviorSubject handles the rest.
    return _statusStreamController.stream;
  }

  @override
  Future<Either<Failure, void>> start(PsiphonPaths paths) async {
    try {
      // Set state to connecting before starting the process
      _statusStreamController.add(const ConnectionStatus(state: ConnectionState.connecting));

      await localDataSource.start(paths);
      return const Right(null);
    } catch (e) {
      _statusStreamController.add(
        _statusStreamController.value.copyWith(
          state: ConnectionState.error,
          errorMessage: 'Failed to start Psiphon process.',
        ),
      );
      return Left(PsiphonStartFailure());
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      _statusStreamController.add(
          _statusStreamController.value.copyWith(state: ConnectionState.stopping));

      await localDataSource.stop();
      return const Right(null);
    } catch (e) {
      return Left(PsiphonFailure(message: 'Failed to stop Psiphon.'));
    }
  }

  /// This is the core logic that translates raw notices into meaningful state.
  ConnectionStatus _mapNoticeToStatus(
      PsiphonNotice notice, ConnectionStatus lastStatus) {
    if (notice is ListeningHttpProxyPortNotice) {
      return lastStatus.copyWith(httpProxyPort: notice.port);
    }
    if (notice is ListeningSocksProxyPortNotice) {
      return lastStatus.copyWith(socksProxyPort: notice.port);
    }
    if (notice is AvailableEgressRegionsNotice) {
      return lastStatus.copyWith(availableRegions: notice.regions);
    }
    if (notice is ClientRegionNotice) {
      return lastStatus.copyWith(clientRegion: notice.region);
    }
    if (notice is TunnelsNotice) {
      if (notice.count > 0 && lastStatus.state != ConnectionState.connected) {
        return lastStatus.copyWith(
            state: ConnectionState.connected, clearError: true);
      } else if (notice.count == 0 &&
          lastStatus.state == ConnectionState.connected) {
        // This might indicate an unexpected disconnect
        return lastStatus.copyWith(state: ConnectionState.disconnected);
      }
    }
    if (notice is ConnectedServerRegionNotice) {
      return lastStatus.copyWith(connectedServerRegion: notice.region);
    }
    if (notice is SkipServerEntryNotice) {
      return lastStatus.copyWith(
        state: ConnectionState.error,
        errorMessage: 'Connection failed: ${notice.reason}',
      );
    }
    if (notice is ExitingNotice) {
      // Reset to a clean disconnected state
      return const ConnectionStatus(state: ConnectionState.disconnected);
    }
    // Return last status if the notice is not handled
    return lastStatus;
  }

  // Clean up resources when the repository is no longer needed
  void dispose() {
    _noticeSubscription?.cancel();
    _statusStreamController.close();
  }
}