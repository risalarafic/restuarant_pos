import 'package:flutter/material.dart';

import '../models/delivery_partner.dart';
import '../theme/app_colors.dart';

class DeliveryPartnerDialog extends StatefulWidget {
  const DeliveryPartnerDialog({
    super.key,
    required this.partners,
    this.selectedId,
  });

  final List<DeliveryPartner> partners;
  final String? selectedId;

  static Future<DeliveryPartner?> show(
    BuildContext context, {
    required List<DeliveryPartner> partners,
    String? selectedId,
  }) {
    return showDialog<DeliveryPartner>(
      context: context,
      builder: (context) => DeliveryPartnerDialog(
        partners: partners,
        selectedId: selectedId,
      ),
    );
  }

  @override
  State<DeliveryPartnerDialog> createState() => _DeliveryPartnerDialogState();
}

class _DeliveryPartnerDialogState extends State<DeliveryPartnerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DeliveryPartner> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.partners;
    return widget.partners
        .where((partner) => partner.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final partners = _filtered;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: size.width < 480 ? size.width - 40 : 440,
        height: (size.height * 0.6).clamp(320.0, 460.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Delivery',
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
                  hintText: 'Search delivery partner',
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
              child: partners.isEmpty
                  ? const Center(
                      child: Text(
                        'No delivery partners found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: partners.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final partner = partners[index];
                        final selected = partner.id == widget.selectedId;
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
                              partner.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            partner.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          trailing: selected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : const Icon(
                                  Icons.delivery_dining_outlined,
                                  color: AppColors.textSecondary,
                                ),
                          onTap: () => Navigator.pop(context, partner),
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
