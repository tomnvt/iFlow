//
//  Knob.swift
//  iFlow
//
//  Created by Tom Novotny on 10.06.2023.
//

import Controls
import Midi
import SwiftUI

struct Knob: View {
    @EnvironmentObject var midiBus: MIDIBus
    var title: String?
    let midiController: Int
    let midiChannel: Int
    @State private var value: Float
    @State private var velocity: Int = 0
    @State private var touchOn: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let extraMessage: MidiMessage?

    init(
        title: String? = nil,
        midiController: Int,
        midiChannel: Int,
        value: Float = 0,
        extraMessage: MidiMessage? = nil
    ) {
        self.title = title
        self.midiController = midiController
        self.midiChannel = midiChannel
        self.value = value
        self.extraMessage = extraMessage
    }

    var body: some View {
        ZStack {
            ControlKnob(value: $value, touched: $touchOn)
                .onChange(of: value) { newValue in
                    guard touchOn else { return }
                    velocity = Int(newValue * 127)
                    sendValue()

                }
            if let title {
                Text(title)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: midiBus.midiInput, perform: { messages in
            guard let message = messages.first(where: { $0.channel == midiChannel && $0.controller == midiController })
            else { return }
            value = Float(message.velocity) / 127
        })
        .onAppear {
            midiBus.listeners.append(MidiMessageListener(channel: midiChannel, controller: midiController, onMessageReceived: {
                value = Float($0) / 127
            }))
        }
        .onReceive(timer) { time in
            guard touchOn else { return }
            sendValue()
        }
    }

    func sendValue() {
        midiBus.sendEvent(message: MidiMessage(channel: midiChannel, controller: midiController, velocity: velocity))
        if let extraMessage {
            midiBus.sendEvent(message: extraMessage)
        }
    }
}

struct Knob_Previews: PreviewProvider {
    static var previews: some View {
        Knob(
            midiController: 0,
            midiChannel: 0
        )
        .frame(width: 50, height: 50)
    }
}

struct ControlKnob: View {
    @Binding var value: Float
    var range: ClosedRange<Float> = 0.0 ... 1.0
    @Binding var touched: Bool

    var backgroundColor: Color = GrayScaleColor.backgroundDisabled.color
    var foregroundColor: Color = .black

    var normalizedValue: Double {
        Double((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    let minimumAngle = Angle(degrees: 45)
    let maximumAngle = Angle(degrees: 315)

    func dim(_ proxy: GeometryProxy) -> CGFloat {
        min(proxy.size.width, proxy.size.height)
    }
    var origin: Float = 0

    var trimFrom: CGFloat {
        if value >= origin {
            return minimumAngle.degrees / 360 + CGFloat(originLocation) * angleRange / 360.0
        } else {
            return (minimumAngle.degrees + CGFloat(nondimValue) * angleRange) / 360.0
        }
    }

    var originLocation: Float {
        (origin - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var angleRange: CGFloat {
        CGFloat(maximumAngle.degrees - minimumAngle.degrees)
    }

    var nondimValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var trimTo: CGFloat {
        if value >= origin {
            return (minimumAngle.degrees +  CGFloat(nondimValue) * angleRange) / 360.0 + 0.0001
        } else {
            return (minimumAngle.degrees + CGFloat(originLocation) * angleRange) / 360.0
        }
    }


    public var body: some View {
        Control(
            value: $value,
            in: range,
            geometry: .twoDimensionalDrag(xSensitivity: 1, ySensitivity: 1),
            onStarted: {
                touched = true
            },
            onEnded: {
                touched = false
            }
        ) { geo in
            ZStack(alignment: .center) {
                Ellipse().foregroundColor(backgroundColor)
                Circle()
                    .trim(from: minimumAngle.degrees / 360.0, to: maximumAngle.degrees / 360.0)

                    .rotation(.degrees(-270))
                    .stroke(.yellow,
                            style: StrokeStyle(lineWidth: dim(geo) / 10,
                                               lineCap: .round))
                    .squareFrame(dim(geo) * 0.8)
                    .foregroundColor(foregroundColor)

                // Stroke value trim of knob

                Circle()
                //                    .trim(from: trimFrom, to: trimTo)
                    .rotation(.degrees(-270))
                    .stroke(Color.black,
                            style: StrokeStyle(lineWidth: dim(geo) / 3,
                                               lineCap: .butt))
                //                    .squareFrame(dim(geo) * 0.8)
                    .frame(width: dim(geo) * 0.8, height: dim(geo) * 0.8)
                    .brightness(0.1)
                Circle()
                    .trim(from: trimFrom, to: trimTo)
                    .rotation(.degrees(-270))

                    .stroke(Color.blue,
                            style: StrokeStyle(lineWidth: dim(geo) / 8,
                                               lineCap: .butt))
                    .brightness(0)
//                    .squareFrame(dim(geo) * 0.8)
                    .frame(width: dim(geo) * 0.7, height: dim(geo) * 0.7)
            }.drawingGroup() // Drawing groups improve antialiasing of rotated indicator
        }.aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
    }
}

struct Knob_Preview: PreviewProvider {
    static var previews: some View {
        Knob(title: "PREV", midiController: 1, midiChannel: 1)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
