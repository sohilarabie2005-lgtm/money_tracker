import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/tx.dart';
import '../services/storage_service.dart';
import '../utils/helpers.dart';
import '../widgets/empty_hint.dart';
import '../widgets/summary_tile.dart';
import '../widgets/tx_sheet.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String userName;

  const HomeScreen({super.key, required this.email, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tx> _txs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.load(widget.email);
    if (!mounted) return;
    setState(() {
      _txs = saved;
      _loading = false;
    });
  }

  Future<void> _persist() => StorageService.save(widget.email, _txs);

  static double _balanceOf(List<Tx> list) {
    double total = 0;
    for (final t in list) {
      total += t.type == TxType.income ? t.amount : -t.amount;
    }
    return total;
  }

  double get _income => _txs
      .where((t) => t.type == TxType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get _expenses => _txs
      .where((t) => t.type == TxType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get _balance => _balanceOf(_txs);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final t in _txs.where((t) => t.type == TxType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Adds a new transaction or replaces [editing]. Returns an error message
  /// if the change would push the balance below zero, otherwise null.
  String? _trySave(Tx tx, {Tx? editing}) {
    final others = _txs.where((t) => t.id != editing?.id).toList();
    final available = _balanceOf(others);
    final next = [tx, ...others]..sort((a, b) => b.date.compareTo(a.date));

    if (_balanceOf(next) < 0) {
      if (tx.type == TxType.expense) {
        return 'Not enough balance. You can spend up to '
            '${money(available < 0 ? 0 : available)}.';
      }
      return 'This change would make your balance negative.';
    }
    setState(() => _txs = next);
    _persist();
    return null;
  }

  void _openSheet({Tx? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TxSheet(
        editing: editing,
        onSubmit: (tx) => _trySave(tx, editing: editing),
      ),
    );
  }

  /// Asks for confirmation, and blocks deletion if it would leave a
  /// negative balance (e.g. deleting an income that was already spent).
  Future<bool> _confirmDelete(Tx t) async {
    final remaining = _txs.where((x) => x.id != t.id).toList();
    if (_balanceOf(remaining) < 0) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded,
              color: expenseRed, size: 40),
          title: const Text("Can't delete"),
          content: const Text(
              'Deleting this income would make your balance negative.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK')),
          ],
        ),
      );
      return false;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${t.title}" will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Delete', style: TextStyle(color: expenseRed))),
        ],
      ),
    );
    return ok ?? false;
  }

  void _remove(Tx t) {
    if (!mounted) return;
    setState(() => _txs.removeWhere((x) => x.id == t.id));
    _persist();
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categories = _byCategory;
    final totalExpenses = _expenses;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        onPressed: () => _openSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Header with the logged-in user's name
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: navy,
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      Text(widget.userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: navy)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Log out',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: navy),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available balance',
                      style: TextStyle(color: Color(0xFFB9C7EA))),
                  const SizedBox(height: 4),
                  Text(money(_balance),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryTile(
                          label: 'Income',
                          value: money(_income),
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryTile(
                          label: 'Total Expenses',
                          value: money(totalExpenses),
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Expense categories
            const Text('Expense Categories',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const EmptyHint('No expenses yet.')
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: categories.entries.map((e) {
                    final share =
                        totalExpenses == 0 ? 0.0 : e.value / totalExpenses;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(iconFor(e.key), size: 20, color: navy),
                              const SizedBox(width: 10),
                              Expanded(child: Text(e.key)),
                              Text(money(e.value),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: share,
                              minHeight: 7,
                              color: navy,
                              backgroundColor: const Color(0xFFE3E9F5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 26),

            // Recent transactions
            const Text('Recent Transactions',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 4),
            Text('Tap to edit • swipe or tap the bin to delete',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 12),
            if (_txs.isEmpty)
              const EmptyHint('No transactions yet. Tap Add to start.')
            else
              ..._txs.map(_buildTile),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(Tx t) {
    final isIncome = t.type == TxType.income;
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(t),
      onDismissed: (_) => _remove(t),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: expenseRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          onTap: () => _openSheet(editing: t),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE3E9F5),
            child: Icon(iconFor(t.category), color: navy, size: 20),
          ),
          title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${t.category} • ${shortDate(t.date)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${money(t.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isIncome ? incomeGreen : expenseRed,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () async {
                  if (await _confirmDelete(t)) _remove(t);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
