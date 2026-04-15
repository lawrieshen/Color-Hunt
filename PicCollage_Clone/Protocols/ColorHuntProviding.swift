//
//  ColorHuntProviding.swift
//  PicCollage_Clone
//
//  Created by Lawrence Shen on 14/4/2026.
//

import UIKit

// MARK: - ColorHuntProviding

/// Extracts the dominant color from a `UIImage`.
///
/// Conforming types are injected into ``ColorHuntViewModel``, keeping the
/// analysis algorithm swappable and mockable in tests.
protocol ColorHuntProviding {
    func dominantColor(for image: UIImage) -> UIColor
}

// MARK: - UIColor distance

extension UIColor {
    /// Euclidean distance between two colors in the RGB unit cube (0–1 per channel).
    ///
    /// Lower value means a closer color match to the user's target.
    func distance(to other: UIColor) -> CGFloat {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let dr = r1 - r2, dg = g1 - g2, db = b1 - b2
        return sqrt(dr * dr + dg * dg + db * db)
    }
}
