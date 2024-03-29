// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

#if !os(tvOS)

    /// MIDI File Track
    struct MIDIFileTrack {
        var chunk: MIDIFileTrackChunk

        /// Channel events
        var channelEvents: [MIDIEvent] {
            return chunk.chunkEvents.compactMap { MIDIEvent(fileEvent: $0) }.filter { $0.status?.data != nil }
        }

        /// MIDI Events
        var events: [MIDIEvent] {
            return chunk.chunkEvents.compactMap { MIDIEvent(fileEvent: $0) }
        }

        /// Meta events
        var metaEvents: [MIDICustomMetaEvent] {
            return chunk.chunkEvents.compactMap { MIDICustomMetaEvent(fileEvent: $0) }
        }

        /// Length of file track in beats
        var length: Double {
            return metaEvents.last?.positionInBeats ?? 0
        }

        /// File track name
        var name: String? {
            if let nameChunk = chunk.chunkEvents
                .first(where: { $0.typeByte == MIDICustomMetaEventType.trackName.rawValue }),
                let meta = MIDICustomMetaEvent(data: nameChunk.computedData)
            {
                return meta.name
            }
            return nil
        }

        /// Initialize with MIDI File Track Chunk
        /// - Parameter chunk: MIDI File Track Chunk
        init(chunk: MIDIFileTrackChunk) {
            self.chunk = chunk
        }
    }

#endif
