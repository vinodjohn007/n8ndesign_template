import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductDialogScreen extends StatefulWidget {
  final Product? product;

  const ProductDialogScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDialogScreen> createState() => _ProductDialogScreenState();
}

class _ProductDialogScreenState extends State<ProductDialogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _status = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Existing product => Edit mode
      _nameController.text = widget.product!.productName;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text =
          widget.product!.price != null ? widget.product!.price.toString() : '';
      _status = widget.product!.status == 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final companyId = authProvider.selectedCompanyId;

    if (companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No company selected')),
      );
      return;
    }

    final productToSave = Product(
      id: widget.product?.id, // null if new product
      productName: _nameController.text,
      description: _descriptionController.text,
      price: _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text)
          : null,
      status: _status ? 1 : 0,
      companyId: companyId,
    );

    try {
      if (widget.product == null) {
        // Insert new product
        await DatabaseHelper.instance.insertProduct(productToSave);
      } else {
        // Update existing product
        await DatabaseHelper.instance.updateProduct(productToSave);
      }
      Navigator.pop(context, true); // Return 'true' to refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) return; // No product to delete
    try {
      await DatabaseHelper.instance.deleteProduct(widget.product!.id!);
      Navigator.pop(context, true); // Return 'true' to refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.product != null;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Product Name
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // Status Switch
                    SwitchListTile(
                      title: const Text('Status'),
                      subtitle: Text(_status ? 'Active' : 'Inactive'),
                      value: _status,
                      onChanged: (value) {
                        setState(() {
                          _status = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Bottom Buttons
              Row(
                children: [
                  if (isEditMode)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _deleteProduct,
                        child: const Text('DELETE'),
                      ),
                    ),
                  if (isEditMode) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('SAVE'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 45, 122),
                          foregroundColor: Colors.white,
                        ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
