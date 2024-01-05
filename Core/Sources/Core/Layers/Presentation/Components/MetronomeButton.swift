//
//  MainView+BottomPanel.swift
//  LinkHut
//
//  Created by Tom Novotny on 20.02.2023.
//

import SwiftUI

struct MetronomeButton: View {
    @State private var isPlaying: Bool = false
    let interactor: MidiLooperActionInteractor

    var body: some View {
        MidiLooperButton(state: isPlaying ? .active : .enabled, systemImageName: isPlaying ? .metronomeFilled : .metronomeFilled, onTap: {
            isPlaying.toggle()
            interactor.handleAction(isPlaying ? .clickOn : .clickOff)
        })
    }
}
