import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ========================================
  // SERVICIO
  // ========================================

  final UserService userService = UserService();

  // ========================================
  // ESTADOS
  // ========================================

  User? user;
  Map<String, dynamic>? stats;

  bool isLoading = true;
  String? error;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  // ========================================
  // CARGAR PERFIL
  // ========================================

  Future<void> loadProfile() async {
    try {
      final profileResult = await userService.getMyProfile();

      final statsResult = await userService.getMyStats();

      if (!mounted) {
        return;
      }

      setState(() {
        user = profileResult;
        stats = statsResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');

        isLoading = false;
      });
    }
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: buildBody(),
    );
  }

  // ========================================
  // CONTENIDO
  // ========================================

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (user == null) {
      return const Center(child: Text('No se pudo cargar el usuario'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ========================================
        // AVATAR
        // ========================================

        const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),

        const SizedBox(height: 24),

        // ========================================
        // NOMBRE
        // ========================================
        Text(
          user!.username,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        const SizedBox(height: 8),

        Text(user!.email, textAlign: TextAlign.center),

        const SizedBox(height: 32),

        // ========================================
        // INFORMACIÓN
        // ========================================
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('ID'),
          subtitle: Text(user!.id.toString()),
        ),

        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Usuario'),
          subtitle: Text(user!.username),
        ),

        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Correo electrónico'),
          subtitle: Text(user!.email),
        ),

        ListTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: const Text('Rol'),
          subtitle: Text(user!.role),
        ),

        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Fecha de registro'),
          subtitle: Text(
            user!.createdAt != null
                ? user!.createdAt!.toLocal().toString()
                : 'No disponible',
          ),
        ),

        const Divider(height: 40),

        // ========================================
        // ESTADÍSTICAS
        // ========================================
        Text('Estadísticas', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Productos creados'),
            trailing: Text(
              '${stats?['products_created'] ?? 0}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}
