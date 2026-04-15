import SwiftUI
import SwiftData

/// App entry point.
///
/// Attaches a SwiftData `ModelContainer` for ``SavedCollage`` so every view
/// in the hierarchy can access `@Environment(\.modelContext)` and `@Query`.
@main
struct PicCollageApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedCollage.self)
    }
}
