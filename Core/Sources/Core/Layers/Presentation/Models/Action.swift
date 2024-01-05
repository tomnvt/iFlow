//
//  Action.swift
//  iFlow
//
//  Created by Tom Novotny on 05.03.2023.
//

import Midi

enum Action {
    case midiMessage(MidiMessage)
    case resetInputFx
    case resetOutputFx
}
