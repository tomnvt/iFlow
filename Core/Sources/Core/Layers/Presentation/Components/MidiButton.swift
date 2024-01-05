//
//  SwiftUIView.swift
//  
//
//  Created by Tom Novotny on 06.09.2023.
//

import SwiftUI
import Midi

struct MidiButton: View {
    @EnvironmentObject var midiBus: MIDIBus

    enum State {
        case enabled
        case active
        case disabled
    }

    enum Style {
        case momentary
        case toggle
        case fader
    }

    var state: State = .enabled
    var style: Style
    var title: String?
    var systemImageName: SystemImageName?
    var channel: Int?
    var controller: Int?
    var onTouchDown: (() -> Void)?
    var onTouchUp: (() -> Void)?
    @SwiftUI.State var isOn: Bool = false
    @SwiftUI.State var size = CGSize.zero
    @SwiftUI.State var value = 0
    @SwiftUI.State var isTouched = false
    @SwiftUI.State var dragStartValue = 0

    var backgroundColor: Color {
        if isOn {
            return GrayScaleColor.backgroundActive.color
        }
        switch state {
        case .enabled:
            return GrayScaleColor.backgroundEnabled.color
        case .active:
            return GrayScaleColor.backgroundActive.color
        case .disabled:
            return GrayScaleColor.backgroundDisabled.color
        }
    }

    var titleColor: Color {
        let activeColor = GrayScaleColor.foregroundActive.color
        if isOn {
            return activeColor
        }
        switch state {
        case .enabled:
            return GrayScaleColor.foregroundEnabled.color
        case .active:
            return activeColor
        case .disabled:
            return GrayScaleColor.foregroundDisabled.color
        }
    }

    var body: some View {
        GeometryReader { proxy in
            MidiLooperLabel(
                backgroundColor: backgroundColor,
                title: title, systemImageName:
                    systemImageName, titleColor: titleColor
            )
            .onTouch(
                down: { _ in
                    isTouched = true
                    if style == .momentary {
                        handleStateChange(on: true)
                    } else {
                        isOn.toggle()
                        handleStateChange(on: isOn)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        onTouchDown?()
                    }
                },
                up: { _ in
                    isTouched = false
                    if style == .momentary {
                        handleStateChange(on: false)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        onTouchUp?()
                    }
                }
            )
            .onAppear() {
                self.size = proxy.size
                if let channel, let controller {
                    midiBus.listeners.append(MidiMessageListener(
                        channel: channel,
                        controller: controller,
                        onMessageReceived: { value in
                            if !isTouched {
                                isOn = value == 127
                            }
                        })
                    )
                }
            }
        }
    }

    func handleStateChange(on: Bool) {
        isOn = on
        if let channel, let controller {
            midiBus.sendEvent(message: MidiMessage(channel: channel, controller: controller, velocity: on ? 127 : 0))
        }
    }
}

struct MidiButton_Previews: PreviewProvider {
    static var previews: some View {
        MidiButton(style: .momentary, title: "PREVIEW", channel: 0, controller: 0)
            .frame(width: 100, height: 100)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
