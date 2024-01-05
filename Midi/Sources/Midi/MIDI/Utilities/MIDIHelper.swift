// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Helper functions for MIDI
enum MIDIHelper {
    /// Convert MIDI Bytes to 16 bit
    /// - Parameters:
    ///   - msb: Most significant bit
    ///   - lsb: Least significant bit
    /// - Returns: 16 bit integer
    static func convertTo16Bit(msb: MIDIByte, lsb: MIDIByte) -> UInt16 {
        return (UInt16(msb) << 8) | UInt16(lsb)
    }

    /// Convert MIDI Bytes to 32 bit
    /// - Parameters:
    ///   - msb: Most significant bit
    ///   - data1: First data byte
    ///   - data2: Second data byte
    ///   - lsb: Least significant bit
    /// - Returns: 32 bit integer
    static func convertTo32Bit(msb: MIDIByte, data1: MIDIByte, data2: MIDIByte, lsb: MIDIByte) -> UInt32 {
        var value = UInt32(lsb) & 0xFF
        value |= (UInt32(data2) << 8) & 0xFFFF
        value |= (UInt32(data1) << 16) & 0xFFFFFF
        value |= (UInt32(msb) << 24) & 0xFFFF_FFFF
        return value
    }

    /// Convert bytes to string
    /// - Parameter bytes: MIDI Bytes
    /// - Returns: Printable string
    static func convertToString(bytes: [MIDIByte]) -> String {
        return bytes.map(String.init).joined()
    }

    /// Convert bytes to ASCII String
    /// - Parameter bytes: MIDI Bytes
    /// - Returns: Printable string in UTF8 format
    static func convertToASCII(bytes: [MIDIByte]) -> String? {
        return String(bytes: bytes, encoding: .utf8)
    }
}
