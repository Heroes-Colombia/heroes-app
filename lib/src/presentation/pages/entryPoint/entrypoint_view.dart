import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
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
    //Redirect to the first time view and login
    AutoRouter.of(context).replaceAll([
      FirstTimeView(),
      LoginView(onResult: (guardCallback) {}),
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

  Widget userIsBusiness() {
    //Redirect to the business dashboard view
    AutoRouter.of(context).replaceAll([const BusinessDashBoardView()]);

    return brandingWidget();
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
