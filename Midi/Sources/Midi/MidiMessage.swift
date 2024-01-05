//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation

public struct MidiMessage: Equatable {
    public let channel: Int
    public let controller: Int
    public let velocity: Int

    public init(channel: Int, controller: Int, velocity: Int = 127) {
        self.channel = channel
        self.controller = controller
        self.velocity = velocity
    }
}
