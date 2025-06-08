import 'package:intl/intl.dart';

String formatDate(String dateString) {
  try {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('MMM d, y').format(dateTime);
  } catch (e) {
    return dateString; // Return original string if parsing fails
  }
}