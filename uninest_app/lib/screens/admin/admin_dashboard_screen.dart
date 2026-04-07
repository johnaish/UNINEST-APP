import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../services/property_service.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _activeTab = ValueNotifier<int>(0);
  final _propertyService = PropertyService.instance;

  bool _isLoading = true;
  final Set<String> _processingPropertyIds = <String>{};

  @override
  void initState() {
    super.initState();
    _propertyService.addListener(_onPropertiesChanged);
    _loadProperties();
  }

  @override
  void dispose() {
    _propertyService.removeListener(_onPropertiesChanged);
    _activeTab.dispose();
    super.dispose();
  }

  void _onPropertiesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProperties({bool refresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = !refresh && _propertyService.properties.isEmpty;
      });
    }

    try {
      await _propertyService.loadProperties(forceRefresh: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveProperty(Property property) async {
    final adminId = FirebaseAuth.instance.currentUser?.uid ?? 'admin_user';
    setState(() => _processingPropertyIds.add(property.id));
    try {
      await _propertyService.updatePropertyVerification(
        property.id,
        isVerified: true,
        verificationStatus: 'approved',
        adminId: adminId,
        note: 'Verified by admin',
      );
      await _propertyService.loadProperties(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${property.title} approved and now visible to students.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve ${property.title}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _processingPropertyIds.remove(property.id));
      }
    }
  }

  Future<void> _rejectProperty(Property property) async {
    final adminId = FirebaseAuth.instance.currentUser?.uid ?? 'admin_user';
    setState(() => _processingPropertyIds.add(property.id));
    try {
      await _propertyService.updatePropertyVerification(
        property.id,
        isVerified: false,
        verificationStatus: 'rejected',
        adminId: adminId,
        note: 'Failed verification checks',
      );
      await _propertyService.loadProperties(forceRefresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${property.title} rejected.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject ${property.title}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _processingPropertyIds.remove(property.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _propertyService.pendingProperties;
    final approved = _propertyService.approvedProperties;
    final all = _propertyService.properties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UNINEST – Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh listings',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadProperties(refresh: true),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(
            pendingCount: pending.length,
            approvedCount: approved.length,
            totalCount: all.length,
          ),
          ValueListenableBuilder<int>(
            valueListenable: _activeTab,
            builder: (context, value, child) {
              return Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _activeTab.value = 0,
                      child: Text(
                        'Pending (${pending.length})',
                        style: TextStyle(
                          color: value == 0 ? Colors.orange : Colors.black54,
                          fontWeight: value == 0 ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _activeTab.value = 1,
                      child: Text(
                        'All (${all.length})',
                        style: TextStyle(
                          color: value == 1 ? Colors.orange : Colors.black54,
                          fontWeight: value == 1 ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _activeTab,
              builder: (context, value, child) {
                final list = value == 0 ? pending : all;

                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) {
                  return _buildEmptyState(value == 0);
                }

                return RefreshIndicator(
                  onRefresh: () => _loadProperties(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final prop = list[index];
                      final isProcessing = _processingPropertyIds.contains(prop.id);
                      return _buildPropertyCard(
                        property: prop,
                        showActions: value == 0,
                        isProcessing: isProcessing,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader({
    required int pendingCount,
    required int approvedCount,
    required int totalCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.orange.shade50,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildSummaryChip(Icons.pending_actions, '$pendingCount pending', Colors.orange),
          _buildSummaryChip(Icons.verified, '$approvedCount approved', Colors.green),
          _buildSummaryChip(Icons.home_work_outlined, '$totalCount total', Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool pendingTab) {
    return RefreshIndicator(
      onRefresh: () => _loadProperties(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        children: [
          Icon(
            pendingTab ? Icons.inbox_outlined : Icons.home_work_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            pendingTab ? 'No pending submissions' : 'No properties available',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            pendingTab
                ? 'New landlord submissions will appear here for review.'
                : 'Properties will appear here after landlords submit them.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard({
    required Property property,
    required bool showActions,
    required bool isProcessing,
  }) {
    final statusColor = property.verificationStatus == 'approved'
        ? Colors.green
        : property.verificationStatus == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  property.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.orange.shade50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined, size: 44),
                  ),
                ),
              ),
            if (property.imageUrl.isNotEmpty) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    property.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(property.verificationStatus.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.12),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Landlord: ${property.landlordName}'),
            Text('Location: ${property.location}'),
            Text('Price: KES ${property.pricePerMonth.toStringAsFixed(0)}/month'),
            Text('Room type: ${property.roomType}'),
            Text(
              'Distance from campus: ${property.distanceFromCampusKm.toStringAsFixed(1)} km',
            ),
            if (property.amenities.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: property.amenities
                    .take(4)
                    .map(
                      (amenity) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(amenity, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (property.verificationNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Admin note: ${property.verificationNote}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : () => _rejectProperty(property),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : () => _approveProperty(property),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      icon: isProcessing
                          ? const SizedBox.shrink()
                          : const Icon(Icons.check_circle_outline),
                      label: Text(isProcessing ? 'Processing...' : 'Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
