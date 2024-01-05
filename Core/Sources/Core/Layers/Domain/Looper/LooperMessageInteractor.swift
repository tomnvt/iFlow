//
//  MidiInteractor.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

import Combine
import Foundation
import Midi

class LooperMessageInteractor {
    private var cancellables = Set<AnyCancellable>()

    private let midiBus: MIDIBus

    init(midiBus: MIDIBus) {
        self.midiBus = midiBus
        NotificationCenter.default.publisher(for: .resetInputFx)
            .sink(receiveValue: { [weak self] _ in
                self?.resetInputFx()
            })
            .store(in: &cancellables)
    }

    func handleMessage(_ message: LooperMessage) {
        switch message {
        case let .barAmountChanged(looperGroupIndex, looperIndex, _, _),
             let .clear(looperGroupIndex, looperIndex),
             let .loopOn(looperGroupIndex, looperIndex, _),
             let .inputOn(looperGroupIndex, looperIndex, _),
             let .soloOn(looperGroupIndex, looperIndex, _),
             let .looperOn(looperGroupIndex, looperIndex, _):
            let (channel, looperBaseNote) = LooperIndexHelper.getBaseNoteAndChannel(
                looperGroupIndex: looperGroupIndex,
                looperIndex: looperIndex
            )
            handleLooperAction(message, channel, looperBaseNote)
        case let .resetFx(fxBaseNote):
            let messages = getResetFxMidiMessages(fxBaseNote: fxBaseNote, channel: Constants.MidiChannels.looperFx)
            dispatchMessages(messages: messages)
        case .resetAllFx:
            var messages = [0, 20, 40, 60, 80, 100]
                .flatMap { getResetFxMidiMessages(fxBaseNote: $0, channel: Constants.MidiChannels.looperFx) }
            messages += getResetFxMidiMessages(fxBaseNote: 0, channel: Constants.MidiChannels.inputFx)
            messages += getResetFxMidiMessages(fxBaseNote: 0, channel: Constants.MidiChannels.outputFx)
            dispatchMessages(messages: messages)
        }
    }


    func resetInputFx() {
        let messages = getResetFxMidiMessages(fxBaseNote: 0, channel: Constants.MidiChannels.inputFx)
        dispatchMessages(messages: messages)
    }

    func resetOutpuFx() {
        let messages = getResetFxMidiMessages(fxBaseNote: 0, channel: Constants.MidiChannels.outputFx)
        dispatchMessages(messages: messages)
    }

    private func getResetFxMidiMessages(fxBaseNote: Int, channel: Int) -> [MidiMessage] {
        [
            MidiMessage(channel: channel, controller: fxBaseNote + 0, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 1, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 2, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 3, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 4, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 5, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 6, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 7, velocity: 0),
            MidiMessage(channel: channel, controller: fxBaseNote + 8, velocity: 127),
            MidiMessage(channel: channel, controller: fxBaseNote + 9, velocity: 127),
            MidiMessage(channel: channel, controller: fxBaseNote + 12, velocity: 127),
        ]
    }

    private func dispatchMessages(messages: [MidiMessage]) {
        DispatchQueue.main.async { [weak self] in
            self?.midiBus.midiInput = messages
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.midiBus.midiInput = []
        }
        messages
            .forEach {
                midiBus
                    .sendEvent(midiAction: .controllerChange, channel: $0.channel, controller: $0.controller,
                               velocity: $0.velocity)
            }
    }

    private func handleLooperAction(_ message: LooperMessage, _ channel: Int, _ looperBaseNote: Int) {
        switch message {
        case let .barAmountChanged(_, _, index, _):
            let velocity = index * 24
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 1,
                velocity: velocity
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 2,
                velocity: 127
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 3,
                velocity: 0
            )
        case .clear:
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote,
                velocity: 127
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 1,
                velocity: 0
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 2,
                velocity: 0
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 3,
                velocity: 127
            )
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 6,
                velocity: 127
            )
        case let .loopOn(_, _, value):
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 2,
                velocity: value.asVelocity
            )
        case let .inputOn(_, _, value):
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 3,
                velocity: value.asVelocity
            )
        case let .soloOn(_, _, value):
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 5,
                velocity: value.asVelocity
            )
        case let .looperOn(_, _, value):
            midiBus.sendEvent(
                midiAction: .controllerChange,
                channel: channel,
                controller: looperBaseNote + 6,
                velocity: value.asVelocity
            )
        case .resetFx, .resetAllFx:
            ()
        }
    }
}
