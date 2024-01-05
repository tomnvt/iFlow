//
//  StMIDIEvent.swift
//  MidiMap
//
//  Created by Tom Novotny on 19.10.2022.
//

import CoreMIDI
import Foundation

struct StMIDIEvent: Decodable, Encodable, Equatable {
    var statusType: Int // AudioKit MIDIStatusType enum
    var channel: MIDIChannel
    var note: MIDIByte
    var velocity: MIDIByte?
    var portUniqueID: MIDIUniqueID?

    var statusDescription: String {
        if let stat = MIDIStatusType(rawValue: statusType) {
            return stat.description
        }
        return "-"
    }

    var channelDescription: String {
        return "\(channel + 1)"
    }

    var data1Description: String {
        switch statusType {
        case MIDIStatusType.noteOn.rawValue:
            return String(note)
        case MIDIStatusType.noteOff.rawValue:
            return String(note)
        case MIDIStatusType.controllerChange.rawValue:
            return note.description + ": " + MIDIControl(rawValue: note)!.description
        case MIDIStatusType.programChange.rawValue:
            return note.description
        default:
            return "-"
        }
    }

    var velocityDescription: String {
        if velocity != nil {
            switch statusType {
            case MIDIStatusType.noteOn.rawValue:
                return velocity!.description
            case MIDIStatusType.noteOff.rawValue:
                return velocity!.description
            case MIDIStatusType.controllerChange.rawValue:
                return velocity!.description
            default:
                return "-"
            }
        } else {
            return "-"
        }
    }
}
