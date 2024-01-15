//
//  GeneralMessageInteractor.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

import Midi

class GeneralMessageInteractor {
    private var midiBus: MIDIBus

    init(midiBus: MIDIBus) {
        self.midiBus = midiBus
    }

    func handleMessage(_ message: GeneralMessage) {
        switch message {
        case let .instrumentChange(index):
            midiBus.sendEvent(midiAction: .controllerChange, channel: Constants.MidiChannels.instrumentSelection, controller: index, velocity: 127)
        case let .looperOutputToggle(index, isOn):
            midiBus.sendEvent(midiAction: .controllerChange, channel: Constants.MidiChannels.automation, controller: index, velocity: isOn.asVelocity)
        case let .general(channel, controller, velocity):
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: controller,
                velocity: velocity
            )
        }
    }
}
