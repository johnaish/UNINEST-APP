import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import 'property_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  static const routeName = '/wishlist';
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final PropertyService service = PropertyService.instance;

  @override
  Widget build(BuildContext context) {
    // ✅ uses the getter that exists in PropertyService
    final List<Property> saved = service.savedProperties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: const Color(0xFFF68B1E),
      ),
      body: saved.isEmpty
          ? const Center(child: Text('No saved properties yet.'))
          : ListView.separated(
              itemCount: saved.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = saved[i];
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text(
                    '${p.location} • KES ${p.pricePerMonth.toStringAsFixed(0)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // ✅ uses the method that exists in PropertyService
                      setState(() => service.toggleWishlist(p.id));
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PropertyDetailScreen.routeName,
                      arguments: p,
                    );
                  },
                );
              },
            ),
    );
  }
}