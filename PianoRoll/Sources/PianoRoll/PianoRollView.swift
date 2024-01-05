// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/PianoRoll/

import SwiftUI

/// Touch-oriented piano roll.
///
/// Note: Requires macOS 12 / iOS 15 due to SwiftUI bug (crashes in SwiftUI when deleting notes).
public struct PianoRollView: View {
    public enum Layout {
        case horizontal
        case vertical
    }

    @State private var selectionBox: CGRect?

    @Binding var model: PianoRollModel
    @Binding var selectedNotes: [PianoRollNote]
    var editable: Bool
    var gridColor: Color
    var gridSize: CGSize
    var noteColor: Color
    var noteLineOpacity: Double
    var layout: Layout
    var onNoteCreated: ((PianoRollNote) -> Void)?
    var gridDensityDivider: Int
    var currentVelocity: Int = 100

    /// Initialize PianoRoll with a binding to a model and a color
    /// - Parameters:
    ///   - editable: Disable edition of any note in piano roll
    ///   - model: PianoRoll data
    ///   - noteColor: Color to use for the note indicator, defaults to system accent color
    ///   - noteLineOpacity: Opacity of the note view vertical black line
    ///   - gridColor: Color of grid
    ///   - gridSize: Size of a grid cell
    public init(
        editable: Bool = true,
        model: Binding<PianoRollModel>,
        selectedNotes: Binding<[PianoRollNote]>,
        noteColor: Color = .accentColor,
        noteLineOpacity: Double = 1,
        gridColor: Color = Color(red: 15.0 / 255.0, green: 17.0 / 255.0, blue: 16.0 / 255.0),
        gridSize: CGSize = CGSize(width: 80, height: 40),
        layout: Layout = .horizontal,
        onNoteCreated: ((PianoRollNote) -> Void)? = nil,
        gridDensityDivider: Int
    ) {
        _model = model
        _selectedNotes = selectedNotes
        self.noteColor = noteColor
        self.noteLineOpacity = noteLineOpacity
        self.gridSize = gridSize
        self.gridColor = gridColor
        self.editable = editable
        self.layout = layout
        self.onNoteCreated = onNoteCreated
        self.gridDensityDivider = gridDensityDivider
    }

    private var width: CGFloat {
        CGFloat(model.length) * gridSize.width
    }

    private var height: CGFloat {
        CGFloat(model.range.upperBound - model.range.lowerBound) * gridSize.height
    }

    /// SwiftUI view with grid and ability to add, delete and modify notes
    public var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                let dragGesture = DragGesture(minimumDistance: 0).onEnded { value in
                    let location = value.location
                    var note: PianoRollNote
                    switch layout {
                    case .horizontal:
                        let step = floor(Double(Int(location.x / gridSize.width)))
                        let pitch = model.height - Int(location.y / gridSize.height)
                        note = PianoRollNote(start: step, length: 40, pitch: pitch, color: noteColor, velocity: currentVelocity)
                        onNoteCreated?(note)
                    case .vertical:
                        let step = Double(Int(location.y / gridSize.width))
                        let pitch = Int(location.x / gridSize.height)
                        note = PianoRollNote(
                            start: Double(model.length) - step - 1,
                            length: 1,
                            pitch: pitch + 1,
                            color: noteColor,
                            velocity: currentVelocity
                        )
                        model.notes.append(note)
                    }
                }
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: proxy.size.width / 4, height: proxy.size.height)
                        .foregroundColor(.white.opacity(0.1))
                    Rectangle()
                        .frame(width: proxy.size.width / 4, height: proxy.size.height)
                        .foregroundColor(.white.opacity(0.05))
                    Rectangle()
                        .frame(width: proxy.size.width / 4, height: proxy.size.height)
                        .foregroundColor(.white.opacity(0.1))
                    Rectangle()
                        .frame(width: proxy.size.width / 4, height: proxy.size.height)
                        .foregroundColor(.white.opacity(0.05))
                }
                PianoRollGrid(gridSize: gridSize, length: model.length, height: model.height, layout: layout, gridDensityDivider: gridDensityDivider)
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(gridColor)
                    .contentShape(Rectangle())
                    .gesture(editable ? TapGesture().sequenced(before: dragGesture) : nil)
                ForEach($model.notes) { $note in
                    switch layout {
                    case .horizontal:
                        GeometryReader { (proxy: GeometryProxy) in
                            PianoRollNoteView(
                                note: $note,
                                gridSize: gridSize,
                                color: noteColor,
                                sequenceLength: model.length,
                                sequenceHeight: model.height,
                                isContinuous: true,
                                editable: editable,
                                lineOpacity: noteLineOpacity,
                                onFrameObtained: { rect in
                                    if let index = model.notes.firstIndex(where: { $0.id == $note.id }) {
                                        DispatchQueue.main.async {
                                            model.notes[index].position = CGPoint(x: rect.midX, y: rect.midY - 70)
                                        }
                                    }
                                }
                            ).onTapGesture {
                                guard editable else { return }
                                // TOOD: - Index out of range ?
                                model.notes.removeAll(where: { $0 == note })
                            }
                        }


                    case .vertical:
                        VerticalPianoRollNoteView(
                            note: $note,
                            gridSize: gridSize,
                            color: noteColor,
                            sequenceLength: model.length,
                            sequenceHeight: model.height,
                            isContinuous: true,
                            editable: editable,
                            lineOpacity: noteLineOpacity
                        ).onTapGesture {
                            guard editable else { return }
                            model.notes.removeAll(where: { $0 == note })
                        }
                    }
                }
            }
        }.frame(width: layout == .horizontal ? width : height,
                height: layout == .horizontal ? height : width)

        .overlay(selectionBox != nil ? selectionBoxOverlay : nil)
        .gesture(dragGesture())
    }

    private var selectionBoxOverlay: some View {
        Rectangle()
            .stroke(Color.blue, lineWidth: 2)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(4)
            .frame(width: selectionBox?.size.width, height: selectionBox?.size.height)
            .position(x: selectionBox!.midX, y: selectionBox!.midY)
    }

    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let startPoint = value.startLocation
                let endPoint = value.location

                let x = min(startPoint.x, endPoint.x)
                let y = min(startPoint.y, endPoint.y)
                let width = abs(startPoint.x - endPoint.x)
                let height = abs(startPoint.y - endPoint.y)

                selectionBox = CGRect(x: x, y: y, width: width, height: height)

                let selectedNotes = model.notes.filter { note in
                    if let position = note.position {
                        return selectionBox!.contains(position)
                    } else {
                        return false
                    }
                }
                model.notes.forEach { note in
                    if let index = model.notes.firstIndex(where: { $0.id == note.id }) {
                        model.notes[index].selected = false
                    }
                }
                selectedNotes.forEach { note in
                    if let index = model.notes.firstIndex(where: { $0.id == note.id }) {
                        model.notes[index].selected = true
                    }
                }
                self.selectedNotes = selectedNotes
            }
            .onEnded { _ in
                selectionBox = nil
            }
    }
}

struct PianoRollPreview: View {
    init() {}

    @State var model = PianoRollModel(notes: [
        PianoRollNote(start: 1, length: 2, pitch: 3, velocity: 120),
        PianoRollNote(start: 5, length: 1, pitch: 4, velocity: 120),
    ], length: 128, height: 128)

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            PianoRollView(model: $model, selectedNotes: .constant([]), noteColor: .cyan, gridDensityDivider: 1)
        }.background(Color(white: 0.1))
    }
}

struct PianoRoll_Previews: PreviewProvider {
    static var previews: some View {
        PianoRollPreview()
    }
}
