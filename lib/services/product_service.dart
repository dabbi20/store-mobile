import '../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService({required this.apiClient});

  // ========================================
  // OBTENER PRODUCTOS
  // ========================================

  Future<List<Product>> getProducts() async {
    final data = await apiClient.get('/products');

    final List<dynamic> productsJson = data;

    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  // ========================================
  // CREAR PRODUCTO
  // ========================================

  Future<Product> createProduct({
    required String name,
    required double price,
  }) async {
    final data = await apiClient.post('/products', {
      'name': name,
      'price': price,
    }, authenticated: true);

    return Product.fromJson(data['product']);
  }

// ========================================
// ACTUALIZAR PRODUCTO
// ========================================

Future<Product> updateProduct({
  required int id,
  required String name,
  required double price,
}) async {
  final data = await apiClient.patch(
    '/products/$id',
    {
      'name': name,
      'price': price,
    },
    authenticated: true,
  );

  return Product.fromJson(
    data['product'],
  );
}
}

