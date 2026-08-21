import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'products_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ========================================
  // SERVICIO
  // ========================================

  final AuthService authService = AuthService();

  // ========================================
  // CONTROLADORES
  // ========================================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ========================================
  // ESTADOS
  // ========================================

  bool isLoading = false;
  bool obscurePassword = true;
  String? error;

  // ========================================
  // LOGIN
  // ========================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ========================================
    // VALIDACIONES
    // ========================================

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'El correo y la contraseña son obligatorios';
      });

      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // ========================================
      // AUTENTICAR USUARIO
      // ========================================

      final user = await authService.login(email, password);

      debugPrint('Sesión iniciada: ${user.username}');

      // ========================================
      // VERIFICAR WIDGET
      // ========================================

      if (!mounted) {
        return;
      }

      // ========================================
      // IR A PRODUCTOS
      // ========================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductsScreen(currentUser: user),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ========================================
  // LIBERAR CONTROLADORES
  // ========================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================================
                // TÍTULO
                // ========================================

                const Icon(Icons.eco, size: 72),

                const SizedBox(height: 16),

                const Text(
                  'EcoHome Store',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Inicia sesión en tu cuenta',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ========================================
                // EMAIL
                // ========================================
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================
                // CONTRASEÑA
                // ========================================
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onSubmitted: (_) {
                    if (!isLoading) {
                      login();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================
                // ERROR
                // ========================================
                if (error != null) ...[
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ========================================
                // BOTÓN
                // ========================================
                FilledButton(
                  onPressed: isLoading ? null : login,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
