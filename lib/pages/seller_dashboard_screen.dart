import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/seller_dashboard_provider.dart';
import 'package:urbanest_app/model/booking.dart';
import 'package:urbanest_app/model/offer.dart';
import 'package:urbanest_app/model/rent_request.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SellerDashboardProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerDashboardProvider>(context);
    final dashboardData = provider.dashboardData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookings'),
            Tab(text: 'Offers'),
            Tab(text: 'Rent Requests'),
          ],
        ),
      ),
      body: provider.isLoading && dashboardData == null
          ? const Center(child: CircularProgressIndicator())
          : dashboardData == null
              ? const Center(child: Text('No data available'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    BookingsTab(bookings: dashboardData.bookings ?? []),
                    OffersTab(offers: dashboardData.receivedOffers ?? []),
                    RentRequestsTab(
                      rentRequests: dashboardData.receivedRentRequests ?? [],
                    ),
                  ],
                ),
    );
  }
}

// Rest of your code remains the same...
class BookingsTab extends StatelessWidget {
  final List<Booking> bookings;

  const BookingsTab({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerDashboardProvider>(context, listen: false);

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Booking #${booking.id ?? 'N/A'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check-in: ${booking.checkInDate}'),
                Text('Check-out: ${booking.checkOutDate}'),
                Text('Status: ${booking.status}'),
                Text('Availability: ${booking.availability}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (booking.availability == 'available')
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: booking.id != null
                        ? () => provider.markBookingAsUnavailable(booking.id!)
                        : null,
                  ),
                if (booking.availability == 'unavailable')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: booking.id != null
                        ? () => provider.markBookingAsAvailable(booking.id!)
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OffersTab extends StatelessWidget {
  final List<Offer> offers;

  const OffersTab({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerDashboardProvider>(context, listen: false);

    if (offers.isEmpty) {
      return const Center(child: Text('No offers received yet'));
    }

    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offer for Listing: ${offer.listingId ?? 'N/A'}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Amount: \$${offer.offerAmount?.toStringAsFixed(2) ?? '0.00'}'),
                Text('From: ${offer.fullName ?? 'Unknown'}'),
                Text('Email: ${offer.email ?? 'N/A'}'),
                Text('Phone: ${offer.phone ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Status: ${offer.status?.toUpperCase() ?? 'PENDING'}',
                    style: TextStyle(
                      color: offer.status == 'accepted' 
                          ? Colors.green 
                          : offer.status == 'rejected' 
                              ? Colors.red 
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    )),
                if (offer.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: offer.id != null
                            ? () => provider.acceptOffer(offer.id!)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: offer.id != null
                            ? () => provider.rejectOffer(offer.id!)
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RentRequestsTab extends StatelessWidget {
  final List<RentRequest> rentRequests;

  const RentRequestsTab({super.key, required this.rentRequests});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SellerDashboardProvider>(context, listen: false);

    return ListView.builder(
      itemCount: rentRequests.length,
      itemBuilder: (context, index) {
        final request = rentRequests[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Rent Request #${request.id ?? 'N/A'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: ${request.fullName}'),
                Text('Income: \$${request.monthlyIncome}'),
                Text('Status: ${request.status ?? 'unknown'}'),
              ],
            ),
            trailing: request.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: request.id != null
                            ? () => provider.acceptRentRequest(request.id!)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: request.id != null
                            ? () => provider.rejectRentRequest(request.id!)
                            : null,
                      ),
                    ],
                  )
                : Text(request.status ?? 'unknown'),
          ),
        );
      },
    );
  }
}