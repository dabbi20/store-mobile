import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'login_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // ========================================
  // SERVICIOS
  // ========================================

  final ProductService productService = ProductService(apiClient: ApiClient());

  final AuthService authService = AuthService();

  // ========================================
  // ESTADOS
  // ========================================

  List<Product> products = [];

  bool isLoading = true;

  String? error;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  // ========================================
  // CARGAR PRODUCTOS
  // ========================================

  Future<void> loadProducts() async {
    try {
      final result = await productService.getProducts();

      if (!mounted) {
        return;
      }

      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ========================================
  // CERRAR SESIÓN
  // ========================================

  Future<void> logout() async {
    await authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoHome Store'),
        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
      return Center(child: Text('Error: $error'));
    }

    if (products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ListTile(
          title: Text(product.name),
          subtitle: Text(
            'Creado por: '
            '${product.createdByUsername}',
          ),
          trailing: Text('\$${product.price.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
