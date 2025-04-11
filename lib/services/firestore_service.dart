import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor.dart';
import '../models/product.dart';

class FirestoreService {
  final CollectionReference _vendorsCollection =
      FirebaseFirestore.instance.collection('vendors');

  // Obtener todos los vendedores con sus productos en tiempo real
  Stream<List<Vendor>> getVendors() {
    return _vendorsCollection.snapshots().asyncMap((snapshot) async {
      List<Vendor> vendors = [];
      for (var doc in snapshot.docs) {
        // Obtener los productos de la subcolección
        QuerySnapshot productSnapshot =
            await doc.reference.collection('products').get();
        List<Product> products = productSnapshot.docs.map((productDoc) {
          return Product.fromFirestore(
              productDoc.data() as Map<String, dynamic>, productDoc.id);
        }).toList();

        // Crear el vendedor con sus productos
        vendors.add(Vendor.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id, products));
      }
      return vendors;
    });
  }

  // Agregar un vendedor con productos
  Future<void> addVendor(Vendor vendor) async {
    // Guardar el vendedor
    await _vendorsCollection.doc(vendor.id).set({
      'name': vendor.name,
      'location': vendor.location,
    });

    // Guardar los productos en la subcolección
    CollectionReference productsCollection =
        _vendorsCollection.doc(vendor.id).collection('products');
    for (var product in vendor.products) {
      await productsCollection.doc(product.id).set(product.toFirestore());
    }
  }
}