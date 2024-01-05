//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation

class BottomPanelViewModel: ObservableObject {
    @Published private(set) var selectedBpmIndex = 0

    private let looperMessageInteractor: LooperMessageInteractor
    private let generalMessageInteractor: GeneralMessageInteractor

    init(
        looperMessageInteractor: LooperMessageInteractor,
        generalMessageInteractor: GeneralMessageInteractor
    ) {
        self.looperMessageInteractor = looperMessageInteractor
        self.generalMessageInteractor = generalMessageInteractor
    }

    func onAction(_ action: BottomPanelAction) {
        switch action {
        case .resetAll:
            NotificationCenter.default.post(name: .resetAll, object: nil)
        case .midiMessage(let message):
            generalMessageInteractor.handleMessage(.general(channel: message.channel, controller: message.controller, velocity: message.velocity))
        case .midiMessages(let messages):
            messages.forEach { message in
                generalMessageInteractor.handleMessage(.general(channel: message.channel, controller: message.controller, velocity: message.velocity))
            }
        }
    }
}
