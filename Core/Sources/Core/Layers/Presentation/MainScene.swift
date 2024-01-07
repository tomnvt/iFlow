//
//  File.swift
//
//
//  Created by Tom Novotny on 17.06.2023.
//

import Combine
import Midi
import SwiftUI

import ReplayKit

public struct MainScene: Scene {
    @Environment(\.scenePhase) private var scenePhase

    var midiBus: MIDIBus
    var barCountInteractor: BarCountInteractor
    var midiLoopersViewModel: MidiLoopersViewModel
    var midiLooperActionInteractor: MidiLooperActionInteractor

    public init() {
        midiBus = MIDIBus()
        barCountInteractor = BarCountInteractor(midiBus: midiBus)
        midiLooperActionInteractor = MidiLooperActionInteractor(midiBus: midiBus)
        midiLoopersViewModel = MidiLoopersViewModel(
            barCountInteractor: barCountInteractor,
            midiLooperActionInteractor: midiLooperActionInteractor,
            midiBus: midiBus
        )
    }

    public var body: some Scene {
        WindowGroup {
            #if os(iOS)
            mainView
                .defersSystemGestures(on: .vertical)
                .statusBar(hidden: true)
                .ignoresSafeArea()
            #else
            ZStack {
                KeystrokeView(midiBus: midiBus)
                mainView
            }
            #endif
        }
    }

    @ViewBuilder
    var mainView: some View {
        let looperMessageInteractor = LooperMessageInteractor(midiBus: midiBus)
        let generalMessageInteractor = GeneralMessageInteractor(midiBus: midiBus)
        MainView(
            loopersViewModel: LoopersViewModel(
                looperMessageInteractor: looperMessageInteractor,
                generalMessageInteractor: generalMessageInteractor,
                midiBus: midiBus
            ),
            fxPanelViewModel: FxPanelViewModel(
                generalMessageInteractor: generalMessageInteractor,
                looperMessageInteractor: looperMessageInteractor
            ),
            bottomPanelViewModel: BottomPanelViewModel(
                looperMessageInteractor: looperMessageInteractor,
                generalMessageInteractor: generalMessageInteractor
            ), barCountInteractor: barCountInteractor,
            midiLoopersViewModel: midiLoopersViewModel,
            midiLooperActionInteractor: midiLooperActionInteractor
        )
        .environmentObject(midiBus)
    }
}
