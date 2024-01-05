//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 28.10.2023.
//

import Controls
import Midi
import SwiftUI

struct ArpQuantControl: View {
    @EnvironmentObject var midiBus: MIDIBus
    
    @State var rateIndex = 0
    let rateLabels = ["4", "6", "8", "12", "16", "24", "32", "48", "64"]
    
    @State var quantizationIndex = 0
    let quantizationLabels = ["4", "8", "16"]
    @State var quantizedSwingPosition: Float = 0

    let foregroundColor = Color.white.opacity(0.25)

    var body: some View {
        VStack {
            HStack {
                PrimaryButton(config: .init(
                    title: "ARP",
                    interactionStyle: .toggle,
                    midiMessageStyle: .onOffSame(
                        MidiMessage(
                            channel: Constants.MidiChannels.automation,
                            controller: Constants.MidiMessages.Automation.arpeggiatorSwitch
                        )
                    )
                ))
                .frame(width: 60)
                // TODO: - Deduplicate
                IndexedSlider(index: $rateIndex, labels: rateLabels)
                    .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                    .foregroundColor(foregroundColor)
                    .cornerRadius(20)
                    .onChange(of: rateIndex) { value in
                        midiBus.sendEvent(message: MidiMessage(
                            channel: Constants.MidiChannels.automation,
                            controller: Constants.MidiMessages.Automation.arpeggiatorSwitch,
                            velocity: 127
                        ))
                        let velocity = value * 127 / (rateLabels.count - 1)
                        midiBus.sendEvent(message: MidiMessage(
                            channel: Constants.MidiChannels.automation,
                            controller: Constants.MidiMessages.Automation.arpeggiatorRate,
                            velocity: velocity
                        ))
                    }
            }
        }
    }
}

#Preview {
    ArpQuantControl()
        .previewLayout(.sizeThatFits)
}

struct ArpQuantControl2: View {
    @EnvironmentObject var midiBus: MIDIBus

    @State var rateIndex = 0
    let rateLabels = ["4", "6", "8", "12", "16", "24", "32", "48", "64"]

    @State var quantizationIndex = 0
    let quantizationLabels = ["4", "8", "16"]
    @State var quantizedSwingPosition: Float = 0

    let foregroundColor = Color.white.opacity(0.25)

    var body: some View {
        VStack {
            HStack {
                PrimaryButton(config: PrimaryButtonConfig(
                    title: "QUAN",
                    interactionStyle: .toggle,
                    midiMessageStyle: .onOffDifferent(onMessage: MidiMessage(
                        channel: Constants.MidiChannels.automation,
                        controller: Constants.MidiMessages.Automation.quantizationSwitchOn,
                        velocity: 100
                    ), offMessage: MidiMessage(
                        channel: Constants.MidiChannels.automation,
                        controller: Constants.MidiMessages.Automation.quantizationSwitchOff,
                        velocity: 100
                    ))
                ))
                .frame(width: 60)
                VStack {
                    Ribbon(position: $quantizedSwingPosition)
                        .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                        .foregroundColor(foregroundColor)
                        .cornerRadius(20)
                        .indicatorWidth(60)
                        .onChange(of: quantizedSwingPosition) { value in
                            midiBus.sendEvent(message: MidiMessage(
                                channel: Constants.MidiChannels.automation,
                                controller: Constants.MidiMessages.Automation.quantizationSwitchOn,
                                velocity: 127
                            ))
                            let velocity = value * 127
                            midiBus.sendEvent(message: MidiMessage(
                                channel: Constants.MidiChannels.automation,
                                controller: Constants.MidiMessages.Automation.quantizedSwing,
                                velocity: Int(velocity)
                            ))
                        }
                    //                    IndexedSlider(index: $quantizationIndex, labels: quantizationLabels)
                    //                        .backgroundColor(GrayScaleColor.backgroundEnabled.color)
                    //                        .foregroundColor(foregroundColor)
                    //                        .cornerRadius(20)
                    //                        .onChange(of: quantizationIndex) { value in
                    //                            midiBus.sendEvent(message: MidiMessage(
                    //                                channel: Constants.MidiChannels.automation,
                    //                                controller: Constants.MidiMessages.Automation.quantizationSwitchOn,
                    //                                velocity: 127
                    //                            ))
                    //                            let velocity = [70, 82, 98][value]
                    //                            midiBus.sendEvent(message: MidiMessage(
                    //                                channel: Constants.MidiChannels.automation,
                    //                                controller: Constants.MidiMessages.Automation.quantitionRate,
                    //                                velocity: velocity
                    //                            ))
                    //                        }
                }
            }
        }
    }
}
