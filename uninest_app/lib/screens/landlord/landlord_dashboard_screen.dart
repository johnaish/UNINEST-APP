import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';
import '../student/account_management_screen.dart';
import '../shared/help_support_screen.dart';
import '../shared/security_screen.dart';
import 'add_property_screen.dart';

class LandlordDashboardScreen extends StatefulWidget {
  static const routeName = '/landlord-dashboard';

  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  int _selectedIndex = 0;
  final PropertyService _propertyService = PropertyService.instance;
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _userService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Landlord Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildPropertiesTab(context)
          : _selectedIndex == 1
              ? _buildBookingRequestsTab(context)
              : _buildProfileTab(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF68B1E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentLandlordId = currentUser?.uid ?? '';
    final currentLandlordName = _userData?['fullName'] as String? ?? currentUser?.displayName ?? '';
    final landlordProps = _propertyService.landlordProperties(
      landlordId: currentLandlordId,
      landlordName: currentLandlordName,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Property Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_home),
                label: const Text('Add New Property'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF68B1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AddPropertyScreen.routeName);
                },
              ),
            ),
          ),

          // Properties List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'MY PROPERTIES (${landlordProps.length})',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),

          if (landlordProps.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
              ),
              child: const Text(
                'You currently have no properties. Add one to list it for students.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...landlordProps.map((property) => _buildPropertyCard(context, property)).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, var property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          // Property Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            property.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.isVerified
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        property.isVerified ? 'Verified' : 'Pending',
                        style: TextStyle(
                          color: property.isVerified ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'KES ${property.pricePerMonth.toStringAsFixed(0)}/month',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFF68B1E)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${property.rating}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Preview',
                        Icons.visibility,
                        const Color(0xFFF68B1E),
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Preview: ${property.title}\n${property.location}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Edit',
                        Icons.edit,
                        Colors.blue,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Edit: ${property.title}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Remove',
                        Icons.delete,
                        Colors.red,
                        () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Property'),
                              content: Text(
                                  'Are you sure you want to remove ${property.title}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${property.title} has been removed'),
                                      ),
                                    );
                                  },
                                  child: const Text('Remove',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color,
      VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildBookingRequestsTab(BuildContext context) {
    final bookingRequests = [
      {
        'studentName': 'Alice Johnson',
        'property': 'Elite Heights Luxury',
        'date': 'March 20, 2026',
        'status': 'Pending',
      },
      {
        'studentName': 'Bob Smith',
        'property': 'Sunrise Executive',
        'date': 'March 19, 2026',
        'status': 'Accepted',
      },
      {
        'studentName': 'Carol White',
        'property': 'Elite Heights Luxury',
        'date': 'March 18, 2026',
        'status': 'Declined',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'BOOKING REQUESTS (${bookingRequests.length})',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          ...bookingRequests.map((booking) => _buildBookingRequestCard(
              context, booking)).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookingRequestCard(BuildContext context, Map<String, String> booking) {
    final statusColor = booking['status'] == 'Pending'
        ? Colors.orange
        : booking['status'] == 'Accepted'
            ? Colors.green
            : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['studentName']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      booking['property']!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['date']!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status']!,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (booking['status'] == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Request from ${booking['studentName']} accepted!'),
                          ),
                        );
                      },
                      child: const Text('Accept', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Request from ${booking['studentName']} declined!'),
                          ),
                        );
                      },
                      child: const Text('Decline', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserHeader(),
          const SizedBox(height: 10),
          _buildSectionTitle('ACCOUNT'),
          _buildListTile(
            Icons.email,
            'Email',
            _userData?['email'] ?? 'No email',
            () {},
          ),
          _buildListTile(
            Icons.phone,
            'Phone',
            _userData?['phone'] ?? 'No phone',
            () {},
          ),
          _buildListTile(
            Icons.location_on,
            'Location',
            'Location not set', // Could be added to user data later
            () {},
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('SETTINGS'),
          _buildListTile(
            Icons.settings,
            'Account Settings',
            null,
            () {
              Navigator.pushNamed(context, AccountManagementScreen.routeName);
            },
          ),
          _buildListTile(
            Icons.security,
            'Security',
            null,
            () {
              Navigator.pushNamed(context, SecurityScreen.routeName);
            },
          ),
          _buildListTile(
            Icons.help,
            'Help & Support',
            null,
            () {
              Navigator.pushNamed(context, HelpSupportScreen.routeName);
            },
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF68B1E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('LOGOUT',
                    style: TextStyle(
                        color: Color(0xFFF68B1E), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final displayName = _userData?['fullName'] ?? 'Landlord';
    final email = _userData?['email'] ?? 'No email';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFF68B1E),
            child: Icon(Icons.business, color: Colors.white, size: 45),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Verified Landlord',
                    style: TextStyle(
                        color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(title,
          style: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildListTile(IconData icon, String title, String? subtitle,
      VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
