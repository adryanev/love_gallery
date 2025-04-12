import 'package:flutter/material.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/screens/memory_detail_screen.dart';
import 'package:love_gallery/widgets/memory_card.dart';
import 'package:love_gallery/widgets/audio_control.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Memory>> _memoriesFuture;
  final DataRepository _repository = getDataRepository();

  @override
  void initState() {
    super.initState();
    _memoriesFuture = _repository.getMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Memory Gallery'),
        elevation: 0,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: AudioControl()),
        ],
      ),
      body: FutureBuilder<List<Memory>>(
        future: _memoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No memories found.'));
          }

          final memories = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    return MemoryCard(
                      memory: memories[index],
                      onTap: () => _openMemoryDetail(context, memories[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openMemoryDetail(BuildContext context, Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(memory: memory),
      ),
    );
  }
}
