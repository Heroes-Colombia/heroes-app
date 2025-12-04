import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';

@RoutePage()
class EntryPointView extends StatefulWidget {
  const EntryPointView({super.key});

  @override
  State<EntryPointView> createState() => _EntryPointViewState();
}

class _EntryPointViewState extends State<EntryPointView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          switch (state.authStatus) {
            case AuthStatus.initial:
              return loadingView();
            case AuthStatus.loading:
              return loadingView();
            case AuthStatus.userLoggedIn:
              return userLoggedIn();
            case AuthStatus.userLoggedInNotVerified:
              return userLoggedInButNotVerified(context);
            case AuthStatus.userNeedsVerification:
              return userNeedsVerification(context);
            case AuthStatus.userNotLoggedIn:
              return userNotLoggedInView(context);
            case AuthStatus.businessLoggedIn:
              return userIsBusiness();
            case AuthStatus.error:
              return logInError();
            default:
              return Container();
          }
        },
      ),
    );
  }

  Widget loadingView() {
    return brandingWidget();
  }

  Widget userNotLoggedInView(BuildContext context) {
    //Redirect to the first time view
    AutoRouter.of(context).replaceAll([
      FirstTimeView(),
    ]);
    return brandingWidget();
  }

  Widget userLoggedInButNotVerified(BuildContext context) {
    //Redirect to the unverified view
    AutoRouter.of(context).replaceAll([
      UnverifiedUserView(),
    ]);
    return const CustomScrollView(
      slivers: [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
      ],
    );
  }

  Widget userLoggedIn() {
    //Redirect to the home view
    AutoRouter.of(context).replaceAll([DashBoardView()]);
    return brandingWidget();
  }

  Widget userNeedsVerification(BuildContext context) {
    // Get user data from AuthService and redirect to verification
    final locator = GetIt.instance;
    final userUid = locator.get<AuthService>().getUserId();
    
    // For app restart scenario, we need to get user data from Firestore
    // Since we don't have form data, create minimal data from stored user info
    final userEnteredData = <String, String>{
      'uid': userUid,
      // The verification service will get full user data from Firestore if needed
    };
    
    AutoRouter.of(context).replaceAll([
      MilitaryVerificationView(
        userEnteredData: userEnteredData,
        userId: userUid,
      ),
    ]);
    
    return const CustomScrollView(
      slivers: [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
      ],
    );
  }

  Widget userIsBusiness() {
    // V2: Business users should use web dashboard - show message and logout
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.business,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Gestión de Negocios',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'La gestión de negocios ahora está disponible en nuestra plataforma web.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.desktop_windows,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Visita',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'app.heroescolombia.com',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  // Logout and redirect to login
                  final authCubit = context.read<AuthCubit>();
                  final router = AutoRouter.of(context);
                  await authCubit.logOut();
                  router.replaceAll([
                    FirstTimeView(),
                    LoginView(onResult: (guardCallback) {}),
                  ]);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget logInError() {
    return const CustomScrollView(
      slivers: [
        SliverFillRemaining(
            child: Center(
          child: Text("Error"),
        ))
      ],
    );
  }

  Widget brandingWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: "logo",
            child: SvgPicture.asset(
              "assets/images/heroes_white_logo.svg",
              height: 40,
              width: 300,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 34),
          const CircularProgressIndicator()
        ],
      ),
    );
  }
}
