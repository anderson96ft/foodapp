import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/vendor.dart';

class VendorDetailScreen extends StatefulWidget {
  @override
  _VendorDetailScreenState createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.pause();
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Vendor vendor = ModalRoute.of(context)!.settings.arguments as Vendor;

    _videoControllers = vendor.videoUrls.map((url) {
      final controller = VideoPlayerController.network(url);
      _initializeController(controller); // Inicializar asíncronamente
      controller.setLooping(true);
      return controller;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(vendor.name)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  vendor.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey,
                    child: Center(child: Text('Imagen no disponible')),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    vendor.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Productos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: vendor.products.length,
                    itemBuilder: (context, index) {
                      final product = vendor.products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('\$${product.price}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: vendor.videoUrls.isEmpty
                ? Center(child: Text('No hay videos disponibles'))
                : PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: vendor.videoUrls.length,
                    itemBuilder: (context, index) {
                      final controller = _videoControllers[index];
                      return FutureBuilder(
                        future: controller.initialize(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (controller.value.isInitialized) {
                              controller.play();
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.value.isPlaying
                                        ? controller.pause()
                                        : controller.play();
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                ),
                              );
                            } else {
                              return Center(child: Text('Error al cargar el video'));
                            }
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}