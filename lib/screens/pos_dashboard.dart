import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/dashboard_api.dart';
import '../api/save_order_api.dart';
import '../auth/auth_session.dart';
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
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<PosDashboard> createState() => _PosDashboardState();
}

class _PosDashboardState extends State<PosDashboard> {
  final _dashboardApi = DashboardApi();
  final _saveOrderApi = SaveOrderApi();

  // ── loading state ──────────────────────────────────────────────────────────
  bool _loading = true;
  bool _isSubmitting = false;
  String? _loadError;
  DashboardData? _data;
  String? _lastReceipt;

  // ── UI state ───────────────────────────────────────────────────────────────
  String _selectedCategory = 'Show All';
  String _customerType = 'Walkin Customer';
  CreditCustomer? _creditCustomer;
  DeliveryPartner? _deliveryPartner;
  String? _walkinPhone;
  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await _dashboardApi.load(widget.session);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        // Reset category selection
        _selectedCategory = data.categories.isNotEmpty
            ? data.categories.first
            : 'Show All';
      });
    } on DashboardException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load dashboard. Please try again.';
        _loading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final products = _data?.products ?? [];
    if (_selectedCategory == 'Show All') return products;
    return products
        .where((p) => p.category == _selectedCategory)
        .toList();
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

  ({String customerId, String phone}) _orderCustomer() {
    if (_customerType == 'Credit Customer' && _creditCustomer != null) {
      return (
        customerId: _creditCustomer!.id,
        phone: _creditCustomer!.phone,
      );
    }
    if (_customerType == 'Delivery' && _deliveryPartner != null) {
      return (customerId: _deliveryPartner!.id, phone: '');
    }

    final phone = _walkinPhone ?? '';
    final walkins = _data?.walkinCustomers ?? [];
    CreditCustomer? match;
    if (phone.isNotEmpty) {
      for (final customer in walkins) {
        if (customer.phone == phone) {
          match = customer;
          break;
        }
      }
    }
    match ??= walkins.isNotEmpty ? walkins.first : null;
    return (customerId: match?.id ?? '1', phone: phone);
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before submitting')),
      );
      return;
    }
    if (_customerType == 'Credit Customer' && _creditCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a credit customer')),
      );
      return;
    }
    if (_customerType == 'Delivery' && _deliveryPartner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery partner')),
      );
      return;
    }

    final customer = _orderCustomer();
    setState(() => _isSubmitting = true);
    try {
      final result = await _saveOrderApi.save(
        session: widget.session,
        customerId: customer.customerId,
        phone: customer.phone,
        cart: List<CartItem>.from(_cart),
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _lastReceipt = null;
        _customerType = 'Walkin Customer';
        _creditCustomer = null;
        _deliveryPartner = null;
        _walkinPhone = null;
        _cart.clear();
      });
      final receipt = result.lastReceipt;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            receipt == null || receipt.isEmpty
                ? (result.message ?? 'Order saved')
                : 'Order saved · Receipt $receipt',
          ),
        ),
      );
    } on SaveOrderException catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save order. Please try again.')),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
                restaurantName: widget.session.restaurantName,
                onLogout: widget.onLogout,
              ),
              Expanded(child: _buildBody(showOrderPanel)),
            ],
          ),
        ),
        floatingActionButton: showOrderPanel || _data == null
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
                label: Text(
                  'Order (${_cart.fold<int>(0, (s, i) => s + i.quantity)})',
                ),
              ),
      ),
    );
  }

  Widget _buildBody(bool showOrderPanel) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: _buildMenuArea()),
        if (showOrderPanel) _buildOrderPanel(),
      ],
    );
  }

  Widget _buildOrderPanel() {
    final data = _data!;
    return OrderPanel(
      orderNumber: _lastReceipt ?? 'New',
      customerType: _customerType,
      cart: _cart,
      creditCustomers: data.creditCustomers,
      deliveryPartners: data.deliveryPartners,
      selectedCreditCustomer: _creditCustomer,
      selectedDeliveryPartner: _deliveryPartner,
      walkinPhone: _walkinPhone,
      onCustomerTypeChanged: (value) => setState(() {
        _customerType = value;
        if (value != 'Credit Customer') _creditCustomer = null;
        if (value != 'Delivery') _deliveryPartner = null;
        if (value != 'Walkin Customer') _walkinPhone = null;
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
      isSubmitting: _isSubmitting,
    );
  }

  Widget _buildMenuArea() {
    final data = _data!;
    final products = _filteredProducts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category chips ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in data.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: category,
                      selected: _selectedCategory == category,
                      onTap: () =>
                          setState(() => _selectedCategory = category),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── Product grid ───────────────────────────────────────────────────
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
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
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

// ── Category chip ─────────────────────────────────────────────────────────────
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
