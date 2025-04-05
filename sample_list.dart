import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_helper.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/nav_arguments.dart';
import 'product_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  NavigationArguments? psargs;
  // For multi-select mode, track selected products.
  final Set<Product> _selectedProducts = {};
  // Store pre-selected product IDs.
  final Set<int> _preSelectedIds = {};

  @override
  void initState() {
    super.initState();
    // Retrieve navigation arguments after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        psargs =
            ModalRoute.of(context)?.settings.arguments as NavigationArguments?;
        if (psargs?.data['preSelectedIds'] != null) {
          List<dynamic> ids = psargs!.data['preSelectedIds'];
          _preSelectedIds.addAll(ids.cast<int>());
        }
      });
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final companyId = authProvider.selectedCompanyId;
    if (companyId != null) {
      final products =
          await DatabaseHelper.instance.getProductsByCompanyId(companyId);
      setState(() {
        _products = products;
        // Pre-select products that match the pre-selected IDs.
        for (var product in products) {
          if (_preSelectedIds.contains(product.id)) {
            _selectedProducts.add(product);
          }
        }
      });
    }
  }

  // Multi-select: toggle the selected product.
  void _toggleSelection(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  // Confirm multi-selection and return the list of selected products.
  void _confirmSelection() {
    Navigator.pop(context, _selectedProducts.toList());
  }

  Future<void> _navigateToAddProduct() async {
    // In multi-select mode, you might not allow adding a new product.
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
    // Determine mode; if no navigation parameters are passed, default to single-select.
    final bool isMultiSelect = psargs?.data['multiSelect'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          psargs != null ? 'Select Products' : 'Manage Products',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 45, 122),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: isMultiSelect
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed:
                      _selectedProducts.isNotEmpty ? _confirmSelection : null,
                ),
              ]
            : null,
      ),
      floatingActionButton: isMultiSelect
          ? null
          : FloatingActionButton(
              onPressed: _navigateToAddProduct,
              backgroundColor: const Color.fromARGB(255, 0, 45, 122),
              shape: const CircleBorder(),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(product.productName),
                      subtitle: Text(
                        product.price != null
                            ? 'Price: ${product.price}'
                            : 'No price set',
                      ),
                      trailing: isMultiSelect
                          ? Checkbox(
                              value: _selectedProducts.contains(product),
                              onChanged: (_) => _toggleSelection(product),
                            )
                          : product.status == 1
                              ? const Icon(Icons.arrow_forward_ios,
                                  color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red),
                      onTap: () {
                        if (isMultiSelect) {
                          _toggleSelection(product);
                        } else {
                          // In single-select mode, navigate to the product dialog for editing.
                          _navigateToEditProduct(product);
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
