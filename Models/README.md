# Models/

Drop location for converted Core ML `.mlpackage` files used by the Camera + Mirror runtime inference stack.

| File | Source | Consumer | Size (INT8) |
|---|---|---|---|
| `ResNet50_INT8.mlpackage` | torchvision ResNet-50 | Camera content-aware filter selection | ~25 MB |
| `CLIP_Image_INT8.mlpackage` | openai/CLIP ViT-B/16 image encoder | Mirror 512-dim identity-axis embedding | ~85 MB |
| `SAM_ViT_B_INT8.mlpackage` | facebookresearch/SAM ViT-B mask decoder | Camera content-aware spatial scoping | ~95 MB |

These files are **git-ignored** (`.mlpackage` / `.mlmodelc` patterns) — they ship to the device via the App Store binary or on-demand resource fetch, not the source repo.

## Generating the files

One-time on a maintainer's Mac. The entry point is the hexa script (per project policy: hexa-only); coremltools + torch are an irreducible Python ML dependency invoked by the script under the hood:

```sh
pip install coremltools torch torchvision
pip install git+https://github.com/openai/CLIP.git
pip install git+https://github.com/facebookresearch/segment-anything.git

hexa scripts/convert_models.hexa resnet50   --out Models/ResNet50_INT8.mlpackage
hexa scripts/convert_models.hexa clip_image --out Models/CLIP_Image_INT8.mlpackage
hexa scripts/convert_models.hexa sam        --out Models/SAM_ViT_B_INT8.mlpackage
```

CLIP and SAM conversion paths are stub-NotImplemented in `scripts/convert_models.hexa` until their source-loading wrappers land — track via `camera.cond.2` and `parallel_self.cond.2` in `.roadmap.camera` / `.roadmap.parallel_self`.

## Loading from Swift

```swift
let url = Bundle.main.url(forResource: "ResNet50_INT8", withExtension: "mlmodelc")!
let model = try MLModel(contentsOf: url)
let processor = try VisionFrameProcessor(model: model)
let session = CameraSession(processor: processor)
```

`VisionFrameProcessor` is generic over any image-input `MLModel` — it preprocesses via `VNCoreMLRequest` (centerCrop + scale to model input shape) and records observations on a thread-safe lock.

## License

Each upstream model carries its own license:
- ResNet-50 weights: BSD-3-Clause (torchvision)
- CLIP weights: MIT (openai/CLIP)
- SAM weights: Apache 2.0 (facebookresearch/segment-anything)

This repo's MIT license covers only the Swift integration layer + conversion scripts, not the model weights themselves.
