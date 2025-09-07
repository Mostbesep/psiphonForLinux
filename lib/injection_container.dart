import 'package:get_it/get_it.dart';
import 'core/services/psiphon_config_service.dart';
import 'core/services/psiphon_setup_service.dart';
import 'features/psiphon/data/datasources/psiphon_local_datasource.dart';
import 'features/psiphon/data/repositories/psiphon_repository_impl.dart';
import 'features/psiphon/domain/repositories/psiphon_repository.dart';
import 'features/psiphon/domain/usecases/get_status_stream.dart';
import 'features/psiphon/domain/usecases/open_webpage.dart';
import 'features/psiphon/domain/usecases/start_psiphon.dart';
import 'features/psiphon/domain/usecases/stop_psiphon.dart';
import 'features/psiphon/presentation/bloc/psiphon_bloc.dart';

// Create a global instance of GetIt
final sl = GetIt.instance;

Future<void> init(PsiphonPaths paths) async {
  // --- Features - Psiphon ---

  // BLoC
  // We register it as a factory because we might want to create a new instance
  // of the BLoC in different parts of the app (though not in this simple case).
  sl.registerFactory(
        () => PsiphonBloc(
      startPsiphon: sl(),
      stopPsiphon: sl(),
      getStatusStream: sl(),
      openWebpage: sl(),
      psiphonPaths: sl(),
      configService: sl(),
    ),
  );

  // Use Cases
  // They are simple classes, so we register them as lazy singletons.
  sl.registerLazySingleton(() => StartPsiphon(sl()));
  sl.registerLazySingleton(() => StopPsiphon(sl()));
  sl.registerLazySingleton(() => GetStatusStream(sl()));
  sl.registerLazySingleton(() => OpenWebpage(sl()));

  // Repository
  sl.registerLazySingleton<PsiphonRepository>(
        () => PsiphonRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<PsiphonLocalDataSource>(
        () => PsiphonLocalDataSourceImpl(),
  );

  // --- Core ---

  sl.registerSingleton<PsiphonPaths>(paths);
  sl.registerLazySingleton(() => PsiphonConfigService());
}