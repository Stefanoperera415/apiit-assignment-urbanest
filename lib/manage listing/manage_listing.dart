import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/auth_provider.dart';
import 'package:urbanest_app/controllers/listing_provider.dart';
import 'package:urbanest_app/manage%20listing/update_listing_screen.dart';
import 'package:urbanest_app/model/listing.dart';

class ManageListing extends StatefulWidget {
  const ManageListing({super.key});

  @override
  State<ManageListing> createState() => _ManageListingState();
}

class _ManageListingState extends State<ManageListing> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserListings();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreListings();
    }
  }

  Future<void> _fetchUserListings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingController =
        Provider.of<ListingController>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      if (authProvider.currentUser != null) {
        await listingController.fetchListings();
        _hasMore = listingController.hasMore;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch listings: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreListings() async {
    if (_isLoadingMore || !_hasMore) return;

    final listingController =
        Provider.of<ListingController>(context, listen: false);

    setState(() => _isLoadingMore = true);
    try {
      await listingController.loadMoreListings();
      _hasMore = listingController.hasMore;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more listings: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  List<Listing> _getUserListings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingController =
        Provider.of<ListingController>(context, listen: false);

    if (authProvider.currentUser == null) return [];

    return listingController.listings
        .where((listing) => listing.userId == authProvider.currentUser!.id.toString())
        .toList();
  }

  Future<void> _deleteListing(String listingId) async {
    final listingController =
        Provider.of<ListingController>(context, listen: false);

    try {
      setState(() => _isLoading = true);
      await listingController.deleteListing(listingId);
      await _fetchUserListings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete listing: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(String listingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteListing(listingId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUpdate(Listing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateListingScreen(listing: listing),
      ),
    ).then((success) {
      if (success == true) {
        _fetchUserListings();
      }
    });
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'inactive':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userListings = _getUserListings();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userListings.isEmpty
              ? RefreshIndicator(
                  onRefresh: _fetchUserListings,
                  child: const Center(
                    child: Text(
                      'No listings found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchUserListings,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: userListings.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= userListings.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: _isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : const Text('No more listings'),
                                ),
                              );
                            }

                            final listing = userListings[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _navigateToUpdate(listing),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (listing.coverImage != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              listing.coverImage!,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.broken_image),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                listing.title,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (listing.status != null)
                                              _buildStatusChip(listing.status!),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${listing.price}',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.location_city,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              listing.city ?? 'N/A',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.public,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              listing.countryRegion ?? 'N/A',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                              onPressed: () => _navigateToUpdate(listing),
                                              child: const Text('Edit'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                              onPressed: () => _confirmDelete(listing.id!),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}