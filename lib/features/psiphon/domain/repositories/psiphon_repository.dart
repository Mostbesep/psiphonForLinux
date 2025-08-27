// lib/features/psiphon/domain/repositories/psiphon_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../entities/connection_status.dart';

/// The contract for interacting with Psiphon.
/// This interface belongs to the domain layer and is independent of how
/// the data is fetched.
abstract class PsiphonRepository {
  /// Starts the Psiphon connection process.
  /// Returns [Right(null)] on success or [Left(Failure)] on error.
  Future<Either<Failure, void>> start(PsiphonPaths paths);

  /// Stops the Psiphon connection process.
  Future<Either<Failure, void>> stop();

  /// Provides a stream of [ConnectionStatus] updates.
  /// The UI will listen to this stream to reflect the current state.
  Stream<ConnectionStatus> getStatusStream();
}
