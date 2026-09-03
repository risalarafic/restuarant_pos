class CreditCustomer {
  const CreditCustomer({
    required this.id,
    required this.name,
    required this.phone,
    this.outstanding = 0,
  });

  final String id;
  final String name;
  final String phone;
  final double outstanding;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
