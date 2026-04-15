import SwiftUI
import SwiftData

/// Displays all saved collages in a reverse-chronological adaptive grid.
///
/// Tapping a card sets `gridToLoad` and switches the tab to Create so the
/// user can continue editing. Swipe-to-delete removes the record from SwiftData.
struct LibraryView: View {

    @Query(sort: \SavedGrid.createdAt, order: .reverse)
    private var collages: [SavedGrid]

    @Environment(\.modelContext) private var modelContext

    /// Written when the user taps a card; read by ``CreateView`` to load the collage.
    @Binding var gridToLoad: SavedGrid?

    /// Controls which tab is shown in the parent `TabView`.
    @Binding var selectedTab: Int

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if collages.isEmpty {
                    emptyState
                } else {
                    collageGrid
                }
            }
            .navigationTitle("Library")
        }
    }

    // MARK: Subviews

    private var emptyState: some View {
        ContentUnavailableView(
            "No Grids Yet",
            systemImage: "photo.stack",
            description: Text("Save a collage from the Create tab to see it here.")
        )
        .accessibilityIdentifier("libraryEmptyState")
    }

    private var collageGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(collages) { collage in
                    SavedGridCardView(collage: collage) {
                        gridToLoad = collage
                        selectedTab = 0
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(collage)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .accessibilityIdentifier("libraryGrid")
    }
}
