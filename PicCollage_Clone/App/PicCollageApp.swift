import SwiftUI
import SwiftData

/// App entry point.
///
/// Attaches a SwiftData `ModelContainer` for ``SavedGrid`` so every view
/// in the hierarchy can access `@Environment(\.modelContext)` and `@Query`.
@main
struct ColorHuntApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedGrid.self)
    }
}
