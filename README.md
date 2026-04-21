# ColorHunt

A SwiftUI iOS app that finds photos in your library matching a color you choose — then arranges the best matches into a collage.
<div align="center">
    
<table style="width: 50%; height: 50%; border-collapse: collapse; border: none;">
  <tr style="border: none;">
    <td width="50%" align="center" style="border: none; vertical-align: middle;">
      <video src="https://github.com/user-attachments/assets/1ba6eb9e-3133-4af4-92c2-ab0d87f70008" width="100%">
    </td>
    <td width="50%" align="center" style="border: none; vertical-align: middle;">
      <video src="https://github.com/user-attachments/assets/b0543777-9280-4b94-855c-f21b2c33c7b4" width="100%"></video>
    </td>
  </tr>
</table>

</div>

## Inspiration and Technical Background

This project is inspired by **PicCollage's** feature to arrange photos to create collage and Apple's official documentation on **[Calculating the Dominant Colors in an Image](https://developer.apple.com/documentation/Accelerate/calculating-the-dominant-colors-in-an-image)**.
To determine the most prominent colors in a photo, the app implements **k-means clustering** using the **Accelerate framework**. This allows for high-performance pixel processing and vector calculations, ensuring that color matching is both fast and accurate even with large photo libraries.

<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr style="border: none;">
    <td width="25%" align="center" style="border: none; vertical-align: middle;">
      <img src="https://github.com/user-attachments/assets/9a3d4264-093a-47d5-94b1-394a28f8f4f4" width="100%" alt="Dominant Color Analysis">
      <br><em></em>
    </td>
    <td width="75%" align="center" style="border: none; vertical-align: middle;">
      <video src="https://github.com/user-attachments/assets/1823606e-1485-4f19-a1cf-4759686c135d" width="100%" controls title="App Demo"></video>
      <br><em>Apple's demo</em>
    </td>
  </tr>
</table>

### What is Color Hunt?

The Color Hunt is a viral visual scavenger hunt and social media trend where participants explore their environment to document objects of a specific hue. By curating these findings into aesthetic photo grids, users share them on their Instagram Stories to either express their mood or do this trend with their friends to create core memories.

<div align="center">

<table>
  <tr>
    <td><img width="168" height="299" alt="image" src="https://github.com/user-attachments/assets/ab481be2-e832-4647-8872-fab2b42487b8" /></td>
    <td><img width="188" height="269" alt="image" src="https://github.com/user-attachments/assets/8bd950e6-0cd8-4886-ab19-dac815ec7eb5" /></td>
    <td><img width="168" height="299" alt="image" src="https://github.com/user-attachments/assets/74afb86e-28f5-4095-96cc-4d41e5a9d349" /></td>
    <td><img width="187" height="269" alt="image" src="https://github.com/user-attachments/assets/e115ea87-a680-4fc2-93a7-96ec43376ca7" /></td>
  </tr>
</table>

</div>

### The Math behind the Color Matching

The app treats each image as a collection of data points in a 3D coordinate system (RGB). To find the dominant colors, we minimize the squared Euclidean distance between pixels and their cluster centroids:

<div align="center">
    
$`J = \sum_{j=1}^{k} \sum_{x \in S_j} \|x - \mu_j\|^2`$

</div>

Where:
- $`k`$: The number of dominant colors you want to find.
- $`S_j`$: The set of pixels assigned to cluster $`j`$.
- $`x`$: The RGB color vector of a specific pixel.
- $`\mu_j`$: The centroid (mean color) of cluster $`j`$.

Using the **Accelerate framework**, we perform these vector subtractions and summations in parallel, allowing the app to analyze your photo library in real-time.

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
