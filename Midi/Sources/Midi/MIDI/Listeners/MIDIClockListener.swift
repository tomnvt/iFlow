// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
    import CoreMIDI
    import Foundation
    import os.log

    /// This class is used to count midi clock events and inform observers
    /// every 24 pulses (1 quarter note)
    ///
    /// If you wish to observer its events, then add your own MIDIBeatObserver
    ///
    class MIDIClockListener: NSObject {
        /// Definition of 24 quantums per quarter note
        let quantumsPerQuarterNote: MIDIByte
        /// Count of 24 quantums per quarter note
        var quarterNoteQuantumCounter: MIDIByte = 0
        /// number of all time quantum F8 MIDI Clock messages seen
        var quantumCounter: UInt64 = 0
        /// 6 F8 MIDI Clock messages = 1 SPP MIDI Beat
        var sppMIDIBeatCounter: UInt64 = 0
        /// 6 F8 MIDI Clock quantum messages = 1 SPP MIDI Beat
        var sppMIDIBeatQuantumCounter: MIDIByte = 0
        /// 1, 2, 3, 4 , 1, 2, 3, 4 - quarter note counter
        var fourCount: MIDIByte = 0

        private var sendStart = false
        private var sendContinue = false
        private let srtListener: MIDISystemRealTimeListener
        private let tempoListener: MIDITempoListener
        private var observers: [MIDIBeatObserver] = []

        /// MIDIClockListener requires to be an observer of both SRT and BPM events
        /// - Parameters:
        ///   - srt: MIDI System real-time listener
        ///   - count: Quantums per quarter note
        ///   - tempo: Tempo listener
        init(srtListener srt: MIDISystemRealTimeListener,
             quantumsPerQuarterNote count: MIDIByte = 24,
             tempoListener tempo: MIDITempoListener)
        {
            quantumsPerQuarterNote = count
            srtListener = srt
            tempoListener = tempo

            super.init()
            // self is now initialized

            srtListener.addObserver(self)
            tempoListener.addObserver(self)
        }

        deinit {
            srtListener.removeObserver(self)
            tempoListener.removeObserver(self)
            observers = []
        }

        func sppChange(_ positionPointer: UInt16) {
            sppMIDIBeatCounter = UInt64(positionPointer)
            quantumCounter = UInt64(6 * sppMIDIBeatCounter)
            quarterNoteQuantumCounter = MIDIByte(quantumCounter % 24)
        }

        func midiClockBeat(timeStamp: MIDITimeStamp) {
            quantumCounter += 1

            // quarter notes can only increment when we are playing
            guard srtListener.state == .playing else {
                sendQuantumUpdateToObservers(time: timeStamp)
                return
            }

            // increment quantum counter used for counting quarter notes
            quarterNoteQuantumCounter += 1

            // ever first quantum we will count as a quarter note event
            if quarterNoteQuantumCounter == 1 {
                // ever four quarter notes we reset
                if fourCount >= 4 { fourCount = 0 }
                fourCount += 1

                let spaces = "    "
                let prefix = spaces.prefix(Int(fourCount))
                Log("\(prefix) \(fourCount)", log: OSLog.midi)

                if sendStart || sendContinue {
                    sendStartContinueToObservers()
                    sendContinue = false
                    sendStart = false
                }

                sendQuarterNoteMessageToObservers()
            } else if quarterNoteQuantumCounter == quantumsPerQuarterNote {
                quarterNoteQuantumCounter = 0
            }
            sendQuantumUpdateToObservers(time: timeStamp)

            if sppMIDIBeatQuantumCounter == 6 { sppMIDIBeatQuantumCounter = 0; sppMIDIBeatCounter += 1 }
            sppMIDIBeatQuantumCounter += 1
            if sppMIDIBeatQuantumCounter == 1 {
                sendMIDIBeatUpdateToObservers()

                let beat = (sppMIDIBeatCounter % 16) + 1
                Log("       \(beat)", log: OSLog.midi)
            }
        }

        func midiClockStopped() {
            quarterNoteQuantumCounter = 0
            quantumCounter = 0
        }
    }

    // MARK: - Observers

    extension MIDIClockListener {
        /// Add MIDI beat observer
        /// - Parameter observer: MIDI Beat observer to add
        func addObserver(_ observer: MIDIBeatObserver) {
            observers.append(observer)
            Log("[MIDIClockListener:addObserver] (\(observers.count) observers)", log: OSLog.midi)
        }

        /// Remove MIDI beat observer
        /// - Parameter observer: MIDI Beat observer to remove
        func removeObserver(_ observer: MIDIBeatObserver) {
            observers.removeAll { $0 == observer }
            Log("[MIDIClockListener:removeObserver] (\(observers.count) observers)", log: OSLog.midi)
        }

        /// Remove all MIDI Beat observers
        func removeAllObservers() {
            observers.removeAll()
        }
    }

    // MARK: - Beat Observations

    extension MIDIClockListener: MIDIBeatObserver {
        internal func sendMIDIBeatUpdateToObservers() {
            for observer in observers {
                observer.receivedBeatEvent(beat: sppMIDIBeatCounter)
            }
        }

        internal func sendQuantumUpdateToObservers(time: MIDITimeStamp) {
            for observer in observers {
                observer.receivedQuantum(time: time,
                                         quarterNote: fourCount,
                                         beat: sppMIDIBeatCounter,
                                         quantum: quantumCounter)
            }
        }

        internal func sendQuarterNoteMessageToObservers() {
            for observer in observers {
                observer.receivedQuarterNoteBeat(quarterNote: fourCount)
            }
        }

        internal func sendPreparePlayToObservers(continue resume: Bool) {
            for observer in observers {
                observer.preparePlay(continue: resume)
            }
        }

        internal func sendStartContinueToObservers() {
            guard sendContinue || sendStart else { return }
            for observer in observers { observer.startFirstBeat(continue: sendContinue) }
        }

        internal func sendStopToObservers() {
            for observer in observers { observer.stopSRT() }
        }
    }

    // MARK: - MMC Observations interface

    extension MIDIClockListener: MIDITempoObserver {
        /// Resets the quantum counter
        func midiClockFollowerMode() {
            Log("MIDI Clock Follower", log: OSLog.midi)
            quarterNoteQuantumCounter = 0
        }

        /// Resets the quantum counter
        func midiClockLeaderEnabled() {
            Log("MIDI Clock Leader Enabled", log: OSLog.midi)
            quarterNoteQuantumCounter = 0
        }
    }

    extension MIDIClockListener: MIDISystemRealTimeObserver {
        /// Stop MIDI System Real-time listener
        /// - Parameter listener: MIDI System Real-time Listener
        func stopSRT(listener _: MIDISystemRealTimeListener) {
            Log("Beat: [Stop]", log: OSLog.midi)
            sendStopToObservers()
        }

        /// Start MIDI System Real-time listener
        /// - Parameter listener: MIDI System Real-time Listener
        func startSRT(listener _: MIDISystemRealTimeListener) {
            Log("Beat: [Start]", log: OSLog.midi)
            sppMIDIBeatCounter = 0
            quarterNoteQuantumCounter = 0
            fourCount = 0
            sendStart = true
            sendPreparePlayToObservers(continue: false)
        }

        /// Continue MIDI System Real-time listener
        /// - Parameter listener: MIDI System Real-time Listener
        func continueSRT(listener _: MIDISystemRealTimeListener) {
            Log("Beat: [Continue]", log: OSLog.midi)
            sendContinue = true
            sendPreparePlayToObservers(continue: true)
        }
    }

#endif
