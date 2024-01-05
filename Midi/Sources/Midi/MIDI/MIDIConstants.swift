//
//  MIDIConstants.swift
//  LinkHut
//
//  Created by Tom Novotny on 04.03.2023.
//

/// Note on shortcut
let noteOnByte: MIDIByte = 0x90
/// Note off shortcut
let noteOffByte: MIDIByte = 0x80

/// MIDI Type Alias making it clear that you're working with MIDI
typealias MIDIByte = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
typealias MIDIWord = UInt16
/// MIDI Type Alias making it clear that you're working with MIDI
typealias MIDINoteNumber = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
typealias MIDIVelocity = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
typealias MIDIChannel = UInt8
