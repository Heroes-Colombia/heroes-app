import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class LoginView extends StatelessWidget {
  final Function(bool?) onResult;
  const LoginView({Key? key, required this.onResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Iniciar sesión'),
            pinned: true,
            floating: true,
            snap: true,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: FormBuilder(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormBuilderTextField(
                      name: 'email',
                      key: const Key('_login_email'),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'Ingresa tu correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        if (!RegExp(
                          r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
                        ).hasMatch(value)) {
                          return 'Por favor ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'password',
                      key: const Key('_login_password'),
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingresa tu contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => doLogin(context),
                      child: const Text('Iniciar sesión'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        AutoRouter.of(context).push(const RestorePassword());
                      },
                      child: const Text('Olvidé mi contraseña'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> doLogin(BuildContext context) async {
    if (_formKey.currentState!.saveAndValidate()) {
      final userIsLoggedIn = await context.read<AuthCubit>().logIn(
            _formKey.currentState!.value,
          );
      print(' userIsLoggedIn: $userIsLoggedIn');
      if (userIsLoggedIn) {
        onResult.call(true);
      }
      if (!context.mounted) return;
      _showMyDialog(context);
    }
    // context.read<AuthCubit>().checkIfUserIsLoggedIn();
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Las credenciales no validas'),
                Text('Por favor intenta de nuevo'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
