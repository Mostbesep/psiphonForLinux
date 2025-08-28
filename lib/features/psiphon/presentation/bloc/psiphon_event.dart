part of 'psiphon_bloc.dart';

abstract class PsiphonEvent extends Equatable {
  const PsiphonEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger the initial setup inside the BLoC.
class PsiphonBlocInitialized extends PsiphonEvent {}

/// Event triggered when the user wants to start the connection.
class StartPsiphonConnection extends PsiphonEvent {}

/// Event triggered when the user wants to stop the connection.
class StopPsiphonConnection extends PsiphonEvent {}

/// Event triggered when the user selects a new region.
class SelectRegion extends PsiphonEvent {
  final String regionCode;

  const SelectRegion(this.regionCode);

  @override
  List<Object> get props => [regionCode];
}

/// An internal event used to push new status updates into the BLoC.
class _PsiphonStatusUpdated extends PsiphonEvent {
  final ConnectionStatus status;

  const _PsiphonStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}
