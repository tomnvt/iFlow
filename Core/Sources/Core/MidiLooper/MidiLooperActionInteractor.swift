//
//  File.swift
//  
//
//  Created by Tom Novotny on 16.07.2023.
//

import Combine
import Midi

class MidiLooperActionInteractor: ObservableObject {
    private let midiBus: MIDIBus
    var onStarted: (() -> Void)?
    var onStopped:  (() -> Void)?

    init(midiBus: MIDIBus) {
        self.midiBus = midiBus
    }

    func handleAction(_ action: MidiLooperSpecialAction) {
        switch action {
        case .play:
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 7, velocity: 127))
            onStarted?()
        case .stop:
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 8, velocity: 127))
            onStopped?()
        case .clickOn:
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 6, velocity: 127))
        case .clickOff:
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 6, velocity: 0))
        case .arm(let armIsOn, let channel):
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 60 + channel, velocity: armIsOn ? 127 : 0))
        case .quantize(let isOn):
            midiBus.sendEvent(message: MidiMessage(channel: 7, controller: 9, velocity: isOn ? 127 : 0))
        }
    }
}
