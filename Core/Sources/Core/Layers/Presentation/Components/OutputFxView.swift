//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct OutputFxView: View {
    enum Layout {
        case v1
        case v2
    }

    let layout: Layout
    var onAction: (Action) -> Void

    var body: some View {
        switch layout {
        case .v1:
            VStack {
                PrimaryButton(title: "RESET", interactionStyle: .doubleTap, midiMessageStyle: .specialAction({
                    onAction(.resetOutputFx)
                }))

                ForEach(0 ..< Constants.FxGroups.output.count, id: \.self) { index in
                    Knob(title: Constants.FxGroups.output[index], midiController: index, midiChannel: Constants.MidiChannels.outputFx)
                }
//                Knob(title: "DRY/WET", midiController: 12, midiChannel: Constants.MidiChannels.outputFx, value: 1)
                XYPad(
                    title: "OUTPUT",
                    midiChannelX: Constants.MidiChannels.outputFx,
                    midiControllerX: 8,
                    midiChannelY: Constants.MidiChannels.outputFx,
                    midiControllerY: 9
                )
                .frame(width: 90, height: 90)
            }
            .frame(width: 90)
        case .v2:
            VStack {
                MidiLooperButton(state: .enabled, title: "RESET", onLongTap: { onAction(.resetOutputFx) })
                HStack {
                    VStack {
                        Knob(title: Constants.FxGroups.output[0], midiController: 0, midiChannel: Constants.MidiChannels.outputFx)
                        Knob(title: Constants.FxGroups.output[1], midiController: 1, midiChannel: Constants.MidiChannels.outputFx)
                        Knob(title: Constants.FxGroups.output[2], midiController: 2, midiChannel: Constants.MidiChannels.outputFx)
                        Knob(title: Constants.FxGroups.output[3], midiController: 3, midiChannel: Constants.MidiChannels.outputFx)
                        Knob(title: Constants.FxGroups.output[4], midiController: 4, midiChannel: Constants.MidiChannels.outputFx)
                    }
                    VStack {
                        Knob(title: Constants.FxGroups.output[5], midiController: 5, midiChannel: Constants.MidiChannels.outputFx)
//                        Knob(title: Constants.FxGroups.output[6], midiController: 6, midiChannel: Constants.MidiChannels.outputFx)
//                        Knob(title: Constants.FxGroups.output[7], midiController: 7, midiChannel: Constants.MidiChannels.outputFx)
                        Knob(title: "DRY/WET", midiController: 12, midiChannel: Constants.MidiChannels.outputFx, value: 1)
                    }
                }
                XYPad(
                    title: "OUTPUT",
                    midiChannelX: Constants.MidiChannels.outputFx,
                    midiControllerX: 8,
                    midiChannelY: Constants.MidiChannels.outputFx,
                    midiControllerY: 9
                )
                .frame(height: 200)
            }
            .frame(width: 200)
        }
    }
}
