import 'package:get_it/get_it.dart';
import 'package:messenger/services/alert_service.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/database_service.dart';
import 'package:messenger/services/media_service.dart';
import 'package:messenger/services/navigation_service.dart';
import 'package:messenger/services/storage_service.dart';

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<AuthService>(AuthService());

  getIt.registerSingleton<NavigationService>(NavigationService());

  getIt.registerSingleton<AlertService>(AlertService());

  getIt.registerSingleton<MediaService>(MediaService());

  getIt.registerSingleton<StorageService>(StorageService());

  getIt.registerSingleton<DatabaseService>(DatabaseService());
}
