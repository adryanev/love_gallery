import 'package:get_it/get_it.dart';
import 'package:love_gallery/core/repositories/app_data_repository.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/repositories/mock_data_repository.dart';
import 'package:love_gallery/core/services/logging_service.dart';
import 'package:love_gallery/core/services/log_export_service.dart';

final GetIt serviceLocator = GetIt.instance;

// Setup core services that should only be registered once
void setupCoreServices() {
  // Only register if not already registered
  if (!serviceLocator.isRegistered<LoggingService>()) {
    serviceLocator.registerLazySingleton<LoggingService>(
      () => LoggingService(),
    );
  }

  if (!serviceLocator.isRegistered<LogExportService>()) {
    serviceLocator.registerLazySingleton<LogExportService>(
      () => LogExportService(),
    );
  }
}

// Setup or update repositories (can be called multiple times)
void setupRepositories({bool useMock = false}) {
  // Unregister existing repository if it exists
  if (serviceLocator.isRegistered<DataRepository>()) {
    serviceLocator.unregister<DataRepository>();
  }

  // Register repositories
  if (useMock) {
    serviceLocator.registerLazySingleton<DataRepository>(
      () => MockDataRepository(),
    );
  } else {
    serviceLocator.registerLazySingleton<DataRepository>(
      () => AppDataRepository(),
    );
  }
}

// Combined setup for compatibility with existing code
void setupServiceLocator({bool useMock = false}) {
  setupCoreServices();
  setupRepositories(useMock: useMock);
}

// Shorthand for obtaining the data repository
DataRepository getDataRepository() {
  return serviceLocator<DataRepository>();
}

// Shorthand for obtaining the logging service
LoggingService getLogger() {
  return serviceLocator<LoggingService>();
}

// Shorthand for obtaining the log export service
LogExportService getLogExporter() {
  return serviceLocator<LogExportService>();
}
