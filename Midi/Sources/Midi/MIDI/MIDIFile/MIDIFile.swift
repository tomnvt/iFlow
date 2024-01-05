// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

    import Foundation

    /// MIDI File
    struct MIDIFile {
        /// File name
        var filename: String

        var chunks: [MIDIFileChunk] = []

        var headerChunk: MIDIFileHeaderChunk? {
            return chunks.first(where: { $0.isHeader }) as? MIDIFileHeaderChunk
        }

        /// Array of track chunks
        var trackChunks: [MIDIFileTrackChunk] {
            return Array(chunks.drop(while: { $0.isHeader && $0.isValid })) as? [MIDIFileTrackChunk] ?? []
        }

        /// Optional tempo track
        var tempoTrack: MIDIFileTempoTrack? {
            if format == 1, let tempoTrackChunk = trackChunks.first {
                return MIDIFileTempoTrack(trackChunk: tempoTrackChunk)
            }
            return nil
        }

        /// Array of MIDI File tracks
        var tracks: [MIDIFileTrack] {
            var tracks = trackChunks
            if format == 1 {
                tracks = Array(tracks.dropFirst()) // drop tempo track
            }
            return tracks.compactMap { MIDIFileTrack(chunk: $0) }
        }

        /// Format integer
        var format: Int {
            return headerChunk?.format ?? 0
        }

        /// Track count
        var trackCount: Int {
            return headerChunk?.trackCount ?? 0
        }

        /// MIDI Time format
        var timeFormat: MIDITimeFormat? {
            return headerChunk?.timeFormat
        }

        /// Number of ticks per beat
        var ticksPerBeat: Int? {
            return headerChunk?.ticksPerBeat
        }

        /// Number of frames per second
        var framesPerSecond: Int? {
            return headerChunk?.framesPerSecond
        }

        /// Number of ticks per frame
        var ticksPerFrame: Int? {
            return headerChunk?.ticksPerFrame
        }

        /// Time division to use
        var timeDivision: UInt16 {
            return headerChunk?.timeDivision ?? 0
        }

        /// Initialize with a URL
        /// - Parameter url: URL to MIDI File
        init(url: URL) {
            filename = url.lastPathComponent
            if let midiData = try? Data(contentsOf: url) {
                let dataSize = midiData.count
                var chunks = [MIDIFileChunk]()
                var processedBytes = 0
                while processedBytes < dataSize {
                    let data = Array(midiData.suffix(from: processedBytes))
                    if let headerChunk = MIDIFileHeaderChunk(data: data) {
                        chunks.append(headerChunk)
                        processedBytes += headerChunk.rawData.count
                    } else if let trackChunk = MIDIFileTrackChunk(data: data) {
                        chunks.append(trackChunk)
                        processedBytes += trackChunk.rawData.count
                    }
                }
                self.chunks = chunks
            }
        }

        /// Initialize with a path
        /// - Parameter path: Path to MIDI FIle
        init(path: String) {
            self.init(url: URL(fileURLWithPath: path))
        }
    }

#endif
