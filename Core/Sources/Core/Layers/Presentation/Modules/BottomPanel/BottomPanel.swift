//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Midi
import SwiftUI

struct BottomPanel: View {
    var onAction: ((BottomPanelAction) -> Void)?
    @EnvironmentObject var midiLooperActionInteractor: MidiLooperActionInteractor
    @State private var lfoSynced: Bool = false

    var body: some View {
        HStack {
            HStack {
                InstrumentSelector(onAction: onAction)
                VStack {
                    PrimaryButton(title: "KICK & SUB", isOn: false, interactionStyle: .momentary, midiMessageStyle: .onOffSame(MidiMessage(channel: Constants.MidiChannels.songStructure, controller: Constants.MidiMessages.SongStructure.kickAndSub)))
                    .frame(width: 50)
                    PrimaryButton(title: "ALL", isOn: false, interactionStyle: .momentary, midiMessageStyle: .onOffSame(MidiMessage(channel: Constants.MidiChannels.songStructure, controller: Constants.MidiMessages.SongStructure.all)))
                    .frame(width: 50)
                }
                VStack {
                    HStack {
                        LfoControl(title: "BASS", baseNote: 30, synced: lfoSynced)
                        PrimaryButton(config: .addOctaveUp)
                    }
                    HStack {
                        LfoControl(title: "HARMONY", baseNote: 50, synced: lfoSynced)
                        PrimaryButton(title: "SYNC LFO", isOn: lfoSynced, interactionStyle: .toggle, midiMessageStyle: .specialAction({
                            lfoSynced.toggle()
                        }))
                    }
                    HStack {
                        LfoControl(title: "MELODY", baseNote: 70, synced: lfoSynced)
                        PrimaryButton(config: .addOctaveDown)
                    }
                }
            }
        }
        .frame(height: 120)
    }
}

struct LoopersView_BottomPanel_Previews: PreviewProvider {
    static var previews: some View {
        BottomPanel()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

// TODO: MOVE
struct LfoControl: View {
    @EnvironmentObject var midiBus: MIDIBus
    let title: String
    let baseNote: Int
    let synced: Bool

    var body: some View {
        PrimaryButton(config: .init(
            title: title,
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: baseNote
                )
            )
        ))
        ForEach(LfoConfig.allCases, id: \.title) { config in
            let channel = Constants.MidiChannels.automation
            PrimaryButton(title: "\(config.title.uppercased())", interactionStyle: .toggle, midiMessageStyle: .specialAction({
                midiBus.sendEvent(message: MidiMessage(channel: channel, controller: baseNote + 1, velocity: config.shapeNumber.inMidiRange(originalRange: 1...12)))
                midiBus.sendEvent(message: MidiMessage(channel: channel, controller: baseNote + 2, velocity: config.rate.rawValue))
                midiBus.sendEvent(message: MidiMessage(channel: channel, controller: baseNote + 3, velocity: config.phase.inMidiRange(originalRange: 1...360)))
                midiBus.sendEvent(message: MidiMessage(channel: channel, controller: baseNote + 4, velocity: config.swing.inMidiRange(originalRange: -100...100)))

            }))
        }
    }
}

struct LfoConfig {
    let title: String
    let shapeNumber: Int // range 1 - 12
    let rate: LfoRate
    let phase: Int // range 0 - 360
    let swing: Int // range -100 - 100

    static var offbeat: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 1, rate: .quarter, phase: 266, swing: 0)
    }

    static var offbeat2: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 1, rate: .sixteenth, phase: 200, swing: 40)
    }

    static var eight: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 1, rate: .eight, phase: 136, swing: 40)
    }

    static var sigteen: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 1, rate: .sixteenth, phase: 136, swing: 40)
    }

    static var swingSaw: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 4, rate: .sixteenth, phase: 0, swing: 28)
    }

    static var allCases: [LfoConfig] {
        [
            offbeat,
//            offbeat2,
//            eight,
//            sigteen,
            swingSaw
        ]
    }
}

enum LfoRate: Int {
    case quarter = 0
    case eight = 63
    case sixteenth = 127
}

extension Int {
    func inMidiRange(originalRange: ClosedRange<Int>) -> Int {
        let midiRange = 0...127
        let midiRangeLength = midiRange.upperBound - midiRange.lowerBound
        let originalRangeLength = originalRange.upperBound - originalRange.lowerBound
        let originalRangeValue = self - originalRange.lowerBound
        let midiRangeValue = (originalRangeValue * midiRangeLength) / originalRangeLength
        return midiRangeValue + midiRange.lowerBound
    }
}
