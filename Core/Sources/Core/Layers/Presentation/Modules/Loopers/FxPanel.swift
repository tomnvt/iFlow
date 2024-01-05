//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct FxPanel: View {
    enum Layout {
        case v1
        case v2

        var fxPanelSize: CGFloat {
            switch self {
            case .v1:
                return 100
            case .v2:
                return 140
            }
        }

        var knobsWidth: CGFloat {
            switch self {
            case .v1:
                return 170
            case .v2:
                return 250
            }
        }
    }

    var layout: Layout
    let fxBaseNote: Int
    let index: Int
    let title: String
    var showFxKnobs = true

    var body: some View {
        Group {
            let knobTitles = Constants.FxGroups.looperFx[index]
            switch layout {
            case .v1:
                VStack {
                    makeFilterPad(index: index)
                    if showFxKnobs {
                        HStack {
                            Knob(title: String(knobTitles[0].prefix(4)), midiController: fxBaseNote, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[1].prefix(4)), midiController: fxBaseNote + 1, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[2].prefix(4)), midiController: fxBaseNote + 2, midiChannel: Constants.MidiChannels.looperFx)
                        }
                        HStack {
                            Knob(title: String(knobTitles[3].prefix(4)), midiController: fxBaseNote + 3, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[4].prefix(4)), midiController: fxBaseNote + 4, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[5].prefix(4)), midiController: fxBaseNote + 5, midiChannel: Constants.MidiChannels.looperFx)
                        }
                        HStack {
                            Knob(title: String(knobTitles[6].prefix(4)), midiController: fxBaseNote + 6, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[7].prefix(4)), midiController: fxBaseNote + 7, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: "WET", midiController: fxBaseNote + 11, midiChannel: Constants.MidiChannels.looperFx, value: 1)
                        }
                    }
                }
            case .v2:
                VStack {
                    HStack(spacing: 12) {
                        makeFilterPad(index: index)
                    }
                    VStack {
                        HStack {
                            Knob(title: String(knobTitles[0].prefix(4)), midiController: fxBaseNote, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[1].prefix(4)), midiController: fxBaseNote + 1, midiChannel:
                                    Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[2].prefix(4)), midiController: fxBaseNote + 2, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[3].prefix(4)), midiController: fxBaseNote + 3, midiChannel: Constants.MidiChannels.looperFx)
                        }
                        HStack {
                            Knob(title: String(knobTitles[4].prefix(4)), midiController: fxBaseNote + 4, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[5].prefix(4)), midiController: fxBaseNote + 5, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[6].prefix(4)), midiController: fxBaseNote + 6, midiChannel: Constants.MidiChannels.looperFx)
                            Knob(title: String(knobTitles[7].prefix(4)), midiController: fxBaseNote + 7, midiChannel: Constants.MidiChannels.looperFx)
                        }
                        // TODO: Add dry wet as fader
                        //                HStack {
                        //
                        //                    Knob(title: "WET", midiController: fxBaseNote + 11, midiChannel: Constants.MidiChannels.looperFx, value: 1)
                        //                }
                    }
                    .frame(width: layout.knobsWidth)
                }
            }
        }
    }

    func makeFilterPad(index: Int) -> some View {
        let channel = Constants.MidiChannels.looperFx
        let midiControllerNumberAddition = index * 20
        return XYPad(
            title: title,
            midiChannelX: channel,
            midiControllerX: 8 + midiControllerNumberAddition,
            midiChannelY: channel,
            midiControllerY: 9 + midiControllerNumberAddition
//            mainToggleChannel: channel,
//            mainToggleController: midiControllerNumberAddition + 10
        )
        .frame(width: layout.fxPanelSize, height: layout.fxPanelSize)
        .border(.white)
    }
}
