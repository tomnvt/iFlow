//
//  File.swift
//
//
//  Created by Tom Novotny on 14.07.2023.
//

#if canImport(AppKit)
import AppKit
import SwiftUI
import Midi

struct KeystrokeView: NSViewRepresentable {
    typealias NSViewType = KeystrokeHostingView

    let midiBus: MIDIBus

    func makeNSView(context: Context) -> KeystrokeHostingView {
        let view = KeystrokeHostingView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: KeystrokeHostingView, context: Context) {
        // Update view if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(midiBus: midiBus)
    }

    class Coordinator: NSObject, KeystrokeHostingViewDelegate {
        let midiBus: MIDIBus
        var octave = 2
        var downKeys = [String]()

        init(midiBus: MIDIBus) {
            self.midiBus = midiBus
        }

        func keyDown(with event: NSEvent) {
            guard
                let character = event.charactersIgnoringModifiers,
                !downKeys.contains(character)
            else { return }
            // Handle key down event
            print("Key down: \(event.charactersIgnoringModifiers ?? "")")
            downKeys.append(character)
            process(character: character, pressedDown: true)
        }

        func keyUp(with event: NSEvent) {
            guard let character = event.charactersIgnoringModifiers else { return }
            // Handle key up event
            print("Key up: \(event.charactersIgnoringModifiers ?? "")")
            process(character: event.charactersIgnoringModifiers, pressedDown: false)
            downKeys.removeAll(where: { $0 == character })
        }

        func process(character: String?, pressedDown: Bool) {
            guard let character else { return }
            let backspaceString = "\u{7F}"
            let chromaticScaleKeys = ["a", "w", "s", "e", "d", "f", "t", "g", "y", "h", "u", "j", "k", "o", "l", "p"]
            if let index = chromaticScaleKeys.firstIndex(of: character) {
                midiBus.sendEvent(midiAction: pressedDown ? .noteOn : .noteOff, channel: 2, controller: octave * 12 + index, velocity: pressedDown ? 127 : 0)
            }
            if ["z" , "x"].contains(character) && pressedDown {
                downKeys.removeAll(where: { $0 == character })
                downKeys.forEach { key in
                    process(character: key, pressedDown: false)
                }
                if character == "z" && octave > 0 {
                    octave -= 1
                }
                if character == "x" {
                    octave += 1
                }
                downKeys = []
            }
            if !pressedDown {
                if character == backspaceString {
                    NotificationCenter.default.post(Notification(name: .deletePressed))
                }
                if character == " " {
                    NotificationCenter.default.post(Notification(name: .spacebarPresed))
                }
            }
        }
    }
}

//class KeystrokeToMidiMessageMapper {
//    static func map(character: String, pressedDown: Bool) -> MidiMessage {
//        let chromaticScaleKeys = ["a", "w", "s", "e", "d", "f", "t", "g", "y", "h", "u", "j", "k", "o", "l", "p"]
//        if let index = chromaticScaleKeys.firstIndex(of: character) {
//            return MidiMessage(channel: 1, controller: 50 + index, velocity: 127)
//        }
//    }
//}

protocol KeystrokeHostingViewDelegate: AnyObject {
    func keyDown(with event: NSEvent)
    func keyUp(with event: NSEvent)
}

class KeystrokeHostingView: NSView {
    weak var delegate: KeystrokeHostingViewDelegate?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        delegate?.keyDown(with: event)
    }

    override func keyUp(with event: NSEvent) {
        delegate?.keyUp(with: event)
    }
}
#endif
