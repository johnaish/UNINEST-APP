import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../services/property_service.dart';
import 'map_screen.dart';
import 'property_detail_screen.dart';
import 'wishlist_screen.dart';

class PropertyListScreen extends StatefulWidget {
  static const routeName = '/property-list';
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService service = PropertyService.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isInitialLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    service.addListener(_onPropertiesChanged);
    _searchController.addListener(_onSearchChanged);
    _loadProperties();
  }

  @override
  void dispose() {
    service.removeListener(_onPropertiesChanged);
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  void _onPropertiesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProperties({bool refresh = false}) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isInitialLoading = true;
        });
      }
    }

    try {
      await service.loadProperties(forceRefresh: true);
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Properties',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Price Range: KES 5,000 - 20,000'),
              const Divider(),
              const Text('Property Type:'),
              Wrap(
                spacing: 10,
                children: ['Hostel', 'Bedsitter', 'Studio']
                    .map(
                      (type) => ActionChip(
                        label: Text(type),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWishlist() {
    Navigator.pushNamed(context, WishlistScreen.routeName);
  }

  void _toggleWishlist(String propertyId) {
    service.toggleWishlist(propertyId);
  }

  List<Property> _filterProperties(List<Property> properties) {
    if (_searchQuery.isEmpty) {
      return properties;
    }

    return properties.where((p) {
      final amenitiesText = p.amenities.join(' ').toLowerCase();
      return p.title.toLowerCase().contains(_searchQuery) ||
          p.location.toLowerCase().contains(_searchQuery) ||
          p.roomType.toLowerCase().contains(_searchQuery) ||
          p.landlordName.toLowerCase().contains(_searchQuery) ||
          amenitiesText.contains(_searchQuery);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final List<Property> allProperties = service.approvedProperties;
        final List<Property> filteredProperties = _filterProperties(allProperties);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Discover Places',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, MapScreen.routeName),
                icon: const Icon(Icons.map, color: Colors.black),
              ),
              IconButton(
                onPressed: _openWishlist,
                icon: const Icon(Icons.favorite, color: Colors.red),
              ),
              IconButton(
                onPressed: _showFilterOptions,
                icon: const Icon(Icons.tune, color: Colors.black),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by place, type, amenity...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadProperties(refresh: true),
            child: _buildBody(
              allProperties: allProperties,
              filteredProperties: filteredProperties,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required List<Property> allProperties,
    required List<Property> filteredProperties,
  }) {
    if (_isInitialLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const [
          SizedBox(height: 32),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Loading approved properties...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    if (allProperties.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.home_work_outlined, size: 72, color: Colors.orange.shade300),
          const SizedBox(height: 16),
          const Text(
            'No approved properties yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Once landlords submit listings and admins approve them, they will appear here for students to browse.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _loadProperties(refresh: true),
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isRefreshing ? 'Refreshing...' : 'Refresh'),
          ),
        ],
      );
    }

    if (filteredProperties.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No matching properties found',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term for location, room type, landlord, or amenities.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _searchController.clear,
            child: const Text('Clear search'),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: filteredProperties.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${filteredProperties.length} approved place${filteredProperties.length == 1 ? '' : 's'} available',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_isRefreshing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          );
        }

        final item = filteredProperties[i - 1];
        return _buildModernPropertyCard(item);
      },
    );
  }

  Widget _buildModernPropertyCard(Property item) {
    final bool isSaved = service.isSaved(item.id);
    final List<String> amenitiesPreview = item.amenities.take(3).toList(growable: false);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        PropertyDetailScreen.routeName,
        arguments: item,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item.imageUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      height: 210,
                      color: Colors.orange[100],
                      child: const Icon(Icons.image, size: 60),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'KES ${item.pricePerMonth.toStringAsFixed(0)}/mo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(item.id),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.home_outlined, item.roomType),
                      _buildInfoChip(
                        Icons.school_outlined,
                        '${item.distanceFromCampusKm.toStringAsFixed(1)} km from campus',
                      ),
                      _buildInfoChip(Icons.person_outline, item.landlordName),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Listed by ${item.landlordName}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (amenitiesPreview.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: amenitiesPreview
                          .map(
                            (amenity) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (item.amenities.length > amenitiesPreview.length) ...[
                      const SizedBox(height: 6),
                      Text(
                        '+${item.amenities.length - amenitiesPreview.length} more amenities',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}