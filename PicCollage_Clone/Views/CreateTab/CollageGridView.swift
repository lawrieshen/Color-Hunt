import SwiftUI

/// Responsive grid that arranges ``CollageCellView`` instances for the active template.
///
/// `GeometryReader` derives cell dimensions from the available width so the
/// layout scales correctly on every iPhone and iPad screen size.
/// Cells are grouped into rows by their ``CollageLayoutSlot/row`` value so that
/// spanning cells (e.g. the bottom slot in `.topPairBottomSingle`) get the
/// correct width automatically.
struct CollageGridView: View {

    @ObservedObject var viewModel: CollageLayoutViewModel

    /// Gap between cells in points.
    var spacing: CGFloat = 0

    /// Called when the user taps a cell, passing its zero-based slot index.
    let onTap: (Int) -> Void

    var body: some View {
        let r = viewModel.aspectRatio.value
        let rows = viewModel.rowCount
        let cols = viewModel.columnCount

        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(groupedRows(from: viewModel.cells), id: \.first?.slot.row) { rowCells in
                GridRow {
                    ForEach(rowCells, id: \.slot.id) { item in
                        // Cell aspect ratio = columnSpan × gridAR × rows/cols
                        // Derived from: cellW/cellH = (span/cols × W) / (1/rows × W/r)
                        let cellAR = CGFloat(item.slot.columnSpan) * r
                                   * CGFloat(rows) / CGFloat(cols)
                        CollageCellView(
                            photo: item.photo,
                            index: item.slot.id,
                            onTap: onTap
                        )
                        .aspectRatio(cellAR, contentMode: .fit)
                        .gridCellColumns(item.slot.columnSpan)
                    }
                }
            }
        }
        .aspectRatio(r, contentMode: .fit)
    }

    /// Groups the flat cells array into row buckets, sorted by row index.
    private func groupedRows(
        from cells: [(slot: CollageLayoutSlot, photo: CollagePhoto?)]
    ) -> [[(slot: CollageLayoutSlot, photo: CollagePhoto?)]] {
        let grouped = Dictionary(grouping: cells, by: { $0.slot.row })
        return grouped.keys.sorted().map { grouped[$0]! }
    }
}
