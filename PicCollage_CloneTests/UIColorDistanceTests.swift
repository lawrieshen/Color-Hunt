import Testing
import UIKit
@testable import PicCollage_Clone

@Suite("UIColor.distance")
struct UIColorDistanceTests {

    @Test func identicalColors_distanceIsZero() {
        let color = UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1)
        #expect(color.distance(to: color) == 0)
    }

    @Test func blackAndWhite_distanceIsMaximum() {
        let d = UIColor.black.distance(to: UIColor.white)
        #expect(abs(d - sqrt(3)) < 0.001)
    }

    @Test func distance_isSymmetric() {
        let a = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        let b = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        #expect(a.distance(to: b) == b.distance(to: a))
    }

    @Test func redAndBlue_distanceIsSqrt2() {
        let red = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        let blue = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        let d = red.distance(to: blue)
        #expect(abs(d - sqrt(2)) < 0.001)
    }
}
