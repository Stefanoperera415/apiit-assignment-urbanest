import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/make_an_offer_provider.dart';
import 'package:urbanest_app/controllers/rent_request_provider.dart';
import 'package:urbanest_app/model/offer.dart';
import 'package:urbanest_app/model/rent_request.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    try {
      await Provider.of<RentRequestController>(context, listen: false).fetchRentRequests();
      await Provider.of<MakeAnOfferController>(context, listen: false).fetchOffers();
    } finally {
      if (mounted) {
        setState(() => _isInitialLoad = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.request_quote)), 
            Tab(icon: Icon(Icons.shopping_cart)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isInitialLoad
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.tealAccent : Colors.blue,
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRentRequestsTab(isDarkMode),
                _buildOffersTab(isDarkMode),
              ],
            ),
    );
  }

  Widget _buildRentRequestsTab(bool isDarkMode) {
    final rentRequestProvider = Provider.of<RentRequestController>(context);
    
    if (rentRequestProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? Colors.tealAccent : Colors.blue,
          ),
        ),
      );
    }

    if (rentRequestProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDarkMode ? Colors.red[300] : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${rentRequestProvider.error}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
               iconColor: isDarkMode ? Colors.teal : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _loadData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (rentRequestProvider.rentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No rent requests found',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: isDarkMode ? Colors.tealAccent : Colors.blue,
      onRefresh: () => Provider.of<RentRequestController>(context, listen: false).fetchRentRequests(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rentRequestProvider.rentRequests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = rentRequestProvider.rentRequests[index];
          return _buildRentRequestCard(request, isDarkMode);
        },
      ),
    );
  }

  Widget _buildOffersTab(bool isDarkMode) {
    final offerProvider = Provider.of<MakeAnOfferController>(context);
    
    if (offerProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? Colors.tealAccent : Colors.blue,
          ),
        ),
      );
    }

    if (offerProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDarkMode ? Colors.red[300] : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${offerProvider.error}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: isDarkMode ? Colors.teal : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _loadData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (offerProvider.offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No offers found',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: isDarkMode ? Colors.tealAccent : Colors.blue,
      onRefresh: () => Provider.of<MakeAnOfferController>(context, listen: false).fetchOffers(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: offerProvider.offers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = offerProvider.offers[index];
          return _buildOfferCard(offer, isDarkMode);
        },
      ),
    );
  }

  Widget _buildRentRequestCard(RentRequest request, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Add tap functionality if needed
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.request_quote,
                        color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rent Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      request.status ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.home_work_outlined,
                label: 'Listing ID:',
                value: request.listingId ?? 'N/A',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Monthly Amount:',
                value: '\$${request.monthlyIncome?.toStringAsFixed(2) ?? 'N/A'}',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 8),
              if (request.status == 'Pending') ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel Request'),
                    style: OutlinedButton.styleFrom(
                      iconColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _confirmDeleteRentRequest(request.id!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Offer offer, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Add tap functionality if needed
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: isDarkMode ? Colors.green[200] : Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Purchase Offer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.green[200] : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(offer.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      offer.status ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.home_work_outlined,
                label: 'Listing ID:',
                value: offer.listingId ?? 'N/A',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Offer Amount:',
                value: '\$${offer.offerAmount?.toStringAsFixed(2) ?? 'N/A'}',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Submitted:',
                value: offer.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A',
                isDarkMode: isDarkMode,
              ),
              if (offer.status == 'Pending') ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Withdraw Offer'),
                    style: OutlinedButton.styleFrom(
                     iconColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _confirmDeleteOffer(offer.id!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmDeleteRentRequest(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Rent Request'),
        content: const Text('Are you sure you want to cancel this rent request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<RentRequestController>(context, listen: false)
            .deleteRentRequest(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Rent request cancelled successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteOffer(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Offer'),
        content: const Text('Are you sure you want to withdraw this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<MakeAnOfferController>(context, listen: false)
            .deleteOffer(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Offer withdrawn successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}