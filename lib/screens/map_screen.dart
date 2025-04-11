import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/vendor.dart';
import '../providers/vendor_provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = LatLng(19.4326, -99.1332);
  int _currentCarouselIndex = 0;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Activa tu ubicación')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  void _goToVendorLocation(Vendor vendor) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(vendor.location.latitude, vendor.location.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Vendedores Ambulantes')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers:
                vendorProvider.vendors.map((vendor) {
                  return Marker(
                    markerId: MarkerId(vendor.id),
                    position: LatLng(
                      vendor.location.latitude,
                      vendor.location.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: vendor.name,
                      snippet: '${vendor.products.length} productos',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/vendor_detail',
                        arguments: vendor,
                      );
                    },
                  );
                }).toSet(),
            onMapCreated: (GoogleMapController controller) {
              if (!mounted) return;
              setState(() {
                _mapController = controller;
              });
            },
          ),
          if (vendorProvider.vendors.isEmpty)
            Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      heroTag: 'vendor_location', // Tag único
                      onPressed:
                          vendorProvider.vendors.isNotEmpty
                              ? () => _goToVendorLocation(
                                vendorProvider.vendors[_currentCarouselIndex],
                              )
                              : null,
                      child: Icon(Icons.location_pin),
                      mini: true,
                    ),
                    FloatingActionButton(
                      heroTag: 'my_location', // Tag único
                      onPressed: _goToMyLocation,
                      child: Icon(Icons.my_location),
                      mini: true,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 120.0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                  ),
                  items:
                      vendorProvider.vendors.isEmpty
                          ? [
                            Card(
                              child: Center(
                                child: Text('No hay vendedores disponibles'),
                              ),
                            ),
                          ]
                          : vendorProvider.vendors.map((vendor) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/vendor_detail',
                                  arguments: vendor,
                                );
                              },
                              child: Card(
                                elevation: 4,
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Image.network(
                                        vendor.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey,
                                            child: Center(
                                              child: Text(
                                                'Error al cargar imagen',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.5),
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            vendor.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            vendor.description,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
