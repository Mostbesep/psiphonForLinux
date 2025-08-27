import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/psiphon_repository.dart';

class StopPsiphon implements UseCase<void, NoParams> {
  final PsiphonRepository repository;

  StopPsiphon(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.stop();
  }
}
