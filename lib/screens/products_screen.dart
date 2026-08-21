import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class ProductsScreen extends StatefulWidget {
  final User currentUser;

  const ProductsScreen({super.key, required this.currentUser});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // ========================================
  // SERVICIOS
  // ========================================

  final ProductService productService = ProductService(apiClient: ApiClient());

  final AuthService authService = AuthService();

  final UserService userService = UserService();

  // ========================================
  // ESTADOS
  // ========================================

  List<Product> products = [];

  bool isLoading = true;

  String? error;

  int productsCreated = 0;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    loadData();
  }

  // ========================================
  // CARGAR DATOS
  // PRODUCTOS + ESTADÍSTICAS
  // ========================================

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final result = await Future.wait([
        productService.getProducts(),
        userService.getMyStats(),
      ]);

      final loadedProducts = result[0] as List<Product>;

      final stats = result[1] as Map<String, dynamic>;

      if (!mounted) {
        return;
      }

      setState(() {
        products = loadedProducts;

        productsCreated = (stats['products_created'] as num?)?.toInt() ?? 0;

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
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ========================================
  // CARGAR ESTADÍSTICAS
  // ========================================

  Future<void> loadStats() async {
    try {
      final stats = await userService.getMyStats();

      if (!mounted) {
        return;
      }

      setState(() {
        productsCreated = (stats['products_created'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron actualizar las estadísticas: $message'),
        ),
      );
    }
  }

  // ========================================
  // RECARGAR CATÁLOGO COMPLETO
  // ========================================

  Future<void> refreshData() async {
    await Future.wait([loadProducts(), loadStats()]);
  }

  // ========================================
  // IR A CREAR PRODUCTO
  // ========================================

  Future<void> goToCreateProduct() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateProductScreen()),
    );

    if (created == true) {
      await refreshData();
    }
  }

  // ========================================
  // IR AL CHAT
  // ========================================

  Future<void> goToChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(currentUser: widget.currentUser),
      ),
    );
  }

  // ========================================
  // IR AL DETALLE DEL PRODUCTO
  // ========================================

  Future<void> goToProductDetail(Product product) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          currentUser: widget.currentUser,
        ),
      ),
    );

    if (changed == true) {
      await refreshData();
    }
  }

  // ========================================
  // IR A EDITAR PRODUCTO
  // ========================================

  Future<void> goToEditProduct(Product product) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (updated == true) {
      await refreshData();
    }
  }

  // ========================================
  // ELIMINAR PRODUCTO
  // ========================================

  Future<void> deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await productService.deleteProduct(id: product.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${product.name}" eliminado correctamente')),
      );

      await refreshData();
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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
          // ========================================
          // USUARIO + CONTADOR
          // ========================================

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${widget.currentUser.username} '
                '($productsCreated)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // ========================================
          // CHAT
          // ========================================
          IconButton(
            onPressed: goToChat,
            tooltip: 'Chat',
            icon: const Icon(Icons.chat_bubble_outline),
          ),

          // ========================================
          // PERFIL
          // ========================================
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle_outlined),
          ),

          // ========================================
          // CERRAR SESIÓN
          // ========================================
          IconButton(
            onPressed: logout,
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // ========================================
      // CREAR PRODUCTO
      // SOLO ADMIN
      // ========================================
      floatingActionButton: widget.currentUser.role == 'admin'
          ? FloatingActionButton(
              onPressed: goToCreateProduct,
              tooltip: 'Crear producto',
              child: const Icon(Icons.add),
            )
          : null,

      body: buildBody(),
    );
  }

  // ========================================
  // CONTENIDO
  // ========================================

  Widget buildBody() {
    // ========================================
    // CARGANDO
    // ========================================

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ========================================
    // ERROR
    // ========================================

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    // ========================================
    // SIN PRODUCTOS
    // ========================================

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text('No hay productos disponibles')),
          ],
        ),
      );
    }

    // ========================================
    // LISTA DE PRODUCTOS
    // ========================================

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          // ========================================
          // PERMISOS DEL PRODUCTO
          // ========================================

          final canManageProduct =
              widget.currentUser.role == 'admin' &&
              product.createdBy == widget.currentUser.id;

          // ========================================
          // PRODUCTO
          // ========================================

          return ListTile(
            // ========================================
            // ABRIR DETALLE
            // ========================================

            onTap: () {
              goToProductDetail(product);
            },

            title: Text(product.name),

            subtitle: Text(
              'Creado por: '
              '${product.createdByUsername ?? 'Desconocido'}',
            ),

            // ========================================
            // PRECIO + ACCIONES
            // ========================================
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${product.price.toStringAsFixed(2)}'),

                // ========================================
                // ACCIONES SOLO SI TIENE PERMISO
                // ========================================
                if (canManageProduct) ...[
                  const SizedBox(width: 8),

                  // ========================================
                  // EDITAR
                  // ========================================
                  IconButton(
                    onPressed: () {
                      goToEditProduct(product);
                    },
                    tooltip: 'Editar producto',
                    icon: const Icon(Icons.edit_outlined),
                  ),

                  // ========================================
                  // ELIMINAR
                  // ========================================
                  IconButton(
                    onPressed: () {
                      deleteProduct(product);
                    },
                    tooltip: 'Eliminar producto',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
