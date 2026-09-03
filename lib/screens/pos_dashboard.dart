import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/menu_data.dart';
import '../models/customer.dart';
import '../models/delivery_partner.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../widgets/order_panel.dart';
import '../widgets/pos_header.dart';
import '../widgets/product_card.dart';

class PosDashboard extends StatefulWidget {
  const PosDashboard({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  State<PosDashboard> createState() => _PosDashboardState();
}

class _PosDashboardState extends State<PosDashboard> {
  String _selectedCategory = 'Show All';
  String _customerType = 'Walkin Customer';
  CreditCustomer? _creditCustomer;
  DeliveryPartner? _deliveryPartner;
  String? _walkinPhone;
  final List<CartItem> _cart = [];

  List<Product> get _filteredProducts {
    return MenuData.products.where((product) {
      return _selectedCategory == 'Show All' ||
          product.category == _selectedCategory;
    }).toList();
  }

  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index] = _cart[index].copyWith(
          quantity: _cart[index].quantity + 1,
        );
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  Future<void> _addNote(CartItem item) async {
    final controller = TextEditingController(text: item.note);
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Note for ${item.product.name}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Extra spicy, no onion',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (note != null) {
      setState(() {
        final index = _cart.indexWhere(
          (cartItem) => cartItem.product.id == item.product.id,
        );
        if (index >= 0) {
          _cart[index] = _cart[index].copyWith(note: note);
        }
      });
    }
  }

  void _submitOrder() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before submitting')),
      );
      return;
    }

    final customerLabel =
        _customerType == 'Credit Customer' && _creditCustomer != null
            ? _creditCustomer!.name
            : _customerType == 'Delivery' && _deliveryPartner != null
                ? _deliveryPartner!.name
                : _customerType == 'Walkin Customer' &&
                        _walkinPhone != null &&
                        _walkinPhone!.isNotEmpty
                    ? 'Walkin ($_walkinPhone)'
                    : _customerType;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #84 submitted for $customerLabel'),
      ),
    );
    setState(_cart.clear);
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final width = MediaQuery.sizeOf(context).width;
    final showOrderPanel = width >= 1100;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              PosHeader(
                onLogout: widget.onLogout,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildMenuArea(products)),
                    if (showOrderPanel) _buildOrderPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: showOrderPanel
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.85,
                      child: _buildOrderPanel(),
                    );
                  },
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: Text('Order (${_cart.fold<int>(0, (s, i) => s + i.quantity)})'),
            ),
      ),
    );
  }

  Widget _buildOrderPanel() {
    return OrderPanel(
      orderNumber: 84,
      customerType: _customerType,
      cart: _cart,
      creditCustomers: MenuData.creditCustomers,
      deliveryPartners: MenuData.deliveryPartners,
      selectedCreditCustomer: _creditCustomer,
      selectedDeliveryPartner: _deliveryPartner,
      walkinPhone: _walkinPhone,
      onCustomerTypeChanged: (value) => setState(() {
        _customerType = value;
        if (value != 'Credit Customer') {
          _creditCustomer = null;
        }
        if (value != 'Delivery') {
          _deliveryPartner = null;
        }
        if (value != 'Walkin Customer') {
          _walkinPhone = null;
        }
      }),
      onCreditCustomerSelected: (customer) => setState(() {
        _customerType = 'Credit Customer';
        _creditCustomer = customer;
        _deliveryPartner = null;
        _walkinPhone = null;
      }),
      onDeliveryPartnerSelected: (partner) => setState(() {
        _customerType = 'Delivery';
        _deliveryPartner = partner;
        _creditCustomer = null;
        _walkinPhone = null;
      }),
      onWalkinPhoneSelected: (phone) => setState(() {
        _customerType = 'Walkin Customer';
        _creditCustomer = null;
        _deliveryPartner = null;
        if (phone != null) {
          _walkinPhone = phone.isEmpty ? null : phone;
        }
      }),
      onQtyChanged: (item, qty) {
        setState(() {
          final index = _cart.indexWhere(
            (cartItem) => cartItem.product.id == item.product.id,
          );
          if (index < 0) return;
          if (qty <= 0) {
            _cart.removeAt(index);
          } else {
            _cart[index] = _cart[index].copyWith(quantity: qty);
          }
        });
      },
      onRemove: (item) {
        setState(() {
          _cart.removeWhere(
            (cartItem) => cartItem.product.id == item.product.id,
          );
        });
      },
      onAddNote: _addNote,
      onSubmit: _submitOrder,
    );
  }

  Widget _buildMenuArea(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in MenuData.categories)
                _CategoryChip(
                  label: category,
                  selected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'No menu items found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          (constraints.maxWidth / 190).floor().clamp(2, 6);
                      return GridView.builder(
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onAdd: () => _addToCart(product),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
