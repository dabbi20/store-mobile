import 'package:flutter/material.dart';

import '../core/storage/session_service.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'products_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // ========================================
  // SERVICIOS
  // ========================================

  final SessionService sessionService = SessionService();
  final UserService userService = UserService();

  // ========================================
  // ESTADOS
  // ========================================

  bool isLoading = true;
  bool isAuthenticated = false;

  User? currentUser;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    checkSession();
  }

  // ========================================
  // COMPROBAR SESIÓN
  // ========================================

  Future<void> checkSession() async {
    try {
      // ========================================
      // COMPROBAR TOKEN
      // ========================================

      final hasToken = await sessionService.hasToken();

      debugPrint('¿EXISTE TOKEN?: $hasToken');

      // ========================================
      // NO HAY TOKEN
      // ========================================

      if (!hasToken) {
        if (!mounted) {
          return;
        }

        setState(() {
          currentUser = null;
          isAuthenticated = false;
          isLoading = false;
        });

        return;
      }

      // ========================================
      // VALIDAR TOKEN CON BACKEND
      // GET /users/me
      // ========================================

      final user = await userService.getMyProfile();

      debugPrint('SESIÓN VÁLIDA: ${user.username}');

      // ========================================
      // USUARIO AUTENTICADO
      // ========================================

      if (!mounted) {
        return;
      }

      setState(() {
        currentUser = user;
        isAuthenticated = true;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('ERROR VALIDANDO SESIÓN: $error');

      // ========================================
      // TOKEN INVÁLIDO
      // ========================================

      await sessionService.removeToken();

      if (!mounted) {
        return;
      }

      setState(() {
        currentUser = null;
        isAuthenticated = false;
        isLoading = false;
      });
    }
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    // ========================================
    // CARGANDO
    // ========================================

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ========================================
    // AUTENTICADO
    // ========================================

    if (isAuthenticated && currentUser != null) {
      return ProductsScreen(currentUser: currentUser!);
    }

    // ========================================
    // NO AUTENTICADO
    // ========================================

    return const LoginScreen();
  }
}
