import SwiftUI

/// Lets the user pick a target color, analyses the past 30 days of photos,
/// and presents the closest matches in a collage grid.
struct ColorHuntView: View {

    @Binding var selectedTab: Int

    /// Written by this view; read by ``CreateView`` to pre-fill the grid.
    @Binding var photosToLoad: PhotosLoadRequest?

    @StateObject private var viewModel = ColorHuntViewModel()
    @StateObject private var gridViewModel = CollageLayoutViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                colorPickerRow

                if viewModel.isAnalyzing {
                    Spacer()
                    ProgressView("Analysing photos…")
                        .accessibilityIdentifier("analysingIndicator")
                    Spacer()
                } else if viewModel.accessDenied {
                    accessDeniedState
                } else if viewModel.rankedPhotos.isEmpty {
                    emptyState
                } else {
                    CollageGridView(viewModel: gridViewModel) { _ in }
                        .padding(.horizontal)
                    sendToCreateButton
                    Spacer()
                }
            }
            .navigationTitle("Color Hunt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { huntButton }
            }
        }
        .onChange(of: viewModel.rankedPhotos) { _, photos in
            updateGrid(with: photos)
        }
    }

    // MARK: Subviews

    private var colorPickerRow: some View {
        ColorPicker("Hunt for color", selection: $viewModel.targetColor)
            .padding(.horizontal)
            .accessibilityIdentifier("colorPicker")
    }

    private var huntButton: some View {
        Button("Hunt") {
            Task { await viewModel.analyze() }
        }
        .disabled(viewModel.isAnalyzing)
        .accessibilityIdentifier("huntButton")
    }

    @ViewBuilder private var emptyState: some View {
        Spacer()
        ContentUnavailableView(
            "No Photos This Month",
            systemImage: "camera.badge.clock",
            description: Text("Start Color Hunt")
        )
        .accessibilityIdentifier("colorHuntEmptyState")
        Spacer()
    }

    @ViewBuilder private var accessDeniedState: some View {
        Spacer()
        ContentUnavailableView(
            "Photos Access Required",
            systemImage: "lock.shield",
            description: Text("Go to Settings → Privacy → Photos and allow access.")
        )
        .accessibilityIdentifier("colorHuntAccessDenied")
        Spacer()
    }

    private var sendToCreateButton: some View {
        Button {
            photosToLoad = PhotosLoadRequest(
                photos: viewModel.topPhotos.map { $0.asCollagePhoto() },
                template: viewModel.suggestedTemplate
            )
            selectedTab = 0
        } label: {
            Label("Send to Create", systemImage: "arrow.up.forward.square")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .accessibilityIdentifier("sendToCreateButton")
    }

    // MARK: Helpers

    private func updateGrid(with photos: [ColorHuntPhoto]) {
        let collagePhotos = viewModel.topPhotos.map { $0.asCollagePhoto() }
        gridViewModel.update(photos: collagePhotos)
        gridViewModel.update(template: viewModel.suggestedTemplate)
    }
}
