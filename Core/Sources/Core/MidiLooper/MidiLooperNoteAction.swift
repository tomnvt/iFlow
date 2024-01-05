//
//  File.swift
//  
//
//  Created by Tom Novotny on 16.07.2023.
//

import PianoRoll

enum MidiLooperNoteAction: CaseIterable {
    case add
    case delete
    case muteAll
    case mute
    case unmute
    case unmuteAll

    var buttonTitle: String? {
        switch self {
        case .add:
            return nil
        case .delete:
            return nil
        case .muteAll:
            return "all"
        case .mute, .unmute:
            return nil
        case .unmuteAll:
            return "all"
        }
    }

    var buttonImageName: SystemImageName {
        switch self {
        case .add:
            return .add
        case .delete:
            return .delete
        case .muteAll:
            return .emptySpeaker
        case .mute, .unmute:
            return .emptySpeaker
        case .unmuteAll:
            return .speakerFilled
        }
    }
}

struct MidiLooperNoteActionModel {
    let action: MidiLooperNoteAction
    var notes: [PianoRollNote] = []
}
