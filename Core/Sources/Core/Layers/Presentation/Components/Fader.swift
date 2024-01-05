//
//  Fader.swift
//  MidiMap
//
//  Created by Tom Novotny on 11.02.2023.
//

import Midi
import SwiftUI

struct FaderSlider: View {
    @EnvironmentObject private var midiBus: MIDIBus
    @State var value: Double = 0.5
    var orientation = Orientation.vertical
    let channel: Int
    let controller: Int
    var onValueChange: ((MidiMessage) -> Void)?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: orientation == .vertical ? .bottom : .leading) {
                Rectangle()
                    .shadow(radius: 5)
                    .foregroundColor(GrayScaleColor.backgroundEnabled.color)

                Rectangle()
                    .clipped()
                    .if(orientation == .vertical, modify: { view in
                        view.frame(height: proxy.size.height * value)
                    }, else: { view in
                        view.frame(width: proxy.size.width * value)
                    })
                    .foregroundColor(GrayScaleColor.foregroundEnabled.color)
            }
            .onChange(of: value) { _ in
                print("DBG \(value)")
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        var percentage: CGFloat
                        if orientation == .vertical {
                            percentage = value.location.y / (proxy.size.height + 10)
                        } else {
                            percentage = value.location.x / (proxy.size.width + 10)
                        }
                        if percentage >= 0.8 {
                            self.value = 0
                        } else {
                            if orientation == .vertical {
                                self.value = abs(1 - percentage)
                            } else {
                                self.value = percentage
                            }
                        }
                        if self.value > 1 {
                            self.value = 1
                        }
                        if percentage >= 0, percentage <= 1 {
                            let velocity = 127 - Int(percentage * 127)
                            midiBus.sendEvent(message: .init(channel: channel, controller: controller, velocity: velocity))
                        }
                    }
            )
        }
    }
}

struct Fader_Previews: PreviewProvider {
    static var previews: some View {
        FaderSlider(channel: 1, controller: 1)
            .previewLayout(.sizeThatFits)
    }
}
