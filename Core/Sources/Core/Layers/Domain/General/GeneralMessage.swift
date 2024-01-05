//
//  GeneralMessage.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

enum GeneralMessage {
    case instrumentChange(index: Int)
    case looperOutputToggle(index: Int, isOn: Bool)
    case general(channel: Int, controller: Int, velocity: Int)
}

extension GeneralMessage {
    var midiValues: (channel: Int, controller: Int, velocity: Int) {
        switch self {
        case let .instrumentChange(index):
            return (channel: 6, controller: index, velocity: 127)
        case let .looperOutputToggle(index, isOn):
            return (channel: 7, controller: index, velocity: isOn.asVelocity)
        case let .general(channel, controller, velocity):
            return (channel, controller, velocity)
        }
    }
}
