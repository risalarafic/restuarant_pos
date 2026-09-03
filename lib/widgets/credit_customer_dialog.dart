import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_colors.dart';

class CreditCustomerDialog extends StatefulWidget {
  const CreditCustomerDialog({
    super.key,
    required this.customers,
    this.selectedId,
  });

  final List<CreditCustomer> customers;
  final String? selectedId;

  static Future<CreditCustomer?> show(
    BuildContext context, {
    required List<CreditCustomer> customers,
    String? selectedId,
  }) {
    return showDialog<CreditCustomer>(
      context: context,
      builder: (context) => CreditCustomerDialog(
        customers: customers,
        selectedId: selectedId,
      ),
    );
  }

  @override
  State<CreditCustomerDialog> createState() => _CreditCustomerDialogState();
}

class _CreditCustomerDialogState extends State<CreditCustomerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CreditCustomer> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.customers;
    return widget.customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.phone.replaceAll(' ', '').contains(query.replaceAll(' ', ''));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final customers = _filtered;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: size.width < 480 ? size.width - 40 : 440,
        height: (size.height * 0.75).clamp(360.0, 560.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Credit Customers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.chipBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Text(
                        'No customers found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: customers.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        final selected = customer.id == widget.selectedId;
                        return ListTile(
                          selected: selected,
                          selectedTileColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: selected
                                ? AppColors.primary
                                : const Color(0xFFFFE4D6),
                            foregroundColor: selected
                                ? Colors.white
                                : AppColors.primary,
                            child: Text(
                              customer.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            customer.phone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            customer.outstanding <= 0
                                ? 'Settled'
                                : 'QAR ${customer.outstanding.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: customer.outstanding <= 0
                                  ? AppColors.billPay
                                  : AppColors.primary,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, customer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
