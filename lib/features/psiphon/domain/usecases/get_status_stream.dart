// lib/features/psiphon/domain/usecases/get_status_stream.dart
import '../../../../core/usecase/usecase.dart';
import '../entities/connection_status.dart';
import '../repositories/psiphon_repository.dart';

// This use case doesn't follow the standard call method because it returns a stream.
class GetStatusStream {
  final PsiphonRepository repository;

  GetStatusStream(this.repository);

  Stream<ConnectionStatus> call() {
    return repository.getStatusStream();
  }
}