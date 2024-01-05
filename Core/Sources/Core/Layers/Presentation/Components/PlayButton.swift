//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct PlayButton: View {
    @State private var isPlaying: Bool = false
    let interactor: MidiLooperActionInteractor

    var body: some View {
        MidiLooperLabel(
            backgroundColor: GrayScaleColor.backgroundEnabled.color,
            systemImageName: isPlaying ? SystemImageName.stop : SystemImageName.play
        )
        .onTapGesture(count: 2) {
            togglePlayState()
        }
        .onTapGesture(count: 1) {
            if !isPlaying { togglePlayState() }
        }
    }

    func togglePlayState() {
        isPlaying.toggle()
        interactor.handleAction(isPlaying ? .play : .stop)
    }
}
