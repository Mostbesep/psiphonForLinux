import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/psiphon_config_service.dart';
import '../../../../core/services/psiphon_setup_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/usecases/get_status_stream.dart';
import '../../domain/usecases/open_webpage.dart';
import '../../domain/usecases/start_psiphon.dart';
import '../../domain/usecases/stop_psiphon.dart';

part 'psiphon_event.dart';
part 'psiphon_state.dart';

class PsiphonBloc extends Bloc<PsiphonEvent, PsiphonState> {
  final StartPsiphon startPsiphon;
  final StopPsiphon stopPsiphon;
  final GetStatusStream getStatusStream;
  final OpenWebpage openWebpage;
  final PsiphonPaths psiphonPaths;
  final PsiphonConfigService configService;

  StreamSubscription<ConnectionStatus>? _statusSubscription;

  PsiphonBloc({
    required this.startPsiphon,
    required this.stopPsiphon,
    required this.getStatusStream,
    required this.openWebpage,
    required this.psiphonPaths,
    required this.configService,
  }) : super(const PsiphonState()) {
    on<PsiphonBlocInitialized>(_onInitialize);
    on<StartPsiphonConnection>(_onStartConnection);
    on<StopPsiphonConnection>(_onStopConnection);
    on<SelectRegion>(_onSelectRegion);
    on<OpenWebsite>(_openWebsite);
    on<_PsiphonStatusUpdated>(_onStatusUpdated);


    // Trigger the initialization event right after the BLoC is created.
    add(PsiphonBlocInitialized());
  }

  Future<void> _onInitialize(
      PsiphonBlocInitialized event, Emitter<PsiphonState> emit) async {
    // Read initial region from config and emit the state.
    final initialRegion = await configService.readEgressRegion(psiphonPaths.configPath);
    if (initialRegion != null) {
      emit(state.copyWith(status: state.status.copyWith(selectedEgressRegion: initialRegion)));
    }

    // Start listening to the status stream.
    _statusSubscription = getStatusStream().listen((status) {
      add(_PsiphonStatusUpdated(status));
    });
  }

  Future<void> _onStartConnection(
      StartPsiphonConnection event, Emitter<PsiphonState> emit) async {
    emit(state.copyWith(serviceIsRunning: true));
    await startPsiphon(StartPsiphonParams(paths: psiphonPaths));
  }

  Future<void> _onStopConnection(
      StopPsiphonConnection event, Emitter<PsiphonState> emit) async {
    emit(state.copyWith(serviceIsRunning: false));
    await stopPsiphon(NoParams());
  }

  Future<void> _onSelectRegion(SelectRegion event, Emitter<PsiphonState> emit) async {
    // 1. Stop the current connection if it's running
    if (state.status.state != ConnectionState.disconnected &&
        state.status.state != ConnectionState.stopping) {
      await stopPsiphon(NoParams());
    }

    // 2. Update the config file with the new region
    await configService.updateEgressRegion(psiphonPaths.configPath, event.regionCode);

    // 3. Update the state with the newly selected region
    emit(state.copyWith(
      status: state.status.copyWith(selectedEgressRegion: event.regionCode),
    ));

    // 4. Automatically reconnect
    add(StartPsiphonConnection());
  }

  Future<void> _openWebsite(OpenWebsite event, Emitter<PsiphonState> emit) async {
    // Open the official Psiphon website in a web browser.
    await openWebpage(event.url);
  }

  void _onStatusUpdated(_PsiphonStatusUpdated event, Emitter<PsiphonState> emit) {
    // Preserve the selected region when status updates come from the stream
    emit(state.copyWith(
        status: event.status.copyWith(
          selectedEgressRegion: state.status.selectedEgressRegion,
        )));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
