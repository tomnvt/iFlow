//
//  File.swift
//  
//
//  Created by Tom Novotny on 22.11.2023.
//

import Controls
import Midi
import SwiftUI

struct RetroLooperControl: View {
    @EnvironmentObject var midiBus: MIDIBus

    @State var rateIndex = 0
    let rateLabels = ["16", "8", "4", "2", "1", "1/2", "1/4", "1/8", "1/16", "Off"]
    @State var rateIndex2 = 0
    let rateLabels2 = ["16", "8", "4", "2", "1", "1/2", "1/4", "1/8", "1/16", "Off"]
    let foregroundColor = Color.white.opacity(0.25)

    var body: some View {
        HStack {
            PrimaryButton(title: "CLEAR", interactionStyle: .momentary, midiMessageStyle: .onOffSame(MidiMessage(channel: Constants.MidiChannels.newLoopers, controller: 1)))
                .frame(width: 100)
            VStack {
                IndexedSlider(index: $rateIndex, labels: rateLabels)
                    .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                    .foregroundColor(foregroundColor)
                    .cornerRadius(20)
                    .onChange(of: rateIndex) { value in
                        let velocity = value * 127 / (rateLabels.count - 1)
                        midiBus.sendEvent(message: MidiMessage(
                            channel: Constants.MidiChannels.newLoopers,
                            controller: 0,
                            velocity: velocity
                        ))
                    }
                IndexedSlider(index: $rateIndex2, labels: rateLabels2)
                    .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                    .foregroundColor(foregroundColor)
                    .cornerRadius(20)
                    .onChange(of: rateIndex2) { value in
                        let velocity = value * 127 / (rateLabels2.count - 1)
                        midiBus.sendEvent(message: MidiMessage(
                            channel: Constants.MidiChannels.newLoopers,
                            controller: 4,
                            velocity: velocity
                        ))
                    }
            }
        }
    }
}
