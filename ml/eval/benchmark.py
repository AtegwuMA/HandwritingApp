"""
Phase 1 benchmarking harness: compares candidate HTR engines on a labeled
sample set and reports CER/WER. This decides which HTR path (ML Kit
baseline vs. off-the-shelf TrOCR vs. later a fine-tuned model) gets
investment in Phase 3.

Usage:
    python benchmark.py --manifest samples/manifest.csv [--ml-kit-results samples/ml_kit_results.json]

manifest.csv format: image_path,ground_truth
    (paths relative to the manifest file's directory)

ML Kit runs on-device only, so its outputs come from a separate Android
instrumented test that dumps {image_path: recognized_text} to JSON; this
script folds those results in as one more engine to compare rather than
re-implementing ML Kit in Python.
"""

import argparse
import csv
import json
from pathlib import Path

from metrics import character_error_rate, word_error_rate


def load_manifest(manifest_path: Path) -> list[tuple[Path, str]]:
    base_dir = manifest_path.parent
    rows = []
    with manifest_path.open(newline="", encoding="utf-8") as f:
        for image_path, ground_truth in csv.reader(f):
            rows.append((base_dir / image_path, ground_truth))
    return rows


def run_trocr(image_paths: list[Path]) -> dict[str, str]:
    from PIL import Image
    from transformers import TrOCRProcessor, VisionEncoderDecoderModel

    processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten")
    model = VisionEncoderDecoderModel.from_pretrained(
        "microsoft/trocr-base-handwritten"
    )

    results = {}
    for path in image_paths:
        image = Image.open(path).convert("RGB")
        pixel_values = processor(images=image, return_tensors="pt").pixel_values
        generated_ids = model.generate(pixel_values)
        results[str(path)] = processor.batch_decode(
            generated_ids, skip_special_tokens=True
        )[0]
    return results


def report(engine_name: str, predictions: dict[str, str], rows: list[tuple[Path, str]]):
    cers, wers = [], []
    for path, ground_truth in rows:
        hypothesis = predictions.get(str(path), "")
        cers.append(character_error_rate(ground_truth, hypothesis))
        wers.append(word_error_rate(ground_truth, hypothesis))

    mean_cer = sum(cers) / len(cers) if cers else float("nan")
    mean_wer = sum(wers) / len(wers) if wers else float("nan")
    print(f"{engine_name}: CER={mean_cer:.4f}  WER={mean_wer:.4f}  n={len(rows)}")
    return {"engine": engine_name, "cer": mean_cer, "wer": mean_wer, "n": len(rows)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--ml-kit-results", type=Path, default=None)
    parser.add_argument("--skip-trocr", action="store_true")
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()

    rows = load_manifest(args.manifest)
    image_paths = [path for path, _ in rows]
    summaries = []

    if args.ml_kit_results and args.ml_kit_results.exists():
        ml_kit_predictions = json.loads(args.ml_kit_results.read_text())
        summaries.append(report("ml_kit", ml_kit_predictions, rows))

    if not args.skip_trocr:
        trocr_predictions = run_trocr(image_paths)
        summaries.append(report("trocr_base_handwritten", trocr_predictions, rows))

    if args.output:
        args.output.write_text(json.dumps(summaries, indent=2))


if __name__ == "__main__":
    main()
