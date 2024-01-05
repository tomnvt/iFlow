//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation

public enum MIDIAction {
    case noteOn
    case noteOff
    case controllerChange
}

extension MIDIAction {
    var asMidiStatusType: MIDIStatusType {
        switch self {
        case .noteOn:
            return .noteOn
        case .noteOff:
            return .noteOff
        case .controllerChange:
            return .controllerChange
        }
    }
}
