import 'package:equatable/equatable.dart';


abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}


class ServerFailure extends Failure {}


class CacheFailure extends Failure {}


class NetworkFailure extends Failure {}



class PsiphonFailure extends Failure {
  final String message;

  const PsiphonFailure({this.message = 'An unknown Psiphon error occurred.'});

  @override
  List<Object> get props => [message];
}


class PsiphonStartFailure extends PsiphonFailure {
  const PsiphonStartFailure({String message = 'Failed to start Psiphon.'})
      : super(message: message);
}