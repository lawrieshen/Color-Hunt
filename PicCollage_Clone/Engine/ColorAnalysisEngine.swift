import UIKit
import Accelerate

/// Finds the dominant color in a photo using k-means++ clustering.
///
/// The image is downscaled to a small working resolution before analysis,
/// keeping each call fast while preserving enough color detail. Pixels are
/// grouped into `k` color clusters; the cluster with the most pixels wins.
/// Implements ``ColorHuntProviding`` so it can be swapped or mocked in tests.
struct ColorAnalysisEngine: ColorHuntProviding {

    nonisolated init() {}

    private let dimension = 48
    private let k = 2
    private let maxIter = 20
    private let tolerance = 10

    private struct Centroid {
        var red: Float
        var green: Float
        var blue: Float
        var pixelCount: Int = 0
    }

    // MARK: - ColorHuntProviding

    func dominantColor(for image: UIImage) -> UIColor {
        guard let cgImage = image.cgImage else { return .gray }

        let count = dimension * dimension
        let redStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: count)
        let greenStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: count)
        let blueStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: count)
        defer {
            redStorage.deallocate()
            greenStorage.deallocate()
            blueStorage.deallocate()
        }

        guard extractPixels(from: cgImage, red: redStorage, green: greenStorage, blue: blueStorage) else {
            return .gray
        }

        let dominant = kMeans(red: redStorage, green: greenStorage, blue: blueStorage)

        return UIColor(
            red: CGFloat(dominant.red),
            green: CGFloat(dominant.green),
            blue: CGFloat(dominant.blue),
            alpha: 1
        )
    }

    // MARK: - Pixel extraction

    /// 32-bit float RGB format for decoding CGImages into normalised 0–1 channel data.
    /// Stored as a static to avoid re-creating the CGColorSpace on every call.
    private static var rgbFormat: vImage_CGImageFormat = {
        vImage_CGImageFormat(
            bitsPerComponent: 32,
            bitsPerPixel: 32 * 3,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue:
                kCGBitmapByteOrder32Host.rawValue |
                CGBitmapInfo.floatComponents.rawValue |
                CGImageAlphaInfo.none.rawValue))!
    }()

    /// Decodes and downscales `cgImage` into three separate Float arrays — one per
    /// RGB channel — with values normalised to 0–1. Returns `false` if the image
    /// cannot be decoded.
    private func extractPixels(
        from cgImage: CGImage,
        red: UnsafeMutableBufferPointer<Float>,
        green: UnsafeMutableBufferPointer<Float>,
        blue: UnsafeMutableBufferPointer<Float>
    ) -> Bool {
        var rgbFormat = Self.rgbFormat

        guard let source = try? vImage.PixelBuffer<vImage.InterleavedFx3>(
            cgImage: cgImage,
            cgImageFormat: &rgbFormat
        ) else { return false }

        let planes = source.planarBuffers()  // [R, G, B]
        let byteCountPerRow = dimension * MemoryLayout<Float>.stride

        let redDst = vImage.PixelBuffer<vImage.PlanarF>(
            data: red.baseAddress!, width: dimension, height: dimension,
            byteCountPerRow: byteCountPerRow)
        let greenDst = vImage.PixelBuffer<vImage.PlanarF>(
            data: green.baseAddress!, width: dimension, height: dimension,
            byteCountPerRow: byteCountPerRow)
        let blueDst = vImage.PixelBuffer<vImage.PlanarF>(
            data: blue.baseAddress!, width: dimension, height: dimension,
            byteCountPerRow: byteCountPerRow)

        planes[0].scale(destination: redDst)
        planes[1].scale(destination: greenDst)
        planes[2].scale(destination: blueDst)

        return true
    }

    // MARK: - K-means

    private func kMeans(
        red: UnsafeMutableBufferPointer<Float>,
        green: UnsafeMutableBufferPointer<Float>,
        blue: UnsafeMutableBufferPointer<Float>
    ) -> Centroid {
        let count = red.count

        let work = UnsafeMutableBufferPointer<Float>.allocate(capacity: count)
        let distances = UnsafeMutableBufferPointer<Float>.allocate(capacity: count * k)
        let centroidIndicesDescriptor = BNNSNDArrayDescriptor.allocateUninitialized(
            scalarType: Int32.self,
            shape: .matrixRowMajor(count, 1))

        // Build descriptors and the reduction layer once — reused across all iterations.
        let distDesc = BNNSNDArrayDescriptor(data: distances, shape: .matrixRowMajor(count, k))!
        let reductionLayer = BNNS.ReductionLayer(
            function: .argMin,
            input: distDesc,
            output: centroidIndicesDescriptor,
            weights: nil)

        defer {
            work.deallocate()
            distances.deallocate()
            centroidIndicesDescriptor.deallocate()
        }

        var centroids = initializeCentroids(red: red, green: green, blue: blue, work: work)

        // Raw pointer into the indices descriptor — avoids a heap alloc per iteration.
        let indicesPtr = centroidIndicesDescriptor.data!.assumingMemoryBound(to: Int32.self)

        for _ in 0..<maxIter {
            // Populate distances matrix: row j = distance^2 from every pixel to centroid j
            for (j, centroid) in centroids.enumerated() {
                computeDistanceSquared(
                    red: red, green: green, blue: blue,
                    to: centroid, count: count,
                    result: distances.baseAddress!.advanced(by: count * j),
                    work: work)
            }

            // BNNS argMin: assign each pixel to its nearest centroid
            try? reductionLayer?.apply(batchSize: 1, input: distDesc, output: centroidIndicesDescriptor)

            // Update centroids via single-pass accumulation over the raw indices pointer
            let prevCounts = centroids.map { $0.pixelCount }
            var sumR = Array(repeating: Float(0), count: k)
            var sumG = Array(repeating: Float(0), count: k)
            var sumB = Array(repeating: Float(0), count: k)
            var counts = Array(repeating: 0, count: k)

            for i in 0..<count {
                let j = Int(indicesPtr[i])
                sumR[j] += red[i]
                sumG[j] += green[i]
                sumB[j] += blue[i]
                counts[j] += 1
            }

            for j in 0..<k {
                centroids[j].pixelCount = counts[j]
                guard counts[j] > 0 else { continue }
                let inv = 1.0 / Float(counts[j])
                centroids[j].red = sumR[j] * inv
                centroids[j].green = sumG[j] * inv
                centroids[j].blue = sumB[j] * inv
            }

            // Convergence: pixel counts stable within tolerance
            let converged = zip(prevCounts, centroids).allSatisfy { abs($0 - $1.pixelCount) < tolerance }
            if converged { break }
        }

        return centroids.max(by: { $0.pixelCount < $1.pixelCount })!
    }

    // MARK: - K-means++ initialisation

    private func initializeCentroids(
        red: UnsafeMutableBufferPointer<Float>,
        green: UnsafeMutableBufferPointer<Float>,
        blue: UnsafeMutableBufferPointer<Float>,
        work: UnsafeMutableBufferPointer<Float>
    ) -> [Centroid] {
        let count = red.count
        var centroids: [Centroid] = []

        let first = Int.random(in: 0..<count)
        centroids.append(Centroid(red: red[first], green: green[first], blue: blue[first]))

        let distResult = UnsafeMutableBufferPointer<Float>.allocate(capacity: count)
        defer { distResult.deallocate() }

        for i in 1..<k {
            computeDistanceSquared(
                red: red, green: green, blue: blue,
                to: centroids[i - 1], count: count,
                result: distResult.baseAddress!,
                work: work)
            let next = weightedRandomIndex(distResult)
            centroids.append(Centroid(red: red[next], green: green[next], blue: blue[next]))
        }

        return centroids
    }

    // MARK: - vDSP distance^2

    /// Writes the squared RGB distance from each pixel to `centroid` into `result`:
    /// `result[i] = (r[i]-cr)^2 + (g[i]-cg)^2 + (b[i]-cb)^2`.
    /// `work` is a scratch buffer — its contents after the call are undefined.
    private func computeDistanceSquared(
        red: UnsafeMutableBufferPointer<Float>,
        green: UnsafeMutableBufferPointer<Float>,
        blue: UnsafeMutableBufferPointer<Float>,
        to centroid: Centroid,
        count: Int,
        result: UnsafeMutablePointer<Float>,
        work: UnsafeMutableBufferPointer<Float>
    ) {
        let n = vDSP_Length(count)

        var negR = -centroid.red
        vDSP_vsadd(red.baseAddress!, 1, &negR, result, 1, n)
        vDSP_vsq(result, 1, result, 1, n)

        var negG = -centroid.green
        vDSP_vsadd(green.baseAddress!, 1, &negG, work.baseAddress!, 1, n)
        vDSP_vsq(work.baseAddress!, 1, work.baseAddress!, 1, n)
        vDSP_vadd(result, 1, work.baseAddress!, 1, result, 1, n)

        var negB = -centroid.blue
        vDSP_vsadd(blue.baseAddress!, 1, &negB, work.baseAddress!, 1, n)
        vDSP_vsq(work.baseAddress!, 1, work.baseAddress!, 1, n)
        vDSP_vadd(result, 1, work.baseAddress!, 1, result, 1, n)
    }

    // MARK: - BNNS weighted random index

    /// Returns a random index sampled in proportion to each weight — higher-weight
    /// indices are chosen more often. Used by k-means++ to spread initial centroids
    /// away from each other across the color space.
    private func weightedRandomIndex(_ weights: UnsafeMutableBufferPointer<Float>) -> Int {
        var outputDescriptor = BNNSNDArrayDescriptor.allocateUninitialized(
            scalarType: Float.self,
            shape: .vector(1))
        var probabilities = BNNSNDArrayDescriptor(data: weights, shape: .vector(weights.count))!
        let rng = BNNSCreateRandomGenerator(BNNSRandomGeneratorMethodAES_CTR, nil)
        BNNSRandomFillCategoricalFloat(rng, &outputDescriptor, &probabilities, false)
        defer {
            BNNSDestroyRandomGenerator(rng)
            outputDescriptor.deallocate()
        }
        return Int(outputDescriptor.makeArray(of: Float.self)!.first!)
    }
}
