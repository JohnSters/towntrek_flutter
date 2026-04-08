import 'package:intl/intl.dart';

/// Matches server [PropertyListingDisplayHelper]: rent shows "/ month", sale does not.
/// `listingType`: 0 = ForRent, 1 = ForSale
String formatPropertyListingPrice({
  required int listingType,
  required double price,
}) {
  final amount = NumberFormat.currency(
    symbol: 'R ',
    decimalDigits: 0,
  ).format(price);
  return listingType == 0 ? '$amount / month' : amount;
}

String propertyListingTypeLabel(int listingType) =>
    listingType == 1 ? 'For sale' : 'For rent';
