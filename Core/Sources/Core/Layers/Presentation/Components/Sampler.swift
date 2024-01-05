//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 03.09.2023.
//

import SwiftUI
import Midi

private struct ADSRPreset {
    let attack: Int
    let decay: Int
    let sustain: Int
    let release: Int

    static var pluck: ADSRPreset {
        ADSRPreset(
            attack: 1,
            decay: 6,
            sustain: 0,
            release: 0
        )
    }

    static var pad: ADSRPreset {
        ADSRPreset(
            attack: 1,
            decay: 127,
            sustain: 127,
            release: 1
        )
    }

    static var beep: ADSRPreset {
        ADSRPreset(
            attack: 0,
            decay: 2,
            sustain: 0,
            release: 0
        )
    }
}

struct Sampler: View {
    @EnvironmentObject var midiBus: MIDIBus
    let channel = Constants.MidiChannels.sampler
    let attackController = 4
    let decayController = 5
    let sustainController = 6
    let releaseController = 7
    let oneShotController = 9

    var body: some View {
        Grid {
            GridRow {
                MidiButton(
                    style: .momentary,
                    title: "REC",
                    channel: channel,
                    controller: 0,
                    onTouchUp: {
                        midiBus.sendEvent(message: MidiMessage(channel: channel, controller: 8, velocity: 127))
                    }
                )
                Knob(
                    title: "INPUT",
                    midiController: 1,
                    midiChannel: channel,
                    value: 0.5
                )
                MidiButton(style: .toggle, title: "MONO", channel: channel, controller: 2)
                Knob(
                    title: "PORTA",
                    midiController: 3,
                    midiChannel: channel
                )
                MidiButton(
                    style: .toggle,
                    title: "ARM",
                    channel: channel,
                    controller: 8
                )
                MidiButton(
                    style: .toggle,
                    title: "O/SHOT",
                    channel: channel,
                    controller: oneShotController
                )
                // TODO: - Turn this into three way toggle
                Knob(
                    title: "LOOP",
                    midiController: 10,
                    midiChannel: channel
                )
                Knob(
                    title: "OUTPUT",
                    midiController: 11,
                    midiChannel: channel,
                    value: 0.5
                )
            }
            GridRow {
                Knob(
                    title: "ATTACK",
                    midiController: attackController,
                    midiChannel: channel
                )
                Knob(
                    title: "DECAY",
                    midiController: decayController,
                    midiChannel: channel
                )
                Knob(
                    title: "SUST",
                    midiController: sustainController,
                    midiChannel: channel
                )
                Knob(
                    title: "RELEA",
                    midiController: releaseController,
                    midiChannel: channel
                )
                MidiButton(
                    style: .momentary,
                    title: "PLUCK",
                    onTouchDown: { sendAdsrChange(preset: .pluck) }
                )
                MidiButton(
                    style: .momentary,
                    title: "PAD",
                    onTouchDown: { sendAdsrChange(preset: .pad) }
                )
                MidiButton(
                    style: .momentary,
                    title: "BEEP",
                    onTouchDown: { sendAdsrChange(preset: .beep) }
                )
                MidiButton(
                    style: .momentary,
                    title: "RESET",
                    channel: channel,
                    controller: 8
                )
            }
        }
//        .frame(width: 300, height: 300)
    }

    private func sendAdsrChange(preset: ADSRPreset) {
        midiBus.sendEvent(
            message: MidiMessage(
                channel: channel,
                controller: attackController,
                velocity: preset.attack
            )
        )
        midiBus.sendEvent(
            message: MidiMessage(
                channel: channel,
                controller: decayController,
                velocity: preset.decay
            )
        )
        midiBus.sendEvent(
            message: MidiMessage(
                channel: channel,
                controller: sustainController,
                velocity: preset.sustain
            )
        )
        midiBus.sendEvent(
            message: MidiMessage(
                channel: channel,
                controller: releaseController,
                velocity: preset.release
            )
        )
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Sampler()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
