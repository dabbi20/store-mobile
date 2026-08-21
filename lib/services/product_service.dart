import '../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService({
    required this.apiClient,
  });

  Future<List<Product>> getProducts() async {
    final data = await apiClient.get('/products');

    final List<dynamic> productsJson = data;

    return productsJson
        .map(
          (json) => Product.fromJson(json),
        )
        .toList();
  }
}