//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Midi
import SwiftUI

struct BottomPanel: View {
    var onAction: ((BottomPanelAction) -> Void)?
    @EnvironmentObject var midiLooperActionInteractor: MidiLooperActionInteractor
    @State private var lfoSynced: Bool = false

    var body: some View {
        HStack {
            HStack {
                InstrumentSelector(onAction: onAction)
                VStack {
                    PrimaryButton(title: "KICK & SUB", isOn: false, interactionStyle: .momentary, midiMessageStyle: .onOffSame(MidiMessage(channel: Constants.MidiChannels.songStructure, controller: Constants.MidiMessages.SongStructure.kickAndSub)))
                    .frame(width: 50)
                    PrimaryButton(title: "ALL", isOn: false, interactionStyle: .momentary, midiMessageStyle: .onOffSame(MidiMessage(channel: Constants.MidiChannels.songStructure, controller: Constants.MidiMessages.SongStructure.all)))
                    .frame(width: 50)
                }
                VStack {
                    HStack {
                        LfoControl(title: "BASS", baseNote: 30, synced: lfoSynced)
                        PrimaryButton(config: .addOctaveUp)
                    }
                    HStack {
                        LfoControl(title: "HARMONY", baseNote: 50, synced: lfoSynced)
                        PrimaryButton(title: "SYNC LFO", isOn: lfoSynced, interactionStyle: .toggle, midiMessageStyle: .specialAction({
                            lfoSynced.toggle()
                        }))
                    }
                    HStack {
                        LfoControl(title: "MELODY", baseNote: 70, synced: lfoSynced)
                        PrimaryButton(config: .addOctaveDown)
                    }
                }
            }
        }
        .frame(height: 120)
    }
}

struct LoopersView_BottomPanel_Previews: PreviewProvider {
    static var previews: some View {
        BottomPanel()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
