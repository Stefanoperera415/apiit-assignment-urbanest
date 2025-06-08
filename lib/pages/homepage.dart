import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/listing_provider.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/theme_provider.dart';
import 'package:urbanest_app/widget/favouites_provider.dart';
import 'package:urbanest_app/widget/property_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum ListingFilter {
  all,
  buy,
  rent,
  reserve,
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ListingFilter _currentFilter = ListingFilter.all;
  String _searchQuery = '';

  final List<Map<String, dynamic>> options = [
    {'label': 'Home', 'icon': Icons.home_filled, 'filter': ListingFilter.all},
    {'label': 'Buy', 'icon': Icons.home_work, 'filter': ListingFilter.buy},
    {'label': 'Rent', 'icon': Icons.key, 'filter': ListingFilter.rent},
    {'label': 'Reserve', 'icon': Icons.calendar_today, 'filter': ListingFilter.reserve},
  ];

  List<Listing> getFilteredListings(List<Listing> allListings) {
    List<Listing> filtered = allListings;

  
    if (_currentFilter != ListingFilter.all) {
      filtered = filtered.where((listing) {
        switch (_currentFilter) {
          case ListingFilter.buy:
            return listing.method.toLowerCase().contains('sell property');
          case ListingFilter.rent:
            return listing.method.toLowerCase().contains('rent out property');
          case ListingFilter.reserve:
            return listing.method.toLowerCase().contains('list vacation rental');
          case ListingFilter.all:
          default:
            return true;
        }
      }).toList();
    }

    // Then filter by search query if there is one
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((listing) {
        return listing.city.toLowerCase().contains(query) || 
               listing.countryRegion.toLowerCase().contains(query) ||
               listing.title.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _handleFilterChange(ListingFilter filter) {
    setState(() {
      _currentFilter = filter;
      selectedIndex = options.indexWhere((opt) => opt['filter'] == filter);
      _searchQuery = ''; // Clear search when changing filters
      _searchController.clear();
    });
    
    String? method;
    switch (filter) {
      case ListingFilter.buy:
        method = 'sell';
        break;
      case ListingFilter.rent:
        method = 'rent';
        break;
      case ListingFilter.reserve:
        method = 'vacation rental';
        break;
      case ListingFilter.all:
      default:
        method = null;
    }
    
    Provider.of<ListingController>(context, listen: false).fetchListings(method: method);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(() {
      _handleSearch(_searchController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingController>(context, listen: false).fetchListings();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent && 
        _searchQuery.isEmpty) {
      String? method;
      switch (_currentFilter) {
        case ListingFilter.buy:
          method = 'sell';
          break;
        case ListingFilter.rent:
          method = 'rent';
          break;
        case ListingFilter.reserve:
          method = 'vacation rental';
          break;
        case ListingFilter.all:
        default:
          method = null;
      }
      Provider.of<ListingController>(context, listen: false).loadMoreListings(method: method);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final listingController = Provider.of<ListingController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredListings = getFilteredListings(listingController.listings);
    final hasMore = listingController.hasMore && 
                   _currentFilter == ListingFilter.all && 
                   _searchQuery.isEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu, size: 28, color: theme.iconTheme.color),
            ),
          ),
        ),
        title: Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search properties...',
          hintStyle: TextStyle(fontSize: 14, color: theme.hintColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, size: 22, color: theme.iconTheme.color),
            onPressed:  () {},
            padding: EdgeInsets.zero,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
        ),
        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
      ),
    ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.tune_rounded, size: 24, color: theme.iconTheme.color),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
     drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
      body: listingController.isLoading && listingController.listings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : listingController.error.isNotEmpty
              ? Center(child: Text('Error: ${listingController.error}'))
              : Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification &&
                              _scrollController.position.extentAfter == 0 &&
                              _searchQuery.isEmpty) {
                            String? method;
                            switch (_currentFilter) {
                              case ListingFilter.buy:
                                method = 'sell';
                                break;
                              case ListingFilter.rent:
                                method = 'rent';
                                break;
                              case ListingFilter.reserve:
                                method = 'vacation rental';
                                break;
                              case ListingFilter.all:
                              default:
                                method = null;
                            }
                            Provider.of<ListingController>(context, listen: false)
                                .loadMoreListings(method: method);
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(options.length, (index) {
                                      final isSelected = selectedIndex == index;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: ChoiceChip(
                                          showCheckmark: false,
                                          avatar: Icon(
                                            options[index]['icon'],
                                            size: 20,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark ? Colors.white70 : Colors.black54),
                                          ),
                                          label: Text(
                                            options[index]['label'],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white70 : Colors.black87),
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          selected: isSelected,
                                          selectedColor: isDark ? Colors.blue[700] : Colors.black,
                                          backgroundColor:
                                              isDark ? Colors.grey[800] : Colors.grey.shade200,
                                          onSelected: (selected) {
                                            if (selected) {
                                              _handleFilterChange(options[index]['filter']);
                                            }
                                          },
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'Search Results'
                                          : _currentFilter == ListingFilter.all
                                              ? 'Top Properties'
                                              : 'Top ${options[selectedIndex]['label']} Properties',
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    if (_searchQuery.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _searchQuery = '';
                                            _searchController.clear();
                                          });
                                        },
                                        child: const Text('Clear'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: isDark ? Colors.white70 : Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (filteredListings.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No properties found for "$_searchQuery"'
                                          : 'No properties available',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredListings.length + (hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= filteredListings.length) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: listingController.isLoadingMore
                                              ? const CircularProgressIndicator()
                                              : const SizedBox(),
                                        ),
                                      );
                                    }

                                    final listing = filteredListings[index];
                                    final isFavorite = favoritesProvider.isFavorite(listing);

                                    return Container(
                                      width: 220,
                                      margin: const EdgeInsets.all(1),
                                      child: PropertyCard(
                                        title: listing.title,
                                        status: listing.status ?? 'For Sale',
                                        city: listing.city,
                                        country: listing.countryRegion,
                                        price: listing.price.toDouble(),
                                        imageUrl: listing.coverImage ?? 'https://via.placeholder.com/300',
                                        isFavorite: isFavorite,
                                        onFavoriteToggle: () {
                                          favoritesProvider.toggleFavorite(listing);
                                        },
                                        listing: listing,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}