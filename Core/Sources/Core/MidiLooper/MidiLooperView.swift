//
//  File.swift
//
//
//  Created by Tom Novotny on 10.07.2023.
//

import Controls
import SwiftUI
import PianoRoll

struct MidiLooperView: View {
    @StateObject var viewModel: MidiLooperViewModel

    var body: some View {
        VStack {
                GeometryReader { proxy in
                    ZStack {
                        PianoRollView(
                            model: $viewModel.pianoRollModel,
                            selectedNotes: $viewModel.selectedNotes,
                            noteColor: .cyan,
                            gridColor: .white,
                            gridSize: CGSize(
                                width: proxy.size.width / CGFloat(viewModel.pianoRollModel.length),
                                height: proxy.size.height / CGFloat(viewModel.pianoRollModel.range.count)
                            ),
                            layout: .horizontal,
                            onNoteCreated: viewModel.onNoteCreated,
                            gridDensityDivider: viewModel.gridDensityDivider
                        )
                    }
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: 2)
                        .position(x: viewModel.playheadPercentage * proxy.size.width, y: proxy.size.height / 2)
                }
            .clipped()

            HStack {
                HStack(spacing: 0) {
                    MidiLooperLabel(backgroundColor: .clear, systemImageName: .dancer)
                        .frame(width: 50)
                    IndexedSlider(index: $viewModel.quantizationOptionIndex, labels: ["-", "1", "1/2", "1/4", "1/8", "1/16", "1/32"])
                        .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                        .foregroundColor(GrayScaleColor.foregroundActive.color)
                        .cornerRadius(20)
                        .frame(width: 400)
                }
                ForEach(MidiLooperNoteAction.allCases.filter { $0 != .unmute }, id: \.self) { action in
                    MidiLooperButton(
                        state: viewModel.enabledNoteActions.contains(action) ? .enabled : .disabled,
                        title: action.buttonTitle,
                        systemImageName: action.buttonImageName,
                        onTap: { viewModel.onNoteAction(action) },
                        onLongTap: { viewModel.onNoteActionLongPress(action) }
                    )
                }
                MidiLooperButton(state: viewModel.undoActionsAvailable ? .enabled : .disabled, systemImageName: .undo, onTap: {
                    viewModel.onUndoButtonTap()
                })
                MidiLooperButton(state: viewModel.redoActionsAvailable ? .enabled : .disabled, systemImageName: .redo, onTap: {
                    viewModel.onRedoButtonTap()
                })
                MidiLooperButton(state: viewModel.isArmed ? .enabled : .disabled, systemImageName: .record, onTap: {

                })
            }
            .frame(height: 60)
            HStack(spacing: 0) {
                MidiLooperLabel(backgroundColor: .clear, systemImageName: .grid)
                    .frame(width: 50)
                IndexedSlider(index: $viewModel.gridDensityIndex, labels: ["1", "2", "4", "8", "16", "32"])
                    .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                    .foregroundColor(GrayScaleColor.foregroundActive.color)
                    .cornerRadius(20)
                    .frame(width: 400)
                Spacer()

                MidiLooperButton(state: .enabled, title: "/2", onTap: {
                    viewModel.onDivideLoopButtonTap()
                })
                Text("\(viewModel.bars)")
                    .padding(.horizontal)
                MidiLooperButton(state: .enabled, title: "x2", onTap: {
                    viewModel.onMultiplyLoopButtonTap()
                })
            }
            .frame(height: 60)
        }
    }
}
