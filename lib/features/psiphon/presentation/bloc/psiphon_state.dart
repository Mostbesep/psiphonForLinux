part of 'psiphon_bloc.dart';

class PsiphonState extends Equatable {
  /// The detailed status of the connection from the domain layer.
  final ConnectionStatus status;

  const PsiphonState({this.status = const ConnectionStatus()});

  @override
  List<Object> get props => [status];

  PsiphonState copyWith({
    ConnectionStatus? status,
  }) {
    return PsiphonState(
      status: status ?? this.status,
    );
  }
}
