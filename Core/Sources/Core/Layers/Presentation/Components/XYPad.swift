//
//  File.swift
//  
//
//  Created by Tom Novotny on 06.07.2023.
//

import Controls
import Midi
import SwiftUI

struct XYPad: View {
    @EnvironmentObject private var midiBus: MIDIBus
    @State private var x: Float = 1
    @State private var y: Float = 1
    @State private var touched: Bool = false

    var title: String?
    let midiChannelX: Int
    let midiControllerX: Int
    let midiChannelY: Int
    let midiControllerY: Int
    var mainToggleChannel: Int?
    var mainToggleController: Int?
    var adiitionalMessages: [(channel: Int, controller: Int)] = []

    var body: some View {
        ZStack {
            Controls.XYPad(x: $x, y: $y)
                .backgroundColor(GrayScaleColor.backgroundDisabled.color)
                .foregroundColor(.yellow)
                .indicatorSize(CGSize(width: 20, height: 20))
                .cornerRadius(10)
                .onStarted { touched = true }
                .onEnded { touched = false }
                .onChange(of: x, perform: processDragValue)
                .onChange(of: y, perform: processDragValue)
                .onAppear {
                    midiBus.listeners.append(
                        MidiMessageListener(channel: midiChannelX, controller: midiControllerX, onMessageReceived: { value in
                            x = Float(value) / 127
                        })
                    )
                    midiBus.listeners.append(
                        MidiMessageListener(channel: midiChannelY, controller: midiControllerY, onMessageReceived: { value in
                            y = Float(value) / 127
                        })
                    )
                }
            if let title {
                Text(title)
                    .allowsHitTesting(false)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private extension XYPad {
    var xVelocity: Int { Int(127 * x) }
    var yVelocity: Int { Int(127 * y) }
    var xMessage: MidiMessage { MidiMessage(channel: midiChannelX, controller: midiControllerX, velocity: xVelocity) }
    var yMessage: MidiMessage { MidiMessage(channel: midiChannelY, controller: midiControllerY, velocity: yVelocity) }

    func processDragValue(_ value: Float) {
        guard touched else { return }
        midiBus.sendEvent(message: xMessage)
        midiBus.sendEvent(message: yMessage)

        if let mainToggleChannel, let mainToggleController {
            if xVelocity == 127 && yVelocity == 127 {
                midiBus.sendEvent(
                    midiAction: .controllerChange,
                    channel: mainToggleChannel,
                    controller: mainToggleController,
                    velocity: 127
                )
            } else {
                midiBus.sendEvent(
                    midiAction: .controllerChange,
                    channel: mainToggleChannel,
                    controller: mainToggleController,
                    velocity: 0
                )
            }
        }
    }
}

struct XYPadMessages {
    let midiChannelX: Int
    let midiControllerX: Int
    let midiChannelY: Int
    let midiControllerY: Int
}

struct XYPad2: View {
    @EnvironmentObject private var midiBus: MIDIBus
    @State private var x: Float = 1
    @State private var y: Float = 1
    @State private var touched: Bool = false

    var title: String?
    let messages: [XYPadMessages]
    var mainToggleChannel: Int?
    var mainToggleController: Int?
    var adiitionalMessages: [(channel: Int, controller: Int)] = []

    var body: some View {
        ZStack {
            Controls.XYPad(x: $x, y: $y)
                .backgroundColor(GrayScaleColor.backgroundDisabled.color)
                .foregroundColor(.yellow)
                .indicatorSize(CGSize(width: 20, height: 20))
                .cornerRadius(10)
                .onStarted { touched = true }
                .onEnded { touched = false }
                .onChange(of: x, perform: processDragValue)
                .onChange(of: y, perform: processDragValue)
            if let title {
                Text(title)
                    .allowsHitTesting(false)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private extension XYPad2 {
    var xVelocity: Int { Int(127 * x) }
    var yVelocity: Int { Int(127 * y) }
    var xMessages: [MidiMessage] { messages.map { MidiMessage(channel: $0.midiChannelX, controller: $0.midiControllerX, velocity: xVelocity) } }
    var yMessages: [MidiMessage] { messages.map { MidiMessage(channel: $0.midiChannelY, controller: $0.midiControllerY, velocity: yVelocity) } }

    func processDragValue(_ value: Float) {
        guard touched else { return }

        xMessages.forEach { midiBus.sendEvent(message: $0) }
        yMessages.forEach { midiBus.sendEvent(message: $0) }
        

//        if let mainToggleChannel, let mainToggleController {
//            if xVelocity == 127 && yVelocity == 127 {
//                midiBus.sendEvent(
//                    midiAction: .controllerChange,
//                    channel: mainToggleChannel,
//                    controller: mainToggleController,
//                    velocity: 127
//                )
//            } else {
//                midiBus.sendEvent(
//                    midiAction: .controllerChange,
//                    channel: mainToggleChannel,
//                    controller: mainToggleController,
//                    velocity: 0
//                )
//            }
//        }
    }
}
