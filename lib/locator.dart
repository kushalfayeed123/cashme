import 'package:get_it/get_it.dart';

import 'core/services/auth.service.dart';
import 'core/services/user.service.dart';

GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
}
