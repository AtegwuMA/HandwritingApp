import 'dart:io';

import 'package:image/image.dart' as img;

/// Basic preprocessing before handwriting recognition: grayscale, contrast
/// normalization, and binarization. Deskew is intentionally left out of the
/// MVP (Phase 2) — ML Kit tolerates modest skew, and a real deskew step
/// (Hough-line based) belongs with the custom HTR pipeline in a later phase.
class ImagePreprocessor {
  /// Reads [inputPath], preprocesses it, writes the result next to it with a
  /// `_processed` suffix, and returns the new path.
  Future<String> process(String inputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw FormatException('Could not decode image at $inputPath');
    }

    var out = img.grayscale(decoded);
    out = img.normalize(out, min: 0, max: 255);
    out = img.adjustColor(out, contrast: 1.3);

    final outputPath = _deriveOutputPath(inputPath);
    await File(outputPath).writeAsBytes(img.encodeJpg(out, quality: 92));
    return outputPath;
  }

  String _deriveOutputPath(String inputPath) {
    final dot = inputPath.lastIndexOf('.');
    if (dot == -1) return '${inputPath}_processed.jpg';
    return '${inputPath.substring(0, dot)}_processed.jpg';
  }
}
