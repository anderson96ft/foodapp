import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/firestore_service.dart';

class VendorProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Vendor> _vendors = [];

  List<Vendor> get vendors => _vendors;

  VendorProvider() {
    _loadVendors();
  }

  void _loadVendors() {
    _firestoreService.getVendors().listen((vendors) {
      _vendors = vendors;
      notifyListeners();
    });
  }

  void addVendor(Vendor vendor) {
    _firestoreService.addVendor(vendor);
  }
}