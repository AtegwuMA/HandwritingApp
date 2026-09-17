import 'dart:io';

import 'package:flutter/material.dart';

import '../models/scan.dart';
import '../storage/scan_store.dart';

/// Side-by-side view of the original scan and the recognized/corrected
/// text, editable in place. Confidence-highlighting on low-confidence spans
/// (per the Phase 7 spec) is deferred until the custom HTR model supplies
/// real per-token confidence — see htr_result.dart.
class ReviewScreen extends StatefulWidget {
  final Scan scan;
  final ScanStore scanStore;

  const ReviewScreen({super.key, required this.scan, required this.scanStore});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.scan.correctedText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.scanStore.updateCorrectedText(
      widget.scan.id,
      _controller.text,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: InteractiveViewer(
              child: Image.file(File(widget.scan.imagePath)),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raw recognition',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.scan.rawText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Corrected (editable)',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
