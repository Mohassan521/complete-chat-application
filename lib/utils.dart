import 'package:get_it/get_it.dart';
import 'package:messenger/services/auth_service.dart';

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<AuthService>(AuthService());
}
