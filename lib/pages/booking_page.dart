import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/booking_provider.dart';
import 'package:urbanest_app/model/booking.dart';
import 'package:urbanest_app/utils/date_utils.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingController>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body:
          bookingProvider.isLoading && bookingProvider.bookings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : bookingProvider.bookings.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                onRefresh: bookingProvider.fetchBookings,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookingProvider.bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder:
                      (context, index) => _buildBookingCard(
                        context,
                        bookingProvider.bookings[index],
                      ),
                ),
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    String coverImageUrl =
        booking.listing?.coverImage?.startsWith('http') == true
            ? booking.listing!.coverImage!
            : 'http://192.168.1.101:8000/storage/listings/${booking.listing?.coverImage}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    coverImageUrl,
                    width: 90,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.home,
                          size: 60,
                          color: Colors.grey.shade200,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.listing?.title ?? 'Unknown Property',
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.listing?.city ?? 'Unknown location',
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LKR ${booking.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateInfo('Check-in', booking.checkInDate, theme),
                _buildDateInfo('Check-out', booking.checkOutDate, theme),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    booking.availability,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _availabilityColor(booking.availability),
                ),
                if (booking.availability.toLowerCase() == 'available')
                  TextButton(
                    onPressed: () => _showCancelDialog(booking.id!),
                    child: const Text(
                      'Cancel Booking',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
      const SizedBox(height: 4),
      Text(formatDate(date), style: theme.textTheme.bodyMedium),
    ],
  );

  Color _availabilityColor(String availability) {
    switch (availability.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  void _showCancelDialog(String bookingId) {
    try {
      Provider.of<BookingController>(
        context,
        listen: false,
      ).cancelBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
