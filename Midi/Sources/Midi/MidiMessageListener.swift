//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation

public class MidiMessageListener {
    let channel: Int
    let controller: Int
    let onMessageReceived: (Int) -> Void

    public init(channel: Int, controller: Int, onMessageReceived: @escaping (Int) -> Void) {
        self.channel = channel
        self.controller = controller
        self.onMessageReceived = onMessageReceived
    }
}
