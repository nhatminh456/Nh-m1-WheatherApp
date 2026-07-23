import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.status == LoginStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/weather');
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'At least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (widget.viewModel.status == LoginStatus.error)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.viewModel.errorMessage ?? 'Login failed',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  if (widget.viewModel.status == LoginStatus.submitting)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        FilledButton(
                          onPressed: _submitSignIn,
                          child: const Text('Sign in'),
                        ),
                        TextButton(
                          onPressed: _submitRegister,
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitSignIn() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _submitRegister() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
