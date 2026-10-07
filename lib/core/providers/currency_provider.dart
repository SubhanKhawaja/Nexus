import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final currencyProvider = StateProvider<String>((ref) => 'PKR');

final currencyFormatterProvider = Provider<NumberFormat>((ref) {
  final currency = ref.watch(currencyProvider);
  String symbol;
  switch (currency) {
    case 'PKR':
      symbol = 'Rs. ';
      break;
    case 'USD':
      symbol = '\$';
      break;
    case 'EUR':
      symbol = '€';
      break;
    case 'GBP':
      symbol = '£';
      break;
    default:
      symbol = '\$';
  }
  return NumberFormat.currency(symbol: symbol, decimalDigits: 2);
});
