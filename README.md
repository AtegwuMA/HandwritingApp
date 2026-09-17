# Handwriting-to-Text App

Offline handwriting recognition with AI context correction. Full plan and
phase breakdown: [docs/PROJECT_PLAN.txt](docs/PROJECT_PLAN.txt).

Note: the plan document specifies a native Kotlin/Android app; this repo
implements the mobile app in **Flutter** instead (per project decision) so
the same codebase can target iOS without a rewrite. The pipeline stages
(preprocessing -> HTR -> fast-pass correction -> context correction ->
review UI -> storage) are unchanged; only the mobile implementation
language differs from the original doc.

## Status

- [x] Phase 0 — repo scaffolding
- [x] Phase 2 — MVP Flutter app (camera/gallery capture, ML Kit HTR,
      SymSpell correction, review/edit UI, local storage)
- [ ] Phase 1 — HTR benchmarking harness (skeleton in `ml/eval/`, not yet
      run against a labeled sample set)
- [ ] Phase 3+ — custom model training, on-device integration, cloud mode

## Layout

```
mobile/    Flutter app (see mobile/README.md to build/run — flutter create
           needs to be run once, since this was scaffolded without the
           Flutter SDK installed)
ml/        Python: training/export/eval (see ml/requirements.txt)
backend/   Spring Boot cloud service — Phase 2+ (optional), not started
docs/
```

## Getting the mobile app running

See [mobile/README.md](mobile/README.md) — requires the Flutter SDK
(not installed in the environment this was scaffolded in).

## Getting the Python side running

```bash
cd ml
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```
