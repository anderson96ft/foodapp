import 'package:grokstreet/models/product.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  final String id;
  final String name;
  final GeoPoint location;
  final List<Product> products;
  final String imageUrl;
  final String description;
  final List<String> videoUrls; // Lista de URLs de videos

  Vendor({
    required this.id,
    required this.name,
    required this.location,
    required this.products,
    required this.imageUrl,
    required this.description,
    required this.videoUrls,
  });

  factory Vendor.fromFirestore(Map<String, dynamic> data, String id, List<Product> products) {
    return Vendor(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] as GeoPoint? ?? GeoPoint(0.0, 0.0),
      products: products,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      description: data['description'] ?? 'Sin descripción',
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
    );
  }
}