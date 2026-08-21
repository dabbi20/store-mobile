import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  final ProductService productService =
      ProductService(
    apiClient: ApiClient(),
  );

  List<Product> products = [];

  bool isLoading = true;

  String? error;

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result =
          await productService.getProducts();

      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EcoHome Store',
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Text(
          'Error: $error',
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos disponibles',
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ListTile(
          title: Text(
            product.name,
          ),
          subtitle: Text(
            'Creado por: '
            '${product.createdByUsername}',
          ),
          trailing: Text(
            '\$${product.price.toStringAsFixed(2)}',
          ),
        );
      },
    );
  }
}