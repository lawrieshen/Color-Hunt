# ColorHunt

A SwiftUI iOS app that finds photos in your library matching a color you choose — then arranges the best matches into a collage.

## Features

### Color Hunt
Pick any target color. The app scans your photo library (last 30 days), ranks photos by color similarity using hardware-accelerated analysis, and automatically selects the best-fit collage layout.

### Create
Choose a layout template and arrange color-matched photos into a collage. Finished collages can be saved to your photo library.

**Layout templates**
| Template | Slots |
|---|---|
| Single | 1 |
| Side by Side | 2 |
| Top Pair / Bottom Single | 3 |
| 2 × 2 | 4 |
| 3 × 3 | 9 |

### Library
Browse and revisit collages you've saved within the app.

## Demo

https://github.com/user-attachments/assets/1ba6eb9e-3133-4af4-92c2-ab0d87f70008

https://github.com/user-attachments/assets/b0543777-9280-4b94-855c-f21b2c33c7b4

## Architecture

```
ColorHunt/
├── App/               # Entry point, root ContentView
├── Engine/            # GridLayoutEngine, GridRenderer, ColorAnalysisEngine
├── Models/            # GridPhoto, ColorHuntPhoto, SavedGrid
├── Protocols/         # GridLayoutProviding, GridRendering, ColorHuntProviding
├── ViewModels/        # GridViewModel, ColorHuntViewModel
└── Views/
    ├── CreateTab/     # GridView, GridCellView
    ├── ColorHuntTab/  # ColorHuntView
    └── LibraryTab/    # LibraryView, SavedGridCardView
```

**Key design decisions**
- `ColorAnalysisEngine` uses k-means++ clustering via **Accelerate / vDSP** and **BNNS** for fast, hardware-accelerated dominant color extraction.
- `ColorHuntViewModel` caps concurrent `PHImageManager` requests at 4 using a Swift actor-based semaphore to prevent memory pressure on large libraries.
- All engines are injected through protocols, making them swappable in unit tests without mocking the photo library.

## Requirements

- Xcode 16+
- iOS 18+ / iPadOS 18+
- Swift 6

## Running

1. Open `PicCollage_Clone.xcodeproj` in Xcode.
2. Select a simulator or a connected device.
3. Build and run (`⌘R`).

Photo library access is required for the Color Hunt and Create tabs. The app will prompt for permission on first launch.

## Tests

Unit tests live in `PicCollage_CloneTests/`. Run them with `⌘U` in Xcode or:

```bash
xcodebuild test \
  -project PicCollage_Clone.xcodeproj \
  -scheme PicCollage_Clone \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' \
  -only-testing:PicCollage_CloneTests
```

**Test coverage**
| Suite | What's tested |
|---|---|
| `ColorAnalysisEngineTests` | Dominant color extraction |
| `ColorHuntViewModelTests` | Template selection logic |
| `GridLayoutEngineTests` | Slot geometry per template |
| `GridViewModelTests` | ViewModel state transitions |
| `UIColorDistanceTests` | Color distance metric |

## Licenses

### This project

Copyright (c) 2025 Lawrence Shen — released under the [MIT License](LICENSE).

### Third-party & referenced code

The color analysis in `Engine/ColorAnalysisEngine.swift` references Apple sample code, used under the Apple MIT License:

Copyright © 2024 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
