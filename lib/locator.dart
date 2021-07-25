import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/core/services/transaction.service.dart';
import 'package:get_it/get_it.dart';

import 'core/services/auth.service.dart';
import 'core/services/user.service.dart';

GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => WalletService());
  locator.registerLazySingleton(() => TransactionService());
}
