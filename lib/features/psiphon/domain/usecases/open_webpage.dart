import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/psiphon_repository.dart';

class OpenWebpage implements UseCase<void, String> {
  final PsiphonRepository repository;

  OpenWebpage(this.repository);

  @override
  Future<Either<Failure, void>> call(String url) async {
    return await repository.openPsiphonWebsite(url);
  }
}