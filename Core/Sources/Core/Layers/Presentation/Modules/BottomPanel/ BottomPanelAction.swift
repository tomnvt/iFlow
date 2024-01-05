//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation
import Midi

enum BottomPanelAction {
    case resetAll
    case midiMessage(MidiMessage)
    case midiMessages([MidiMessage])
}
