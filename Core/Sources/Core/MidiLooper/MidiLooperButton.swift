//
//  File.swift
//  
//
//  Created by Tom Novotny on 13.07.2023.
//

import SwiftUI

struct MidiLooperButton: View {
    enum State {
        case enabled
        case active
        case disabled
    }

    var state: State = .enabled
    var title: String?
    var systemImageName: SystemImageName?
    var onTap: (() -> Void)?
    var tapCount = 1
    var onLongTap: (() -> Void)?
    var onTouchDown: (() -> Void)?
    var onTouchUp: (() -> Void)?

    var backgroundColor: Color {
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
        switch state {
        case .enabled:
            return GrayScaleColor.foregroundEnabled.color
        case .active:
            return GrayScaleColor.foregroundActive.color
        case .disabled:
            return GrayScaleColor.foregroundDisabled.color
        }
    }

    var body: some View {
        Button {} label: {
            MidiLooperLabel(backgroundColor: backgroundColor, title: title, systemImageName: systemImageName, titleColor: titleColor)
                .onTapGesture(count: tapCount) {
                    onTap?()
                }
                .onLongPressGesture(minimumDuration: 2) {
                    onLongTap?()
                }
                .onTouch(
                    down: { _ in onTouchDown?() },
                    up: { _ in onTouchUp?() }
                )
        }
        .buttonStyle(.plain)
    }
}

struct MidiLooperButton_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            MidiLooperButton(state: .enabled, title: "Title", onTap: {})
                .padding()
            MidiLooperButton(state: .active, title: "Title", onTap: {})
                .padding()
            MidiLooperButton(state: .disabled, title: "Title", onTap: {})
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}

struct MidiLooperLabel: View {
    var backgroundColor: Color = GrayScaleColor.backgroundEnabled.color
    var title: String?
    var systemImageName: SystemImageName?
    var titleColor: Color = GrayScaleColor.foregroundEnabled.color

    var body: some View {
        Rectangle()
            .foregroundColor(backgroundColor)
            .overlay {
                HStack(spacing: 12) {
                    if let systemImageName {
                        Image(systemName: systemImageName.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    }
                    if let title {
                        Text(title)
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundColor(titleColor)
            }
            .cornerRadius(16)
    }
}
