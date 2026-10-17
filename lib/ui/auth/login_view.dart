import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_info.dart';
import '../brand/ariston_brand.dart';
import 'auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final email = _email.text.trim();
    if (_isLogin) {
      await vm.login(email, _password.text);
    } else {
      await vm.register(email, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AristonLogo(width: 240)),
                    const SizedBox(height: 12),
                    Text(
                      _isLogin ? 'Bem-vinda' : 'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o email.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe sua senha.';
                        if (v.length < 6) return 'Mínimo de 6 caracteres.';
                        return null;
                      },
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: vm.isLoading ? null : _submit,
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isLogin ? 'Entrar' : 'Cadastrar'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou', style: theme.textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: vm.isLoading ? null : vm.loginWithGoogle,
                      icon: Image.asset('assets/brand/google_g.png',
                          width: 20, height: 20),
                      label: const Text('Continuar com o Google'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.clearError();
                        setState(() => _isLogin = !_isLogin);
                      },
                      child: Text(
                        _isLogin
                            ? 'Ainda não tem conta? Cadastre-se.'
                            : 'Voltar ao login.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ariston ${AppInfo.label}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
