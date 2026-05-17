import 'package:get_it/get_it.dart';
import 'package:forge/data/datasources/local/hive_service.dart';
import 'package:forge/data/repositories/workout_repository_impl.dart';
import 'package:forge/domain/repositories/workout_repository.dart';

final getIt = GetIt.instance;

void setupInjection(HiveService hiveService) {
  // Services
  getIt.registerSingleton<HiveService>(hiveService);

  // Repositories
  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(getIt<HiveService>()),
  );
}
