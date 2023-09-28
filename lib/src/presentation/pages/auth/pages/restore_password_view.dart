import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class RestorePassword extends StatelessWidget {
  const RestorePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('¿Olvidaste tu contraseña?'),
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
                      key: const Key('_restore_email'),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'Ingresa tu correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Recuperar'),
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
}
