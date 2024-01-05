// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
    /// MIDI Note Duration - helpful for storing length of MIDI notes
    class MIDINoteDuration {
        /// Note Start time
        var noteStartTime = 0.0
        /// Note End time
        var noteEndTime = 0.0
        /// Note Duration
        var noteDuration = 0.0
        /// Note Number
        var noteNumber = 0
        /// Note Number Map
        var noteNumberMap = 0
        /// Note Range
        var noteRange = 0

        /// Initialize with common parameters
        /// - Parameters:
        ///   - noteOnPosition: Note start time
        ///   - noteOffPosition: Note end time
        ///   - noteNumber: Note Number
        init(noteOnPosition: Double, noteOffPosition: Double, noteNumber: Int) {
            noteStartTime = noteOnPosition
            noteEndTime = noteOffPosition
            noteDuration = noteOffPosition - noteOnPosition
            self.noteNumber = noteNumber
        }
    }

    /// Get the MIDI events which occur inside a MIDI track in a MIDI file
    /// This class should only be initialized once if possible - (many calculations are involved)
    class MIDIFileTrackNoteMap {
        /// MIDI File Track
        let midiTrack: MIDIFileTrack!
        /// MIDI File
        let midiFile: MIDIFile!
        /// Track number
        let trackNumber: Int!
        /// Low Note
        var loNote: Int = 0
        /// High note
        var hiNote: Int = 0
        /// Note Range
        var noteRange: Int = 0
        /// End of track
        var endOfTrack: Double = 0.0
        private var notesInProgress: [Int: (Double, Double)] = [:]
        /// A list of all the note events in the MIDI file for tracking purposes
        var noteList = [MIDINoteDuration]()

        /// Initialize track map
        /// - Parameters:
        ///   - midiFile: MIDI File
        ///   - trackNumber: Track Number
        init(midiFile: MIDIFile, trackNumber: Int) {
            self.midiFile = midiFile
            if !midiFile.tracks.isEmpty {
                if trackNumber > (midiFile.tracks.count - 1) {
                    let trackNumber = (midiFile.tracks.count - 1)
                    midiTrack = midiFile.tracks[trackNumber]
                    self.trackNumber = trackNumber
                } else if trackNumber < 0 {
                    midiTrack = midiFile.tracks[0]
                    self.trackNumber = 0
                } else {
                    midiTrack = midiFile.tracks[trackNumber]
                    self.trackNumber = trackNumber
                }
            } else {
                Log("No Tracks in the MIDI File")
                midiTrack = midiFile.tracks[0]
                self.trackNumber = 0
            }
            getNoteList()
            getLoNote()
            getHiNote()
            getNoteRange()
            getEndOfTrack()
        }

        private func addNoteOff(event: MIDIEvent) {
            let eventPosition = (event.positionInBeats ?? 1.0) / Double(midiFile.ticksPerBeat ?? 1)
            let noteNumber = Int(event.data[1])
            if let prevPosValue = notesInProgress[noteNumber]?.0 {
                notesInProgress[noteNumber] = (prevPosValue, eventPosition)
                var noteTracker = MIDINoteDuration(
                    noteOnPosition: 0.0,
                    noteOffPosition: 0.0, noteNumber: 0
                )
                if let note = notesInProgress[noteNumber] {
                    noteTracker = MIDINoteDuration(
                        noteOnPosition:
                        note.0,
                        noteOffPosition:
                        note.1,
                        noteNumber: noteNumber
                    )
                }
                notesInProgress.removeValue(forKey: noteNumber)
                noteList.append(noteTracker)
            }
        }

        private func addNoteOn(event: MIDIEvent) {
            let eventPosition = (event.positionInBeats ?? 1.0) / Double(midiFile.ticksPerBeat ?? 1)
            let noteNumber = Int(event.data[1])
            notesInProgress[noteNumber] = (eventPosition, 0.0)
        }

        private func getNoteList() {
            let events = midiTrack.channelEvents
            var velocityEvent: Int?
            for event in events {
                // Usually the third element of a note event is the velocity
                if event.data.count > 2 {
                    velocityEvent = Int(event.data[2])
                }
                if event.status?.type == MIDIStatusType.noteOn {
                    // A note played with a velocity of zero is the equivalent
                    // of a noteOff command
                    if velocityEvent == 0 {
                        addNoteOff(event: event)
                    } else {
                        addNoteOn(event: event)
                    }
                }
                if event.status?.type == MIDIStatusType.noteOff {
                    addNoteOff(event: event)
                }
            }
        }

        private func getLoNote() {
            if noteList.count >= 2 {
                loNote = (noteList.min(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
            } else {
                loNote = 0
            }
        }

        private func getHiNote() {
            if noteList.count >= 2 {
                hiNote = (noteList.max(by: { $0.noteNumber < $1.noteNumber })?.noteNumber) ?? 0
            } else {
                hiNote = 0
            }
        }

        private func getNoteRange() {
            // Increment by 1 to properly fit the notes in the MIDI UI View
            noteRange = (hiNote - loNote) + 1
        }

        private func getEndOfTrack() {
            let midiTrack = midiFile.tracks[trackNumber]
            let endOfTrackEvent = 47
            var eventTime = 0.0
            for event in midiTrack.events {
                // Again, here we make sure the
                // data is in the proper format
                // for a MIDI end of track message before trying to parse it
                if event.data[1] == endOfTrackEvent, event.data.count >= 3 {
                    eventTime = (event.positionInBeats ?? 0.0) / Double(midiFile.ticksPerBeat ?? 1)
                    endOfTrack = eventTime
                } else {
                    // Some MIDI files may not
                    // have this message. Instead, we can
                    // grab the position of the last noteOff message
                    if !noteList.isEmpty {
                        endOfTrack = noteList[noteList.count - 1].noteEndTime
                    }
                }
            }
            endOfTrack = 0.0
        }
    }
#endif
