part of 'psiphon_bloc.dart';

abstract class PsiphonEvent extends Equatable {
  const PsiphonEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the user wants to start the connection.
class StartPsiphonConnection extends PsiphonEvent {}

/// Event triggered when the user wants to stop the connection.
class StopPsiphonConnection extends PsiphonEvent {}

/// An internal event used to push new status updates into the BLoC.
class _PsiphonStatusUpdated extends PsiphonEvent {
  final ConnectionStatus status;

  const _PsiphonStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}
