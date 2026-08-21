import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {
  // ========================================
  // SERVICIO
  // ========================================

  final ProductService productService = ProductService(
    apiClient: ApiClient(),
  );

  // ========================================
  // CONTROLADORES
  // ========================================

  late final TextEditingController nameController;
  late final TextEditingController priceController;

  // ========================================
  // ESTADOS
  // ========================================

  bool isLoading = false;
  String? error;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product.name,
    );

    priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2),
    );
  }

  // ========================================
  // ACTUALIZAR PRODUCTO
  // ========================================

  Future<void> updateProduct() async {
    final name = nameController.text.trim();

    final price = double.tryParse(
      priceController.text.trim(),
    );

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
      await productService.updateProduct(
        id: widget.product.id,
        name: name,
        price: price,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
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
      appBar: AppBar(
        title: const Text(
          'Editar producto',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 64,
                ),

                const SizedBox(
                  height: 24,
                ),

                // ========================================
                // NOMBRE
                // ========================================

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(
                      Icons.inventory_2_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ========================================
                // PRECIO
                // ========================================

                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) {
                      updateProduct();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(
                      Icons.attach_money,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ========================================
                // ERROR
                // ========================================

                if (error != null) ...[
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],

                // ========================================
                // BOTÓN
                // ========================================

                FilledButton.icon(
                  onPressed:
                      isLoading ? null : updateProduct,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                        ),
                  label: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'Guardar cambios',
                    ),
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