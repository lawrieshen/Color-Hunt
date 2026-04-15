import SwiftUI
import SwiftData

/// Root view of the app. Hosts the two-tab navigation shell.
///
/// `ContentView` owns the cross-tab binding state that lets `LibraryView`
/// trigger a collage re-load in `CreateView`:
/// - `selectedTab` drives which tab is visible.
/// - `collageToLoad` carries the ``SavedCollage`` the user tapped in the Library.
///   `CreateView` observes it, calls `viewModel.load(from:)`, then clears it.
/// - `photosToLoad` carries color-ranked photos from ``ColorHuntView`` to ``CreateView``.
struct ContentView: View {

    @State private var selectedTab: Int = 0
    @State private var collageToLoad: SavedCollage? = nil
    @State private var photosToLoad: PhotosLoadRequest? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            CreateView(collageToLoad: $collageToLoad, selectedTab: $selectedTab, photosToLoad: $photosToLoad)
                .tabItem { Label("Create", systemImage: "plus.rectangle.on.rectangle") }
                .tag(0)

            LibraryView(collageToLoad: $collageToLoad, selectedTab: $selectedTab)
                .tabItem { Label("Library", systemImage: "photo.on.rectangle") }
                .tag(1)

            ColorHuntView(selectedTab: $selectedTab, photosToLoad: $photosToLoad)
                .tabItem { Label("Color Hunt", systemImage: "paintpalette") }
                .tag(2)
        }
    }
}
