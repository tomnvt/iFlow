// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

    /// MIDI File Tempo Track
    struct MIDIFileTempoTrack {
        /// Associated MIDI File Track
        let track: MIDIFileTrack

        /// Length of MIDI File tempo track
        var length: Double {
            return track.length
        }

        /// Track name
        var name: String? {
            return track.name
        }

        /// Array of events included on the track
        var events: [MIDIEvent] {
            return track.events
        }

        /// Custom MIDI meta events contained on the track
        var metaEvents: [MIDICustomMetaEvent] {
            return track.metaEvents
        }

        /// Initialize with a MIDI File Track Chunk
        /// - Parameter trackChunk: MIDI File track chunk
        init?(trackChunk: MIDIFileTrackChunk) {
            let tempoTrack = MIDIFileTrack(chunk: trackChunk)
            guard let tempoData = tempoTrack.metaEvents.first(where: { $0.type == .setTempo })?.data else {
                return nil
            }
            track = tempoTrack
            self.tempoData = tempoData
        }

        /// Array of tempo bytes
        var tempoData = [MIDIByte]()

        /// Current tempo
        var tempo: Float {
            let microsecondsPerSecond: Float = 60_000_000
            let int = tempoData.suffix(3).integerValue
            let value = Float(int ?? 500_000)
            return Float(Double(microsecondsPerSecond / value).roundToDecimalPlaces(4))
        }
    }

#endif
