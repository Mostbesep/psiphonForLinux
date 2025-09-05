part of 'psiphon_bloc.dart';

class PsiphonState extends Equatable {
  /// The detailed status of the connection from the domain layer.
  final ConnectionStatus status;
  final bool serviceIsRunning;

  const PsiphonState({this.status = const ConnectionStatus(), this.serviceIsRunning = false,});

  @override
  List<Object> get props => [serviceIsRunning ,status];

  PsiphonState copyWith({
    ConnectionStatus? status,
    bool? serviceIsRunning,
  }) {
    return PsiphonState(
      status: status ?? this.status,
      serviceIsRunning: serviceIsRunning ?? this.serviceIsRunning,
    );
  }
}
