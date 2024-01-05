//
//  File.swift
//  
//
//  Created by Tom Novotny on 16.07.2023.
//

enum MidiLooperSpecialAction {
    case play
    case stop
    case clickOn
    case clickOff
    case arm(on: Bool, channel: Int)
    case quantize(isOn: Bool)
}
