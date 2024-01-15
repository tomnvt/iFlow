//
//  File.swift
//  
//
//  Created by Tom Novotny on 29.10.2023.
//

import Midi

extension Constants {
    enum MidiMessages {}
}

extension Constants.MidiMessages {
    enum Automation {
        static let clockClip = 6
        static let quantizationSwitchOn = 9
        static let quantizationSwitchOff = 10
        static let quantitionRate = 11
        static let arpeggiatorSwitch = 12
        static let arpeggiatorRate = 13
        static let arpeggiatorGroove = 14
        static let quantizedSwing = 15
        static let click = 16
        static let clickToggle = 17
        static let lfoControlsBaseNote = 30
        static let addOctaveUp = 100
        static let addOctaveDown = 101
        static let fourByFourOn = 90
        static let fourByFourOff = 91
    }

    static let onInstrumentChange: [MidiMessage] = resetArpAndQuan + resetMidiOctaver

    static let onResetAll: [MidiMessage] = onInstrumentChange + resetMidiOctaver + [
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.lfoControlsBaseNote,
            velocity: 0
        ),
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.lfoControlsBaseNote + 20,
            velocity: 0
        ),
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.lfoControlsBaseNote + 40,
            velocity: 0
        )
    ]

    private static let resetArpAndQuan = [
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.quantizationSwitchOff,
            velocity: 127
        ),
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.arpeggiatorSwitch,
            velocity: 0
        )
    ]

    private static let resetMidiOctaver = [
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.addOctaveUp,
            velocity: 0
        ),
        MidiMessage(
            channel: Constants.MidiChannels.automation,
            controller: Constants.MidiMessages.Automation.addOctaveDown,
            velocity: 0
        )
    ]
}

extension Constants.MidiMessages {
    enum SongStructure {
        static let all = 0
        static let kickAndSub = 1
    }
}
