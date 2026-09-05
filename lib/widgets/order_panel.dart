import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../models/delivery_partner.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import 'credit_customer_dialog.dart';
import 'delivery_partner_dialog.dart';
import 'walkin_phone_dialog.dart';

class OrderPanel extends StatelessWidget {
  const OrderPanel({
    super.key,
    required this.orderNumber,
    required this.customerType,
    required this.cart,
    required this.creditCustomers,
    required this.deliveryPartners,
    this.selectedCreditCustomer,
    this.selectedDeliveryPartner,
    this.walkinPhone,
    required this.onCustomerTypeChanged,
    required this.onCreditCustomerSelected,
    required this.onDeliveryPartnerSelected,
    required this.onWalkinPhoneSelected,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onAddNote,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final String orderNumber;
  final String customerType;
  final List<CartItem> cart;
  final List<CreditCustomer> creditCustomers;
  final List<DeliveryPartner> deliveryPartners;
  final CreditCustomer? selectedCreditCustomer;
  final DeliveryPartner? selectedDeliveryPartner;
  final String? walkinPhone;
  final ValueChanged<String> onCustomerTypeChanged;
  final ValueChanged<CreditCustomer> onCreditCustomerSelected;
  final ValueChanged<DeliveryPartner> onDeliveryPartnerSelected;
  final ValueChanged<String?> onWalkinPhoneSelected;
  final void Function(CartItem item, int qty) onQtyChanged;
  final ValueChanged<CartItem> onRemove;
  final ValueChanged<CartItem> onAddNote;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  static const customerTypes = [
    'Credit Customer',
    'Walkin Customer',
    'Delivery',
  ];

  double get subTotal => cart.fold(0, (sum, item) => sum + item.amount);

  double get total => subTotal;

  int get itemCount => cart.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _onCustomerTypeTap(BuildContext context, String type) async {
    if (type == 'Credit Customer') {
      final customer = await CreditCustomerDialog.show(
        context,
        customers: creditCustomers,
        selectedId: selectedCreditCustomer?.id,
      );
      if (customer != null) {
        onCreditCustomerSelected(customer);
      }
      return;
    }

    if (type == 'Delivery') {
      final partner = await DeliveryPartnerDialog.show(
        context,
        partners: deliveryPartners,
        selectedId: selectedDeliveryPartner?.id,
      );
      if (partner != null) {
        onDeliveryPartnerSelected(partner);
      }
      return;
    }

    if (type == 'Walkin Customer') {
      final phone = await WalkinPhoneDialog.show(
        context,
        initialPhone: walkinPhone,
      );
      onWalkinPhoneSelected(phone);
      return;
    }

    onCustomerTypeChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #$orderNumber',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < customerTypes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _CustomerTypeChip(
                          label: customerTypes[i],
                          selected: customerType == customerTypes[i],
                          onTap: () => _onCustomerTypeTap(
                            context,
                            customerTypes[i],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (customerType == 'Credit Customer' &&
                    selectedCreditCustomer != null) ...[
                  const SizedBox(height: 10),
                  _SelectedCreditCustomer(customer: selectedCreditCustomer!),
                ],
                if (customerType == 'Walkin Customer' &&
                    walkinPhone != null &&
                    walkinPhone!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _SelectedWalkinPhone(phone: walkinPhone!),
                ],
                if (customerType == 'Delivery' &&
                    selectedDeliveryPartner != null) ...[
                  const SizedBox(height: 10),
                  _SelectedDeliveryPartner(partner: selectedDeliveryPartner!),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'ITEM NAME',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    'PRICE',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    'AMOUNT',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 28),
              ],
            ),
          ),
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'No items added yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => onAddNote(item),
                                    child: Text(
                                      item.note == null || item.note!.isEmpty
                                          ? 'Add Note'
                                          : item.note!,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _QtyControl(
                                quantity: item.quantity,
                                onMinus: () =>
                                    onQtyChanged(item, item.quantity - 1),
                                onPlus: () =>
                                    onQtyChanged(item, item.quantity + 1),
                              ),
                            ),
                            SizedBox(
                              width: 52,
                              child: Text(
                                item.product.price.toStringAsFixed(0),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 64,
                              child: Text(
                                item.amount.toStringAsFixed(0),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => onRemove(item),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                                size: 18,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                _TotalRow(label: 'Items count', value: '$itemCount'),
                _TotalRow(
                  label: 'Sub Total',
                  value: 'QAR ${subTotal.toStringAsFixed(2)}',
                ),
                _TotalRow(
                  label: 'Total',
                  value: 'QAR ${total.toStringAsFixed(2)}',
                  emphasize: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTypeChip extends StatelessWidget {
  const _CustomerTypeChip({
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedCreditCustomer extends StatelessWidget {
  const _SelectedCreditCustomer({required this.customer});

  final CreditCustomer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD8C7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${customer.name}  ·  ${customer.phone}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedWalkinPhone extends StatelessWidget {
  const _SelectedWalkinPhone({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD8C7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              phone,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDeliveryPartner extends StatelessWidget {
  const _SelectedDeliveryPartner({required this.partner});

  final DeliveryPartner partner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD8C7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.delivery_dining_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              partner.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QtyBtn(icon: Icons.remove, onTap: onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _QtyBtn(icon: Icons.add, onTap: onPlus),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
      fontSize: emphasize ? 15 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}