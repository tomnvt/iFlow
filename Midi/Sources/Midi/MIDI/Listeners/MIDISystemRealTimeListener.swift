// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
    import CoreMIDI
    import Foundation
    import os.log

    /// This MIDIListener looks for midi system real time (SRT)
    /// midi system messages.
    open class MIDISystemRealTimeListener: NSObject {
        enum SRTEvent: MIDIByte {
            case stop = 0xFC
            case start = 0xFA
            case `continue` = 0xFB
        }

        /// System real-time state
        enum SRTState {
            /// Stopped
            case stopped
            /// Playing
            case playing
            /// Paused
            case paused

            func event(event: SRTEvent) -> SRTState {
                switch self {
                case .stopped:
                    switch event {
                    case .start:
                        return .playing
                    case .stop:
                        return .stopped
                    case .continue:
                        return .playing
                    }
                case .playing:
                    switch event {
                    case .start:
                        return .playing
                    case .stop:
                        return .paused
                    case .continue:
                        return .playing
                    }
                case .paused:
                    switch event {
                    case .start:
                        return .playing
                    case .stop:
                        return .stopped
                    case .continue:
                        return .playing
                    }
                }
            }
        }

        var state: SRTState = .stopped
        var observers: [MIDISystemRealTimeObserver] = []
    }

    extension MIDISystemRealTimeListener: MIDIListener {
        /// Receive a MIDI system command (such as clock, SysEx, etc)
        ///
        /// - data:       Array of integers
        /// - portID:     MIDI Unique Port ID
        /// - offset:     MIDI Event TimeStamp
        ///
        func receivedMIDISystemCommand(
            _ data: [MIDIByte],
            portID _: MIDIUniqueID? = nil,
            timeStamp _: MIDITimeStamp? = nil
        ) {
            if data[0] == MIDISystemCommand.stop.rawValue {
                Log("Incoming MMC [Stop]", log: OSLog.midi)
                let newState = state.event(event: .stop)
                state = newState

                sendStopToObservers()
            }
            if data[0] == MIDISystemCommand.start.rawValue {
                Log("Incoming MMC [Start]", log: OSLog.midi)
                let newState = state.event(event: .start)
                state = newState

                sendStartToObservers()
            }
            if data[0] == MIDISystemCommand.continue.rawValue {
                Log("Incoming MMC [Continue]", log: OSLog.midi)
                let newState = state.event(event: .continue)
                state = newState

                sendContinueToObservers()
            }
        }

        /// Receive the MIDI note on event
        ///
        /// - Parameters:
        ///   - noteNumber: MIDI Note number of activated note
        ///   - velocity:   MIDI Velocity (0-127)
        ///   - channel:    MIDI Channel (1-16)
        ///   - portID:     MIDI Unique Port ID
        ///   - timeStamp:  MIDI Event TimeStamp
        ///
        func receivedMIDINoteOn(noteNumber _: MIDINoteNumber,
                                       velocity _: MIDIVelocity,
                                       channel _: MIDIChannel,
                                       portID _: MIDIUniqueID? = nil,
                                       timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive the MIDI note off event
        ///
        /// - Parameters:
        ///   - noteNumber: MIDI Note number of released note
        ///   - velocity:   MIDI Velocity (0-127) usually speed of release, often 0.
        ///   - channel:    MIDI Channel (1-16)
        ///   - portID:     MIDI Unique Port ID
        ///   - timeStamp:  MIDI Event TimeStamp
        ///
        func receivedMIDINoteOff(noteNumber _: MIDINoteNumber,
                                        velocity _: MIDIVelocity,
                                        channel _: MIDIChannel,
                                        portID _: MIDIUniqueID? = nil,
                                        timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive a generic controller value
        ///
        /// - Parameters:
        ///   - controller: MIDI Controller Number
        ///   - value:      Value of this controller
        ///   - channel:    MIDI Channel (1-16)
        ///   - portID:     MIDI Unique Port ID
        ///   - timeStamp:  MIDI Event TimeStamp
        ///
        func receivedMIDIController(_: MIDIByte,
                                           value _: MIDIByte, channel _: MIDIChannel,
                                           portID _: MIDIUniqueID? = nil,
                                           timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive single note based aftertouch event
        ///
        /// - Parameters:
        ///   - noteNumber: Note number of touched note
        ///   - pressure:   Pressure applied to the note (0-127)
        ///   - channel:    MIDI Channel (1-16)
        ///   - portID:     MIDI Unique Port ID
        ///   - timeStamp:  MIDI Event TimeStamp
        ///
        func receivedMIDIAftertouch(noteNumber _: MIDINoteNumber,
                                           pressure _: MIDIByte,
                                           channel _: MIDIChannel,
                                           portID _: MIDIUniqueID? = nil,
                                           timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive global aftertouch
        ///
        /// - Parameters:
        ///   - pressure: Pressure applied (0-127)
        ///   - channel:  MIDI Channel (1-16)
        ///   - portID:   MIDI Unique Port ID
        ///   - timeStamp:MIDI Event TimeStamp
        ///
        func receivedMIDIAftertouch(_: MIDIByte,
                                           channel _: MIDIChannel,
                                           portID _: MIDIUniqueID? = nil,
                                           timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive pitch wheel value
        ///
        /// - Parameters:
        ///   - pitchWheelValue: MIDI Pitch Wheel Value (0-16383)
        ///   - channel:         MIDI Channel (1-16)
        ///   - portID:          MIDI Unique Port ID
        ///   - timeStamp:       MIDI Event TimeStamp
        ///
        func receivedMIDIPitchWheel(_: MIDIWord,
                                           channel _: MIDIChannel,
                                           portID _: MIDIUniqueID? = nil,
                                           timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// Receive program change
        ///
        /// - Parameters:
        ///   - program:  MIDI Program Value (0-127)
        ///   - channel:  MIDI Channel (1-16)
        ///   - portID:   MIDI Unique Port ID
        ///   - timeStamp:MIDI Event TimeStamp
        ///
        func receivedMIDIProgramChange(_: MIDIByte,
                                              channel _: MIDIChannel,
                                              portID _: MIDIUniqueID? = nil,
                                              timeStamp _: MIDITimeStamp? = nil)
        {
            // Do nothing
        }

        /// MIDI Setup has changed
        func receivedMIDISetupChange() {
            // Do nothing
        }

        /// MIDI Object Property has changed
        func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {
            // Do nothing
        }

        /// Generic MIDI Notification
        func receivedMIDINotification(notification _: MIDINotification) {
            // Do nothing
        }
    }

    extension MIDISystemRealTimeListener {
        /// Add MIDI System real-time observer
        /// - Parameter observer: MIDI System real-time observer
        func addObserver(_ observer: MIDISystemRealTimeObserver) {
            observers.append(observer)
        }

        /// Remove MIDI System real-time observer
        /// - Parameter observer: MIDI System real-time observer
        func removeObserver(_ observer: MIDISystemRealTimeObserver) {
            observers.removeAll { $0 == observer }
        }

        /// Remove all observers
        func removeAllObservers() {
            observers.removeAll()
        }

        /// Send stop command to all observers
        func sendStopToObservers() {
            for observer in observers { observer.stopSRT(listener: self) }
        }

        func sendStartToObservers() {
            for observer in observers { observer.startSRT(listener: self) }
        }

        func sendContinueToObservers() {
            for observer in observers { observer.continueSRT(listener: self) }
        }
    }

#endif
