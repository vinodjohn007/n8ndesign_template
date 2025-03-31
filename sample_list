import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../database/database_helper.dart';
import 'product_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final companyId = authProvider.selectedCompanyId;

    if (companyId != null) {
      final products = await DatabaseHelper.instance.getProductsByCompanyId(companyId);
      setState(() {
        _products = products;
      });
    }
  }

  Future<void> _navigateToAddProduct() async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductDialogScreen(),
      ),
    );

    if (updated == true) {
      _loadProducts();
    }
  }

  Future<void> _navigateToEditProduct(Product product) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDialogScreen(product: product),
      ),
    );

    if (updated == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Products',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 45, 122),
        iconTheme: const IconThemeData(color: Colors.white), // Back button color white
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: const Color.fromARGB(255, 0, 45, 122),
        shape: const CircleBorder(), // Explicitly rounded shape
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _products.isEmpty
            ? const Center(child: Text('No products found'))
            : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(product.productName),
                      subtitle: Text(
                        product.price != null ? 'Price: ${product.price}' : 'No price set',
                      ),
                      trailing: product.status == 1
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                      onTap: () => _navigateToEditProduct(product),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
