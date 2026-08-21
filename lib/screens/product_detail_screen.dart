import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final User currentUser;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.currentUser,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ========================================
  // SERVICIOS
  // ========================================

  final ProductService productService = ProductService(apiClient: ApiClient());

  // ========================================
  // PRODUCTO ACTUAL
  // ========================================

  late Product product;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    product = widget.product;
  }

  // ========================================
  // COMPROBAR PERMISOS
  // ========================================

  bool get canManageProduct {
    return widget.currentUser.role == 'admin' &&
        widget.currentUser.id == product.createdBy;
  }

  // ========================================
  // FORMATEAR FECHA
  // ========================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // ========================================
  // EDITAR PRODUCTO
  // ========================================

  Future<void> editProduct() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (updated != true) {
      return;
    }

    try {
      final products = await productService.getProducts();

      final updatedProduct = products.firstWhere(
        (item) => item.id == product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        product = updatedProduct;
      });
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
  // ELIMINAR PRODUCTO
  // ========================================

  Future<void> deleteProduct() async {
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

      Navigator.pop(context, true);
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
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ========================================
                    // ICONO
                    // ========================================

                    const Icon(Icons.inventory_2_outlined, size: 80),

                    const SizedBox(height: 24),

                    // ========================================
                    // NOMBRE
                    // ========================================
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    // ========================================
                    // PRECIO
                    // ========================================
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 32),

                    const Divider(),

                    const SizedBox(height: 16),

                    // ========================================
                    // ID
                    // ========================================
                    _DetailRow(
                      icon: Icons.tag,
                      title: 'ID',
                      value: product.id.toString(),
                    ),

                    // ========================================
                    // CREADO POR
                    // ========================================
                    _DetailRow(
                      icon: Icons.person_outline,
                      title: 'Creado por',
                      value: product.createdByUsername ?? 'Desconocido',
                    ),

                    // ========================================
                    // FECHA DE CREACIÓN
                    // ========================================
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Fecha de creación',
                      value: formatDate(product.createdAt),
                    ),

                    // ========================================
                    // ÚLTIMA ACTUALIZACIÓN
                    // ========================================
                    _DetailRow(
                      icon: Icons.update,
                      title: 'Última actualización',
                      value: formatDate(product.updatedAt),
                    ),

                    // ========================================
                    // ACCIONES
                    // ========================================
                    if (canManageProduct) ...[
                      const SizedBox(height: 24),

                      const Divider(),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_user_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'Puedes administrar este producto',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // ========================================
                          // EDITAR
                          // ========================================

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: editProduct,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar'),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ========================================
                          // ELIMINAR
                          // ========================================
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: deleteProduct,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Eliminar'),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ========================================
// FILA DE INFORMACIÓN
// ========================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
