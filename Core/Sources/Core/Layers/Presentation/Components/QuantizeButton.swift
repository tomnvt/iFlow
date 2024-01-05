//
//  File.swift
//  
//
//  Created by Tom Novotny on 01.10.2023.
//

import SwiftUI
import Midi

struct QuantizeButton: View {
    @State private var isOn: Bool = false
    let interactor: MidiLooperActionInteractor
    @EnvironmentObject var midiBus: MIDIBus

    var body: some View {
        MidiLooperButton(state: isOn ? .active : .enabled, title: "QUAN", onTap: {
            isOn.toggle()
            interactor.handleAction(.quantize(isOn: isOn))
        })
        .onAppear(perform: {
            midiBus.listeners.append(MidiMessageListener(channel: 7, controller: 9, onMessageReceived: {
                isOn = $0 == 127
            }))
        })
    }
}
