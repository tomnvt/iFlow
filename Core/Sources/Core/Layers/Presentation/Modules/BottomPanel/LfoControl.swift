//
//  File.swift
//  
//
//  Created by Tom Novotny on 07.01.2024.
//

import Midi
import SwiftUI

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
        return LfoConfig(title: #function, shapeNumber: 2, rate: .sixteenth, phase: 0, swing: 25)
    }

    static var eight: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 2, rate: .thirtyTwoTriplet, phase: 0, swing: 0)
    }

    static var sixteen: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 2, rate: .sixteenthDot, phase: 0, swing: 0)
    }

    static var swingSaw: LfoConfig {
        return LfoConfig(title: #function, shapeNumber: 4, rate: .sixteenth, phase: 0, swing: 28)
    }

    static var allCases: [LfoConfig] {
        [
            offbeat,
            offbeat2,
            eight,
            sixteen,
            swingSaw
        ]
    }
}

enum LfoRate: Int {
    case quarter = 0
    case eight = 42
    case sixteenthDot = 50
    case sixteenthTriplet = 60
    case sixteenth = 86
    case thirtyTwoDot = 100
    case thirtyTwoTriplet = 111
    case thirtyTwo = 127
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
