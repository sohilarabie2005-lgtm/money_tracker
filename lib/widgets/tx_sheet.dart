import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/tx.dart';
import '../utils/helpers.dart';

/// Bottom sheet used for both adding and editing a transaction.
class TxSheet extends StatefulWidget {
  final Tx? editing;

  /// Returns an error message to show, or null if saved successfully.
  final String? Function(Tx tx) onSubmit;

  const TxSheet({super.key, this.editing, required this.onSubmit});

  @override
  State<TxSheet> createState() => _TxSheetState();
}

class _TxSheetState extends State<TxSheet> {
  late TxType _type;
  late String _category;
  late final TextEditingController _title;
  late final TextEditingController _amount;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _type = e?.type ?? TxType.expense;
    _category = (e != null && e.type == TxType.expense)
        ? e.category
        : expenseCategories.first;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(text: e == null ? '' : e.amount.toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (title.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a title and a valid amount.');
      return;
    }
    final tx = Tx(
      id: widget.editing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _type,
      category: _type == TxType.income ? 'Income' : _category,
      date: widget.editing?.date ?? DateTime.now(),
    );
    final error = widget.onSubmit(tx);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit transaction' : 'New transaction',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TxType>(
                segments: const [
                  ButtonSegment(
                      value: TxType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(
                      value: TxType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  _error = null;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              decoration:
                  appInputDecoration('Title', Icons.edit_outlined, fill: pageBg),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  appInputDecoration('Amount', Icons.attach_money, fill: pageBg),
            ),
            if (_type == TxType.expense) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: appInputDecoration(
                    'Category', Icons.category_outlined,
                    fill: pageBg),
                items: expenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: expenseRed.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: expenseRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: expenseRed)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submit,
                child: Text(isEdit ? 'Save changes' : 'Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
