import SwiftUI
import PhotosUI
import SwiftData

/// The main collage-editing screen.
///
/// Responsibilities:
/// - Hosts ``CollageGridView`` driven by ``CollageLayoutViewModel``.
/// - Provides a bulk `PhotosPicker` (toolbar leading) to fill all slots at once.
/// - Allows per-cell replacement via a sheet-presented `PhotosPicker`.
/// - Saves the finished collage to SwiftData + Photos library.
/// - Reacts to `collageToLoad` to restore a saved collage from the Library tab.
struct CreateView: View {

    @StateObject private var viewModel = CollageLayoutViewModel()
    @Environment(\.modelContext) private var modelContext

    /// Set by ``LibraryView`` when the user taps a saved collage card.
    @Binding var collageToLoad: SavedCollage?

    /// Drives the parent `TabView` selection so saving can keep the user on Create.
    @Binding var selectedTab: Int

    /// Set by ``ColorHuntView`` to pre-fill the grid with color-matched photos.
    @Binding var photosToLoad: PhotosLoadRequest?

    @State private var bulkPickerItems: [PhotosPickerItem] = []
    @State private var activePickerIndex: Int? = nil
    @State private var cellPickerItem: [PhotosPickerItem] = []
    @State private var saveError: Error? = nil
    @State private var showSaveError = false

    var body: some View {
        navigationContent
            .onChange(of: bulkPickerItems) { _, items in loadPhotos(from: items, replacing: nil) }
            .onChange(of: cellPickerItem) { _, items in
                guard let index = activePickerIndex, let item = items.first else { return }
                loadPhotos(from: [item], replacing: index)
                activePickerIndex = nil
                cellPickerItem = []
            }
            .onChange(of: collageToLoad) { _, collage in
                guard let collage else { return }
                viewModel.load(from: collage)
                collageToLoad = nil
            }
            .onChange(of: photosToLoad) { _, _ in applyPhotosToLoad() }
    }

    private var navigationContent: some View {
        NavigationStack {
            VStack(spacing: 12) {
                templatePicker
                aspectRatioPicker
                collageGrid
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Create")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { bulkPickerButton }
                ToolbarItem(placement: .topBarTrailing) { saveButton }
            }
            .sheet(isPresented: Binding(
                get: { activePickerIndex != nil },
                set: { if !$0 { activePickerIndex = nil } }
            )) {
                cellReplacementPicker
            }
            .alert("Save Failed", isPresented: $showSaveError, presenting: saveError) { _ in
                Button("OK", role: .cancel) {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: Subviews

    private var templatePicker: some View {
        Picker("Layout", selection: $viewModel.template) {
            ForEach(CollageLayoutTemplate.allCases) { template in
                Text(template.displayName).tag(template)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .accessibilityIdentifier("templatePicker")
    }

    private var aspectRatioPicker: some View {
        Picker("Aspect Ratio", selection: $viewModel.aspectRatio) {
            ForEach(CollageAspectRatio.allCases) { ratio in
                Text(ratio.displayName).tag(ratio)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .accessibilityIdentifier("aspectRatioPicker")
    }

    private var collageGrid: some View {
        CollageGridView(viewModel: viewModel) { index in
            activePickerIndex = index
        }
    }

    private var bulkPickerButton: some View {
        PhotosPicker(
            selection: $bulkPickerItems,
            maxSelectionCount: viewModel.template.rawValue,
            matching: .images
        ) {
            Label("Add Photos", systemImage: "photo.badge.plus")
        }
        .accessibilityIdentifier("addPhotosButton")
    }

    private var saveButton: some View {
        Button {
            Task {
                do {
                    try await viewModel.save(gridView: collageGrid, context: modelContext)
                } catch {
                    saveError = error
                    showSaveError = true
                }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
            } else {
                Text("Save")
            }
        }
        .disabled(viewModel.photos.isEmpty || viewModel.isSaving)
        .accessibilityIdentifier("saveButton")
    }

    private var cellReplacementPicker: some View {
        PhotosPicker(
            selection: $cellPickerItem,
            maxSelectionCount: 1,
            matching: .images
        ) {
            Label("Choose Photo", systemImage: "photo")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .presentationDetents([.medium])
    }

    // MARK: Helpers

    private func applyPhotosToLoad() {
        guard let request = photosToLoad else { return }
        viewModel.update(photos: request.photos)
        viewModel.update(template: request.template)
        photosToLoad = nil
    }

    private func loadPhotos(from items: [PhotosPickerItem], replacing replacingIndex: Int?) {
        Task {
            var loaded: [CollagePhoto] = []
            for item in items {
                guard
                    let data = try? await item.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data),
                    let jpegData = uiImage.jpegData(compressionQuality: 0.85)
                else { continue }
                loaded.append(CollagePhoto(image: Image(uiImage: uiImage), imageData: jpegData))
            }
            if let index = replacingIndex {
                if let first = loaded.first {
                    viewModel.replacePhoto(at: index, with: first)
                }
            } else {
                viewModel.update(photos: loaded)
            }
        }
    }
}
