//
//  MIDIBus.swift
//  LinkHut
//
//  Created by Tom Novotny on 19.02.2023.
//

import CoreMIDI
//import UIKit
#if canImport(UIKit)
let deviceIsIpad = true
#else
let deviceIsIpad = false
#endif

import Combine

public class MIDIBus: ObservableObject {
    @Published public var midiInput = [MidiMessage(channel: 0, controller: 0, velocity: 0)]

    private let midi = MIDI()
    public var listeners: [MidiMessageListener] = []
    public var onMessageReceivedWithVelocity: ((NoteMessage) -> Void)?

    public var onSystemMessageReceive: ((SystemMidiMessage) -> Void)?

    public let systemMessageSubject = PassthroughSubject<SystemMidiMessage, Error>()

    public var noteOnEvents: ((MidiMessage) -> Void)?
    public var noteOffEvents: ((MidiMessage) -> Void)?

    public init() {

        midi.createVirtualPorts()
        midi.createVirtualPorts()
        if deviceIsIpad {
            for uid in midi.destinationUIDs {
                midi.openOutput(uid: uid)
            }
        } else {
            for uid in midi.virtualOutputUIDs {
                midi.openOutput(uid: uid)
            }
        }
        midi.addListener(self)
        midi.openInput()

        let srtListener = MIDISystemRealTimeListener()
        let tempoListener = MIDITempoListener()
        midi.addListener(tempoListener)
        midi.addListener(srtListener)
    }

    public func sendEvent(message: MidiMessage) {
        sendEvent(midiAction: .controllerChange, channel: message.channel, controller: message.controller, velocity: message.velocity)
    }

    public func sendEvent(
        midiAction: MIDIAction,
        channel: Int,
        controller: Int,
        velocity: Int
    ) {
        let event = StMIDIEvent(statusType: midiAction.asMidiStatusType.rawValue,
                                channel: MIDIChannel(Float16(channel - 1)),
                                note: MIDINoteNumber(Float16(controller)),
                                velocity: MIDIByte(velocity))

        switch event.statusType {
        case MIDIStatusType.controllerChange.rawValue:
            print("[MIDI] - CC - channel: \(channel), controller: \(controller), velocity: \(velocity)")
            midi.sendControllerMessage(
                event.note,
                value: event.velocity ?? 0,
                channel: event.channel,
                virtualOutputPorts: midi.virtualOutputs
            )
        case MIDIStatusType.programChange.rawValue:
            midi.sendEvent(
                MIDIEvent(programChange: event.note, channel: event.channel),
                virtualOutputPorts: midi.virtualOutputs
            )
        case MIDIStatusType.noteOn.rawValue:
            midi.sendNoteOnMessage(
                noteNumber: event.note,
                velocity: event.velocity ?? 0,
                channel: event.channel,
                virtualOutputPorts: midi.virtualOutputs
            )
        case MIDIStatusType.noteOff.rawValue:
            midi.sendNoteOffMessage(
                noteNumber: event.note,
                channel: event.channel,
                virtualOutputPorts: midi.virtualOutputs
            )
        default:
            break
        }
    }
}

extension MIDIBus: MIDIListener {
    func receivedMIDINoteOn(
        noteNumber: MIDINoteNumber,
        velocity: MIDIVelocity,
        channel: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {
        print("[DBG] receivedMIDINoteOn: noteNumber \(noteNumber) - velocity \(velocity)")
        noteOnEvents?(MidiMessage(channel: 0, controller: Int(noteNumber), velocity: Int(velocity)))
        onMessageReceivedWithVelocity?(NoteMessage(noteOn: true, pitch: Int(noteNumber), velocity: Int(velocity)))
        midi.sendNoteOnMessage(
            noteNumber: noteNumber,
            velocity: velocity,
            channel: channel,
            virtualOutputPorts: midi.virtualOutputs
        )
    }

    func receivedMIDINoteOff(
        noteNumber: MIDINoteNumber,
        velocity: MIDIVelocity,
        channel _: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {
        print("[DBG] receivedMIDINoteOff: noteNumber \(noteNumber) - velocity \(velocity)")
        noteOffEvents?(MidiMessage(channel: 0, controller: Int(noteNumber), velocity: Int(velocity)))
        onMessageReceivedWithVelocity?(NoteMessage(noteOn: false, pitch: Int(noteNumber), velocity: Int(velocity)))
    }

    func receivedMIDIController(
        _ controller: MIDIByte,
        value: MIDIByte,
        channel: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {
        print("[DBG] controller: \(controller) - value: \(value) - channel: \(channel)")
        listeners.filter { $0.channel == channel + 1 && $0.controller == Int(controller) }
            .forEach { $0.onMessageReceived(Int(value)) }
    }

    func receivedMIDIAftertouch(
        noteNumber _: MIDINoteNumber,
        pressure _: MIDIByte,
        channel _: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {}

    func receivedMIDIAftertouch(
        _: MIDIByte,
        channel: MIDIChannel,
        portID: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {
        //        print("[DBG] receivedMIDIAftertouch: noteNumber \(channel) - velocity \(portID)")
    }

    func receivedMIDIPitchWheel(
        _: MIDIWord,
        channel _: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {}

    func receivedMIDIProgramChange(
        _: MIDIByte,
        channel _: MIDIChannel,
        portID _: MIDIUniqueID?,
        timeStamp _: MIDITimeStamp?
    ) {}

    func receivedMIDISystemCommand(_ data: [MIDIByte], portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        print("receivedMIDISystemCommand \(data)")
        if let message = SystemMidiMessage(rawValue: Int(data[0])) {
            onSystemMessageReceive?(message)
        }
        var chars = ""
        for (index, byte) in data.enumerated() {
            if index < 7 || index == data.count - 1 {
                continue
            }
            let char = Character(UnicodeScalar(byte))
            chars += String(char)
        }
        //        print("[DBG] Recieved message: \(chars)")
    }

    func receivedMIDISetupChange() {}

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {}

    func receivedMIDINotification(notification _: MIDINotification) {}
}

extension MIDIBus: MIDIBusProtocol {}
