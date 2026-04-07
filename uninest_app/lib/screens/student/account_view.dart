import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(),
            const SizedBox(height: 10),
            
            _buildSectionTitle('MY UNINEST ACCOUNT'),
            _buildListTile(context, Icons.receipt_long, 'Bookings', 'View your hostel history', '/bookings'),
            _buildListTile(context, Icons.mail_outline, 'Inbox', 'Messages from landlords', '/inbox'),
            _buildListTile(context, Icons.favorite_border, 'Saved Items', 'Your favorite houses', '/wishlist'),
            
            const SizedBox(height: 10),
            
            _buildSectionTitle('SETTINGS'),
            _buildListTile(context, Icons.settings, 'Account Management', null, '/account-management'),
            _buildListTile(context, Icons.lock_outline, 'Close Account', null, '/close-account'),
            
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _userData?['fullName'] ?? user?.displayName ?? 'Your Name';
    final email = _userData?['email'] ?? user?.email ?? 'No email on file';
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFF68B1E),
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.white, size: 45);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 45),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(email, 
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String? subtitle, String routeName) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFF68B1E)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('LOGOUT', 
            style: TextStyle(color: Color(0xFFF68B1E), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}