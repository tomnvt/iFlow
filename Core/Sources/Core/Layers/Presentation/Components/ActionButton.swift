//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Midi
import SwiftUI

struct ActionButton: View {
    let title: String
    let channel: Int
    let controller: Int
    var offActionController: Int?
    var momentary: Bool = false
    var activeControllers: [(channel: Int, controller: Int)]
    var onMidiAction: ((MidiMessage) -> Void)?
    var specificValue: Int?

    var controllerIsActive: Bool {
        activeControllers.contains(where: { $0.channel == channel && $0.controller == controller })
    }

    @State var momentarillyOn: Bool = false

    var body: some View {
        Rectangle()
            .foregroundColor((controllerIsActive || momentarillyOn) ? GrayScaleColor.backgroundDisabled.color : GrayScaleColor.backgroundEnabled.color)
            .overlay {
                Text(title)
                    .lineLimit(0)
                    .foregroundColor(GrayScaleColor.foregroundEnabled.color)
                    .minimumScaleFactor(0.01)
            }
            .onTapGesture {
                if !momentary {
                    if controllerIsActive, let offActionController {
                        onMidiAction?(.init(channel: channel, controller: controller,
                                            velocity: (!controllerIsActive).asVelocity))
                        onMidiAction?(.init(channel: channel, controller: offActionController,
                                            velocity: controllerIsActive.asVelocity))
                    } else {
                        onMidiAction?(.init(channel: channel, controller: controller,
                                            velocity: (!controllerIsActive).asVelocity))
                    }
                }
            }
            .onTouch(down: { _ in
                if momentary {
                    momentarillyOn = true
                    onMidiAction?(.init(channel: channel, controller: controller, velocity: 127))
                }
            }, up: { _ in
                if momentary {
                    momentarillyOn = false
                }
            })
    }
}
