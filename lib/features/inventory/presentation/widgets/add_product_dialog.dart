/// Inventory — Add Product dialog.
library;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexus/core/theme/app_colors.dart';
import 'package:nexus/core/database/app_database.dart';
import 'package:nexus/features/inventory/providers/inventory_providers.dart';
import 'package:nexus/l10n/app_localizations.dart';
import 'package:nexus/core/providers/currency_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'General');
  final _stockCtrl = TextEditingController(text: '0');
  final _purchaseCtrl = TextEditingController();
  final _sellingCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _stockCtrl.dispose();
    _purchaseCtrl.dispose();
    _sellingCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final entry = ProductsCompanion.insert(
      name: _nameCtrl.text.trim(),
      category: Value(_categoryCtrl.text.trim()),
      stockQuantity: Value(int.tryParse(_stockCtrl.text) ?? 0),
      purchaseRate: double.tryParse(_purchaseCtrl.text) ?? 0.0,
      sellingPrice: double.tryParse(_sellingCtrl.text) ?? 0.0,
    );

    await ref.read(addProductProvider)(entry);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final String currencySymbol = switch (currency) {
      'PKR' => 'Rs. ',
      'EUR' => '€ ',
      'GBP' => '£ ',
      _ => '\$ ',
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_box_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Text('Add Product',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Fields ──────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'e.g. ThinkPad X1 Carbon',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g. Electronics',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _stockCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _purchaseCtrl,
                          decoration: InputDecoration(
                            labelText: 'Purchase Rate',
                            prefixText: currencySymbol,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _sellingCtrl,
                          decoration: InputDecoration(
                            labelText: 'Selling Price',
                            prefixText: currencySymbol,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Actions ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppLocalizations.of(context)!.addProduct),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
