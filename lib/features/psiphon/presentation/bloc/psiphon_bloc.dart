// lib/features/psiphon/presentation/bloc/psiphon_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/usecases/get_status_stream.dart';
import '../../domain/usecases/start_psiphon.dart';
import '../../domain/usecases/stop_psiphon.dart';

part 'psiphon_event.dart';
part 'psiphon_state.dart';

class PsiphonBloc extends Bloc<PsiphonEvent, PsiphonState> {
  final StartPsiphon startPsiphon;
  final StopPsiphon stopPsiphon;
  final GetStatusStream getStatusStream;
  final PsiphonPaths psiphonPaths; // Paths from the initial setup

  StreamSubscription<ConnectionStatus>? _statusSubscription;

  PsiphonBloc({
    required this.startPsiphon,
    required this.stopPsiphon,
    required this.getStatusStream,
    required this.psiphonPaths,
  }) : super(const PsiphonState()) {
    // Register event handlers
    on<StartPsiphonConnection>(_onStartConnection);
    on<StopPsiphonConnection>(_onStopConnection);
    on<_PsiphonStatusUpdated>(_onStatusUpdated);

    // Start listening to the status stream immediately
    _statusSubscription = getStatusStream().listen((status) {
      // Add an internal event to update the state
      add(_PsiphonStatusUpdated(status));
    });
  }

  Future<void> _onStartConnection(
      StartPsiphonConnection event,
      Emitter<PsiphonState> emit,
      ) async {
    // We don't need to emit a 'loading' state here because the
    // status stream will automatically report the 'connecting' state.
    await startPsiphon(StartPsiphonParams(paths: psiphonPaths));
  }

  Future<void> _onStopConnection(
      StopPsiphonConnection event,
      Emitter<PsiphonState> emit,
      ) async {
    await stopPsiphon(NoParams());
  }

  void _onStatusUpdated(
      _PsiphonStatusUpdated event,
      Emitter<PsiphonState> emit,
      ) {
    emit(state.copyWith(status: event.status));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
