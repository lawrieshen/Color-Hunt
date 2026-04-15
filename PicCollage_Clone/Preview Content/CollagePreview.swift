import SwiftUI

private extension CollagePhoto {
    static func preview(symbol: String) -> CollagePhoto {
        let uiImage = UIImage(systemName: symbol) ?? UIImage()
        let data = uiImage.jpegData(compressionQuality: 0.85) ?? Data()
        return CollagePhoto(image: Image(systemName: symbol), imageData: data)
    }
}

private func makeViewModel(count: Int, template: CollageLayoutTemplate) -> CollageLayoutViewModel {
    let vm = CollageLayoutViewModel()
    let photos = (0..<count).map { _ in CollagePhoto.preview(symbol: "mountain.2.fill") }
    vm.update(photos: photos)
    vm.update(template: template)
    return vm
}

#Preview("1 Photo — Single") {
    CollageGridView(viewModel: makeViewModel(count: 1, template: .single), onTap: { _ in })
        .padding()
}

#Preview("2 Photos — Side by Side") {
    CollageGridView(viewModel: makeViewModel(count: 2, template: .sideBySide), onTap: { _ in })
        .padding()
}

#Preview("3 Photos — Top Pair + Bottom (1 placeholder)") {
    CollageGridView(viewModel: makeViewModel(count: 2, template: .topPairBottomSingle), onTap: { _ in })
        .padding()
}

#Preview("4 Photos — 2×2 Grid") {
    CollageGridView(viewModel: makeViewModel(count: 4, template: .twoByTwo), onTap: { _ in })
        .padding()
}

#Preview("Create Tab") {
    CreateView(
        collageToLoad: .constant(nil),
        selectedTab: .constant(0),
        photosToLoad: .constant(nil as PhotosLoadRequest?)
    )
}
