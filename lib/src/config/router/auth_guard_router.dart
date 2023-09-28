import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
// import 'package:get_it/get_it.dart';
// import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final getIt = GetIt.instance;
    var authenticated = getIt<AuthService>().checkUserSession();

    if (authenticated) {
      resolver.next();
      router.removeLast();
    } else {
      router.replaceAll([const AuthView()]);
      resolver.redirect(
        LoginView(
          onResult: (success) {
            resolver.next(success!);
          },
        ),
      );
    }
  }
}
