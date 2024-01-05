//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct InputFxView: View {
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
                onAction(.resetInputFx)
            }))
            ForEach(0 ..< Constants.FxGroups.input.count, id: \.self) { index in
                Knob(title: Constants.FxGroups.input[index], midiController: index, midiChannel: Constants.MidiChannels.inputFx)
            }
//            Knob(title: "DRY/WET", midiController: 12, midiChannel: Constants.MidiChannels.inputFx, value: 1)
            XYPad(
                title: "INPUT",
                midiChannelX: Constants.MidiChannels.inputFx,
                midiControllerX: 8,
                midiChannelY: Constants.MidiChannels.inputFx,
                midiControllerY: 9
            )
            .frame(width: 90, height: 90)
        }
        .frame(width: 90)
        case .v2:
            VStack {
                MidiLooperButton(state: .enabled, title: "RESET", onLongTap: { onAction(.resetInputFx) })
                    .frame(width: 300, height: 40)
                HStack {
                    Knob(title: Constants.FxGroups.input[0], midiController: 0, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: Constants.FxGroups.input[1], midiController: 1, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: Constants.FxGroups.input[2], midiController: 2, midiChannel: Constants.MidiChannels.inputFx)
                }
                HStack {
                    Knob(title: Constants.FxGroups.input[3], midiController: 3, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: Constants.FxGroups.input[4], midiController: 4, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: Constants.FxGroups.input[5], midiController: 5, midiChannel: Constants.MidiChannels.inputFx)
                }
                HStack {
                    Knob(title: Constants.FxGroups.input[6], midiController: 6, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: Constants.FxGroups.input[7], midiController: 7, midiChannel: Constants.MidiChannels.inputFx)
                    Knob(title: "DRY/WET", midiController: 12, midiChannel: Constants.MidiChannels.inputFx, value: 1)
                }
                XYPad(
                    title: "INPUT",
                    midiChannelX: Constants.MidiChannels.inputFx,
                    midiControllerX: 8,
                    midiChannelY: Constants.MidiChannels.inputFx,
                    midiControllerY: 9
                )
                .frame(width: 300, height: 300)
            }
        }
    }
}
