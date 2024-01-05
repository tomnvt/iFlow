//
//  Main.swift
//  MidiMap
//
//  Created by Tom Novotny on 11.02.2023.
//

import Combine
import Core
import SwiftUI
import ReplayKit

@main
struct Main: App {
    init() {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = true
        #endif
    }

    var body: some Scene {
        MainScene()
    }
}
