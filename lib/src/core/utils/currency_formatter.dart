/// Currency and number formatting utilities
class CurrencyFormatter {
  /// Format number as currency (IDR)
  static String formatCurrency(num amount, {String symbol = 'Rp '}) {
    final formatter = _CurrencyFormatterHelper();
    return formatter.format(amount, symbol: symbol);
  }

  /// Format as price with 2 decimal places
  static String formatPrice(num price) {
    return price.toStringAsFixed(2);
  }

  /// Parse currency string to number
  static num? parseCurrency(String value) {
    try {
      final cleaned = value
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return num.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format number with thousand separator
  static String formatNumber(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => '.',
    );
  }
}

class _CurrencyFormatterHelper {
  String format(num amount, {String symbol = 'Rp '}) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.');
    return '$symbol$formatted';
  }
}
