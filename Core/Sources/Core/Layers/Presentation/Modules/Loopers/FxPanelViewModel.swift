//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation
import Midi

class FxPanelViewModel: ObservableObject {
    @Published var activeActions: [(channel: Int, controller: Int)] = []

    let generalMessageInteractor: GeneralMessageInteractor
    let looperMessageInteractor: LooperMessageInteractor

    init(
        generalMessageInteractor: GeneralMessageInteractor,
        looperMessageInteractor: LooperMessageInteractor
    ) {
        self.generalMessageInteractor = generalMessageInteractor
        self.looperMessageInteractor = looperMessageInteractor
    }

    func onAction(_ action: Action) {
        switch action {
        case let .midiMessage(midiMessage):
            onMidiMessage(midiMessage)
        case .resetInputFx:
            looperMessageInteractor.resetInputFx()
        case .resetOutputFx:
            looperMessageInteractor.resetOutpuFx()
        }
    }

    private func onMidiMessage(_ message: MidiMessage) {
        generalMessageInteractor
            .handleMessage(
                .general(channel: message.channel, controller: message.controller, velocity: message.velocity)
            )
        if message.velocity == 127 {
            activeActions.append((channel: message.channel, controller: message.controller))
        } else {
            activeActions.removeAll(where: { $0.channel == message.channel && $0.controller == message.controller })
        }
    }
}
