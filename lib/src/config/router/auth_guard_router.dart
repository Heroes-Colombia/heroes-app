import 'package:auto_route/auto_route.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
// import 'package:get_it/get_it.dart';
// import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    //TODO: Implement authentication logic

    // final getIt = GetIt.instance;
    var authenticated = true;

    // ignore: dead_code
    if (authenticated) {
      resolver.next();
      router.removeLast();
    } else {
      router.replaceAll([const AuthView()]);
      resolver.redirect(LoginView(onResult: (success) {
        resolver.next(success!);
      }));
    }
  }
}
