import 'package:flutter/material.dart';

import '../core/storage/session_service.dart';
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

  // ========================================
  // INICIALIZAR
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
      // COMPROBAR SI EXISTE TOKEN
      // ========================================

      final hasToken = await sessionService.hasToken();

      debugPrint('¿EXISTE TOKEN?: $hasToken');

      // ========================================
      // NO EXISTE TOKEN
      // ========================================

      if (!hasToken) {
        if (!mounted) {
          return;
        }

        setState(() {
          isAuthenticated = false;
          isLoading = false;
        });

        return;
      }

      // ========================================
      // OBTENER TOKEN GUARDADO
      // SOLO PARA DEPURACIÓN
      // ========================================

      final token = await sessionService.getToken();

      debugPrint('TOKEN GUARDADO: $token');

      // ========================================
      // VALIDAR TOKEN CONTRA EL BACKEND
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
        isAuthenticated = true;
        isLoading = false;
      });
    } catch (error) {
      // ========================================
      // ERROR VALIDANDO SESIÓN
      // ========================================

      debugPrint('ERROR VALIDANDO SESIÓN: $error');

      // ========================================
      // COMPROBAR SI EL TOKEN SIGUE GUARDADO
      // ========================================

      final token = await sessionService.getToken();

      debugPrint('TOKEN DESPUÉS DEL ERROR: $token');

      // ========================================
      // IMPORTANTE
      // NO BORRAMOS EL TOKEN TODAVÍA
      // ESTAMOS DEPURANDO
      // ========================================

      if (!mounted) {
        return;
      }

      setState(() {
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
    // CARGANDO SESIÓN
    // ========================================

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ========================================
    // USUARIO AUTENTICADO
    // ========================================

    if (isAuthenticated) {
      return const ProductsScreen();
    }

    // ========================================
    // USUARIO NO AUTENTICADO
    // ========================================

    return const LoginScreen();
  }
}
