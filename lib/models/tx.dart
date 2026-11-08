enum TxType { income, expense }

class Tx {
  final String id;
  final String title;
  final double amount;
  final TxType type;
  final String category;
  final DateTime date;

  const Tx({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TxType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => TxType.expense,
        ),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
