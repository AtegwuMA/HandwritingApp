import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../correction/correction_service.dart';
import '../models/scan.dart';
import '../ocr/ml_kit_htr_engine.dart';
import '../pipeline.dart';
import '../review/review_screen.dart';
import '../storage/scan_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanStore _scanStore = ScanStore();
  late final HandwritingPipeline _pipeline = HandwritingPipeline(
    htrEngine: MlKitHtrEngine(),
    correctionService: CorrectionService(),
    scanStore: _scanStore,
  );
  final ImagePicker _picker = ImagePicker();

  List<Scan> _scans = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final scans = await _scanStore.all();
    setState(() => _scans = scans);
  }

  Future<void> _capture(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 95);
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final scan = await _pipeline.run(picked.path);
      await _refresh();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReviewScreen(scan: scan, scanStore: _scanStore),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recognition failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handwriting')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scans.isEmpty
              ? const Center(child: Text('No scans yet. Tap + to start.'))
              : ListView.builder(
                  itemCount: _scans.length,
                  itemBuilder: (context, index) {
                    final scan = _scans[index];
                    return ListTile(
                      title: Text(
                        scan.correctedText.isEmpty
                            ? '(empty)'
                            : scan.correctedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(scan.createdAt.toLocal().toString()),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ReviewScreen(scan: scan, scanStore: _scanStore),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _capture(ImageSource.gallery),
            tooltip: 'Import from gallery',
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _capture(ImageSource.camera),
            tooltip: 'Scan with camera',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
