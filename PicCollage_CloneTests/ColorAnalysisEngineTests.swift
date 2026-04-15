import Testing
import UIKit
@testable import PicCollage_Clone

@Suite("ColorAnalysisEngine")
struct ColorAnalysisEngineTests {

    private let engine = ColorAnalysisEngine()

    // MARK: Helpers

    /// Draws a solid-color image of the given size using UIGraphicsImageRenderer.
    private func makeImage(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: Dominant color

    @Test func solidRedImage_returnsDominantRed() {
        let image = makeImage(color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        let color = engine.dominantColor(for: image)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r > 0.9)
        #expect(g < 0.1)
        #expect(b < 0.1)
    }

    @Test func solidBlueImage_returnsDominantBlue() {
        let image = makeImage(color: UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        let color = engine.dominantColor(for: image)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r < 0.1)
        #expect(g < 0.1)
        #expect(b > 0.9)
    }

    @Test func invalidImage_returnsGray() {
        // UIImage() has no CGImage — engine should fall back to .gray
        let color = engine.dominantColor(for: UIImage())
        #expect(color == .gray)
    }

    @Test func dominantColor_rgbComponentsAreInValidRange() {
        let image = makeImage(color: UIColor(red: 0.4, green: 0.7, blue: 0.2, alpha: 1))
        let color = engine.dominantColor(for: image)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r >= 0 && r <= 1)
        #expect(g >= 0 && g <= 1)
        #expect(b >= 0 && b <= 1)
    }
}
