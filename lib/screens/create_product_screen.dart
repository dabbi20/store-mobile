import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../services/product_service.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  // ========================================
  // SERVICIO
  // ========================================

  final ProductService productService = ProductService(apiClient: ApiClient());

  // ========================================
  // CONTROLADORES
  // ========================================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  // ========================================
  // ESTADOS
  // ========================================

  bool isLoading = false;
  String? error;

  // ========================================
  // CREAR PRODUCTO
  // ========================================

  Future<void> createProduct() async {
    final name = nameController.text.trim();

    final price = double.tryParse(priceController.text.trim());

    // ========================================
    // VALIDACIONES
    // ========================================

    if (name.isEmpty) {
      setState(() {
        error = 'El nombre es obligatorio';
      });

      return;
    }

    if (price == null || price <= 0) {
      setState(() {
        error = 'Ingresa un precio válido';
      });

      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await productService.createProduct(name: name, price: price);

      if (!mounted) {
        return;
      }

      // true significa que el producto
      // fue creado correctamente.
      Navigator.pop(context, true);
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
    nameController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear producto')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.add_shopping_cart, size: 64),

                const SizedBox(height: 24),

                // ========================================
                // NOMBRE
                // ========================================
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================
                // PRECIO
                // ========================================
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) {
                      createProduct();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
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
                FilledButton.icon(
                  onPressed: isLoading ? null : createProduct,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('Crear producto'),
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
