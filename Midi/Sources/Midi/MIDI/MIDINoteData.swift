// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Struct holding relevant data for MusicTrackManager note events
@available(macOS 13.0, *)
@available(iOS 16.0, *)
struct MIDINoteData: CustomStringConvertible, Equatable {
    /// MIDI Note Number
    var noteNumber: MIDINoteNumber

    /// MIDI Velocity
    var velocity: MIDIVelocity

    /// MIDI Channel
    var channel: MIDIChannel

    /// Note duration
    var duration: Duration

    /// Note position as a duration from the start
    var position: Duration

    /// Initialize the MIDI Note Data
    /// - Parameters:
    ///   - noteNumber: MID Note Number
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///   - duration: Note duration
    ///   - position: Note position as a duration from the start
    init(noteNumber: MIDINoteNumber,
                velocity: MIDIVelocity,
                channel: MIDIChannel,
                duration: Duration,
                position: Duration
    )
    {
        self.noteNumber = noteNumber
        self.velocity = velocity
        self.channel = channel
        self.duration = duration
        self.position = position
    }

    /// Pretty printout
    var description: String {
        return """
        note: \(noteNumber)
        velocity: \(velocity)
        channel: \(channel)
        """
    }
}
