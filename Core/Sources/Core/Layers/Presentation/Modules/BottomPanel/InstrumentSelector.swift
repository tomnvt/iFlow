//
//  File.swift
//  
//
//  Created by Tom Novotny on 09.10.2023.
//

import SwiftUI
import Midi

private let groups = [
    "ESSENCE",
    "DEEP",
    "BASS",
    "KEYS",
    "WORLD",
]

private let groupsLists = [
    [
        "DRUMS",
        "BASS",
        "KEYS",
        "PIANO",
        "CLAV",
        "MUTED G",
        "PLUCK",
        "HORNS",
        "BELLS",
    ],
    [
        "DRUMS",
        "SUB",
        "E-PIANO",
        "SAMPLE",
        "STRINGS",
        "BRASS",
        "PAD",
        "GUITAR",
        "PLUCK",
    ],
    [
        "DRUMS",
        "PLUCK",
        "303",
        "SPACE",
        "DARK",
        "ORGAN",
        "WOB",
        "808",
        "HARD",
    ],
    [
        "HOUSE ORGAN",
        "RETRO ORGAN",
        "CORRAL",
        "SUBTERRANEA",
        "FUNKY ORGAN",
        "PIANOSITAR",
        "ROUGH ORGAN",
        "JUNO ORGAN",
        "???",
    ],
    [
        "SITAR",
        "KOTO",
        "HARP",
        "BASIC BELLS",
        "ISLAND BELLS",
        "OCEAN",
        "???",
        "???",
        "???",
    ],
]

struct InstrumentSelector: View {
    @State var currentlySelectedInstrumentGroupIndex: Int = 0
    @State var currentlySelectedGenreInstrumentIndex: Int = 0
    var onAction: ((BottomPanelAction) -> Void)?

    var body: some View {
        VStack {
            instrumentGroupSelector
            HStack {
                ForEach(0..<9, id: \.self) { index in
                    PrimaryButton(
                        title: groupsLists[currentlySelectedInstrumentGroupIndex][index],
                        isOn: currentlySelectedGenreInstrumentIndex == index,
                        interactionStyle: .listToggle,
                        midiMessageStyle: .specialAction {
                            NotificationCenter.default.post(name: .resetInputFx, object: nil)
                            currentlySelectedGenreInstrumentIndex = index
                            onAction?(
                                .midiMessages(Constants.MidiMessages.onInstrumentChange + [
                                    MidiMessage(
                                        channel: Constants.MidiChannels.genreInstrumentSelection,
                                        controller: currentlySelectedInstrumentGroupIndex * 16 + index,
                                        velocity: 127
                                    )
                                ])
                            )
                        }
                    )
                }
            }
        }
        .frame(width: 500)
    }

    var instrumentGroupSelector: some View {
        HStack {
            ForEach(0..<groups.count, id: \.self) { index in
                makeInstrumentGroupSelector(title: groups[index], index: index)
            }
        }
        .frame(height: 40)
    }

    func makeInstrumentGroupSelector(title: String, index: Int) -> some View {
        PrimaryButton(
            title: title,
            isOn: currentlySelectedInstrumentGroupIndex == index,
            interactionStyle: .listToggle,
            midiMessageStyle: .specialAction {
                NotificationCenter.default.post(name: .resetInputFx, object: nil)
                currentlySelectedInstrumentGroupIndex = index
                onAction?(
                    .midiMessages(Constants.MidiMessages.onInstrumentChange + [
                        MidiMessage(
                            channel: Constants.MidiChannels.genreInstrumentSelection,
                            controller: currentlySelectedInstrumentGroupIndex * 16 + currentlySelectedGenreInstrumentIndex,
                            velocity: 127
                        )
                    ])
                )
            }
        )
    }
}
