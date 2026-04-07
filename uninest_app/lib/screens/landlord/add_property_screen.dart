import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../services/property_service.dart';

class AddPropertyScreen extends StatefulWidget {
  static const routeName = '/add-property';
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _roomTypeCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _landlordNameCtrl = TextEditingController();

  XFile? _pickedImage;
  Uint8List? _pickedImageData;

  late LatLng _selectedLocation;
  bool _locationSelected = false;
  bool _loading = false;

  final _service = PropertyService.instance;

  @override
  void initState() {
    super.initState();
    _selectedLocation = const LatLng(-0.5312, 37.4506);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _distanceCtrl.dispose();
    _roomTypeCtrl.dispose();
    _amenitiesCtrl.dispose();
    _imageUrlCtrl.dispose();
    _landlordNameCtrl.dispose();
    super.dispose();
  }

  Future<String?> _uploadImageToStorage(XFile imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('You must be signed in to upload property images.');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rawExtension = imageFile.path.contains('.')
          ? imageFile.path.split('.').last.toLowerCase()
          : 'jpg';
      final extension = ['jpg', 'jpeg', 'png', 'webp'].contains(rawExtension)
          ? rawExtension
          : 'jpg';
      final remotePath = 'property_images/${user.uid}/$timestamp.$extension';

      final ref = FirebaseStorage.instance.ref().child(remotePath);
      final bytes = await imageFile.readAsBytes();

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/${extension == 'jpg' ? 'jpeg' : extension}',
          customMetadata: {
            'uploadedBy': user.uid,
            'folder': 'property_images',
          },
        ),
      );

      await uploadTask;
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      String message;
      switch (e.code) {
        case 'permission-denied':
          message = 'Storage permission denied. Update Firebase Storage rules and try again.';
          break;
        case 'quota-exceeded':
          message = 'Storage quota exceeded. Try a smaller image or contact support.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection and try again.';
          break;
        default:
          message = 'Upload error: ${e.message}';
      }
      throw StateError(message);
    } catch (e) {
      throw StateError('Image upload failed: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      final data = await picked.readAsBytes();
      setState(() {
        _pickedImage = picked;
        _pickedImageData = data;
      });
    } catch (e) {
      _showSnack('Image pick failed: $e');
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnack('Please sign in again before submitting a property.');
      return;
    }

    setState(() => _loading = true);

    try {
      final amenities = _amenitiesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      final landlordId = currentUser.uid;
      final landlordName = currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!.trim()
          : (_landlordNameCtrl.text.trim().isNotEmpty
              ? _landlordNameCtrl.text.trim()
              : 'Unknown Landlord');

      String imageUrl = _imageUrlCtrl.text.trim();
      if (_pickedImage != null) {
        try {
          imageUrl = await _uploadImageToStorage(_pickedImage!) ?? imageUrl;
        } catch (e) {
          _showSnack(e.toString());
          // Fallback to manual URL or placeholder
          imageUrl = imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/400x250.png?text=New+Property';
        }
      } else if (imageUrl.isEmpty) {
        imageUrl = 'https://via.placeholder.com/400x250.png?text=New+Property';
      }

      final property = Property(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        pricePerMonth: double.parse(_priceCtrl.text.trim()),
        distanceFromCampusKm: double.parse(_distanceCtrl.text.trim()),
        roomType: _roomTypeCtrl.text.trim(),
        rating: 0,
        amenities: amenities,
        isVerified: false,
        verificationStatus: 'pending',
        verificationAdminId: '',
        verificationNote: '',
        imageUrl: imageUrl,
        landlordName: landlordName,
        landlordId: landlordId,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      await _service.addProperty(property);
      await _service.loadProperties(forceRefresh: true);

      if (!mounted) return;
      _showSnack('Property submitted successfully and sent for admin review.');
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Property submission failed: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickLocation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Property Location'),
        content: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,
              onTap: (tapPosition, latLng) {
                setState(() {
                  _selectedLocation = latLng;
                  _locationSelected = true;
                });
                Navigator.pop(context);
                _showSnack(
                  'Location set: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.uninest_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red.shade700,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    return null;
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName must be a number';
    }
    if (parsed <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedAmenities = _amenitiesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Property',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF68B1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Listings are reviewed by admins before they appear to students.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Title'),
                    validator: (v) => _requiredText(v, 'title'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Location'),
                    validator: (v) => _requiredText(v, 'location'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Price per month (KES)'),
                    validator: (v) => _validatePositiveNumber(v, 'price'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _distanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Distance from campus (km)'),
                    validator: (v) => _validatePositiveNumber(v, 'distance'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roomTypeCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Room type'),
                    validator: (v) => _requiredText(v, 'room type'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amenitiesCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Amenities (comma-separated)'),
                  ),
                  if (selectedAmenities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedAmenities
                          .map(
                            (amenity) => Chip(
                              label: Text(amenity),
                              backgroundColor: Colors.orange.shade50,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Property Image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF68B1E), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange.withOpacity(0.05),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _pickedImageData != null
                          ? Image.memory(_pickedImageData!, fit: BoxFit.cover)
                          : _imageUrlCtrl.text.trim().isNotEmpty
                              ? Image.network(
                                  _imageUrlCtrl.text.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Text('Invalid URL preview'),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined, size: 42),
                                    SizedBox(height: 10),
                                    Text('Add a clear photo to increase trust'),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text('Gallery/File'),
                        onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _imageUrlCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Image URL (optional fallback)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _landlordNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Landlord Name'),
                    validator: (v) => _requiredText(v, 'your name'),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF68B1E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF68B1E), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Property Location',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _locationSelected
                              ? 'Pinned at ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}'
                              : 'Not selected yet — default location will be used unless you pin it on the map.',
                          style: TextStyle(
                            color: _locationSelected ? Colors.green : Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF68B1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _loading ? null : _pickLocation,
                            icon: const Icon(Icons.location_on, color: Colors.white),
                            label: const Text(
                              'Pick Location on Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'After submission, your property is saved as pending and sent to the admin dashboard for approval.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF68B1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit for Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFF68B1E)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF68B1E), width: 2),
      ),
    );
  }
}
