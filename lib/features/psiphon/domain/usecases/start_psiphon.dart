// lib/features/psiphon/domain/usecases/start_psiphon.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/psiphon_repository.dart';

class StartPsiphon implements UseCase<void, StartPsiphonParams> {
  final PsiphonRepository repository;

  StartPsiphon(this.repository);

  @override
  Future<Either<Failure, void>> call(StartPsiphonParams params) async {
    return await repository.start(params.paths);
  }
}

/// Parameters required to start the Psiphon process.
class StartPsiphonParams extends Equatable {
  final PsiphonPaths paths;

  const StartPsiphonParams({required this.paths});

  @override
  List<Object> get props => [paths];
}
