//
//  File.swift
//  
//
//  Created by Tom Novotny on 08.10.2023.
//

import SwiftUI
import Midi

struct PrimaryButtonConfig {
    let title: String
    let interactionStyle: PrimaryButton.InteractionStyle
    let midiMessageStyle: PrimaryButton.MidiMessageStyle
}

extension PrimaryButtonConfig {
    static var quantizationSwitch: PrimaryButtonConfig {
        .init(
            title: "QUAN",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.quantizationSwitchOn
                )
            )
        )
    }

    static var bassLfoSwitch: PrimaryButtonConfig {
        .init(
            title: "BASS\nLFO",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.lfoControlsBaseNote
                )
            )
        )
    }

    static var harmonyLfoSwitch: PrimaryButtonConfig {
        .init(
            title: "HAR\nMONY\nLFO",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.lfoControlsBaseNote + 20
                )
            )
        )
    }

    static var melodyLfoSwitch: PrimaryButtonConfig {
        .init(
            title: "MELODY\nLFO",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.lfoControlsBaseNote + 40
                )
            )
        )
    }

    static var addOctaveUp: PrimaryButtonConfig {
        .init(
            title: "ADD +1 OCT",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.addOctaveUp
                )
            )
        )
    }

    static var addOctaveDown: PrimaryButtonConfig {
        .init(
            title: "ADD -1 OCT",
            interactionStyle: .toggle,
            midiMessageStyle: .onOffSame(
                MidiMessage(
                    channel: Constants.MidiChannels.automation,
                    controller: Constants.MidiMessages.Automation.addOctaveDown
                )
            )
        )
    }
}

struct PrimaryButton: View {
    enum InteractionStyle {
        case momentary
        case toggle
        case doubleTap
        case listToggle
    }

    enum MidiMessageStyle {
        case onOffSame(MidiMessage)
        case onOffDifferent(onMessage: MidiMessage, offMessage: MidiMessage)
        case specialAction(() -> Void)
    }

    let title: String
    let interactionStyle: InteractionStyle
    let midiMessageStyle: MidiMessageStyle

    init(title: String, isOn: Bool = false, interactionStyle: InteractionStyle, midiMessageStyle: MidiMessageStyle) {
        self.title = title
        self.isOn = isOn
        self.interactionStyle = interactionStyle
        self.midiMessageStyle = midiMessageStyle
        _isOnExternal = .constant(isOn)
    }

    init(config: PrimaryButtonConfig) {
        self.title = config.title
        self.interactionStyle = config.interactionStyle
        self.midiMessageStyle = config.midiMessageStyle
        _isOnExternal = .constant(nil)
    }

    @State private var isOn: Bool = false
    @Binding private var isOnExternal: Bool?
    @EnvironmentObject var interactor: MidiLooperActionInteractor
    @EnvironmentObject var midiBus: MIDIBus

    var body: some View {
        MidiLooperButton(
            state: (isOnExternal ?? isOn) ? .active : .enabled,
            title: title,
            onTap: {
                switch interactionStyle {
                case .momentary, .listToggle, .doubleTap:
                    ()
                case .toggle:
                    isOn.toggle()
                }

                if interactionStyle == .momentary {
                    return
                }

                switch midiMessageStyle {
                case .onOffSame(let message):
                    midiBus.sendEvent(
                        message: MidiMessage(
                            channel: message.channel,
                            controller: message.controller,
                            velocity: isOn ? 127 : 0
                        )
                    )
                case .onOffDifferent(let onMessage, let offMessage):
                    if isOn {
                        midiBus.sendEvent(
                            message: MidiMessage(
                                channel: onMessage.channel,
                                controller: onMessage.controller,
                                velocity: onMessage.velocity
                            )
                        )
                    } else {
                        midiBus.sendEvent(
                            message: MidiMessage(
                                channel: offMessage.channel,
                                controller: offMessage.controller,
                                velocity: onMessage.velocity
                            )
                        )
                    }
                case .specialAction(let action):
                    action()
                }
            },
            tapCount: interactionStyle == .doubleTap ? 2 : 1
        )
        .onAppear(perform: {
            switch midiMessageStyle {
            case .onOffSame(let message):
                listenToIncomingMessage(message)
            case .onOffDifferent(let onMessage, let offMessage):
                listenToIncomingMessage(onMessage)
                listenToIncomingMessage(offMessage)
            case .specialAction: ()
            }
        })
        .onTouch(
            down: { _ in
                if interactionStyle == .momentary {
                    isOn = true

                    switch midiMessageStyle {
                    case .onOffSame(let message):
                        midiBus.sendEvent(
                            message: MidiMessage(
                                channel: message.channel,
                                controller: message.controller,
                                velocity: 127
                            )
                        )
                    case .onOffDifferent(let onMessage, let offMessage):
                        if isOn {
                            midiBus.sendEvent(
                                message: MidiMessage(
                                    channel: onMessage.channel,
                                    controller: onMessage.controller,
                                    velocity: 127
                                )
                            )
                        } else {
                            midiBus.sendEvent(
                                message: MidiMessage(
                                    channel: offMessage.channel,
                                    controller: offMessage.controller,
                                    velocity: 127
                                )
                            )
                        }
                    case .specialAction(let action):
                        action()
                    }
                }
            },
            up: { _ in
                if interactionStyle == .momentary {
                    isOn = false

                    switch midiMessageStyle {
                    case .onOffSame(let message):
                        midiBus.sendEvent(
                            message: MidiMessage(
                                channel: message.channel,
                                controller: message.controller,
                                velocity: 0
                            )
                        )
                    case .onOffDifferent(let onMessage, let offMessage):
                        if isOn {
                            midiBus.sendEvent(
                                message: MidiMessage(
                                    channel: onMessage.channel,
                                    controller: onMessage.controller,
                                    velocity: 0
                                )
                            )
                        } else {
                            midiBus.sendEvent(
                                message: MidiMessage(
                                    channel: offMessage.channel,
                                    controller: offMessage.controller,
                                    velocity: 0
                                )
                            )
                        }
                    case .specialAction(let action):
                        action()
                    }
                }
            }
        )
    }

    private func listenToIncomingMessage(_ message: MidiMessage) {
        midiBus.listeners.append(MidiMessageListener(channel: message.channel, controller: message.controller, onMessageReceived: {
            switch midiMessageStyle {
            case .onOffSame:
                isOn = $0 == 127
            case .onOffDifferent(let onMessage, let offMessage):
                if onMessage == message && $0 == 127 {
                    isOn = true
                }
                if offMessage == message && $0 == 127 {
                    isOn = false
                }
            case .specialAction:
                ()
            }
        }))
    }
}
