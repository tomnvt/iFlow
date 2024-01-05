//
//  MIDIBusProtocol.swift
//  LinkHut
//
//  Created by Tom Novotny on 04.03.2023.
//

import Foundation

protocol MIDIBusProtocol {
    func sendEvent(
        midiAction: MIDIAction,
        channel: Int,
        controller: Int,
        velocity: Int
    )

    var onSystemMessageReceive: ((SystemMidiMessage) -> Void)? { get set }
}
