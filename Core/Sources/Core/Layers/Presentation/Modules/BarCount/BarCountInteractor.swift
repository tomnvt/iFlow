//
//  BarCountInteractor.swift
//  iFlow
//
//  Created by Tom Novotny on 07.06.2023.
//

import Midi

class BarCountInteractor {
    private(set) var clockCount = 0
    private(set) var currentBeat = 0
    private(set) var currentBar = 0

    private var midiBus: MIDIBus
    private var connected = false

    init(midiBus: MIDIBus) {
        self.midiBus = midiBus
    }

    var onBeatChangedClosures: [(Int) -> Void] = []
    var onClockChangeClosures: [((Int) -> Void)] = []
    var onBarChangeClosures: [((Int) -> Void)] = []
    var onStopEventClosures: [(() -> Void)] = []

    func observeCurrentBar(
        onBeatChanged: ((Int) -> Void)? = nil,
        onClockChange: ((Int) -> Void)? = nil,
        onBarChange: ((Int) -> Void)? = nil,
        onStopEvent: (() -> Void)? = nil
    ) {
        if let onBeatChanged {
            onBeatChangedClosures.append(onBeatChanged)
        }
        if let onClockChange {
            onClockChangeClosures.append(onClockChange)
        }
        if let onBarChange {
            onBarChangeClosures.append(onBarChange)
        }
        if let onStopEvent {
            onStopEventClosures.append(onStopEvent)
        }
        guard !connected else { return }
        midiBus.onSystemMessageReceive = { [weak self] message in
            switch message {
            case .clock:
                ()
            case .stop:
                self?.clockCount = 0
                self?.currentBeat = 0
                self?.currentBar = 0
                self?.onBeatChangedClosures.forEach { $0(0) }
                self?.onBarChangeClosures.forEach { $0(0) }
                self?.onClockChangeClosures.forEach { $0(0) }
                self?.onStopEventClosures.forEach { $0() }
            }
        }
        midiBus.listeners.append(
            MidiMessageListener(
                channel: Constants.MidiChannels.automation,
                controller: Constants.MidiMessages.Automation.clockClip,
                onMessageReceived: {
                    [weak self] clock in
                    guard let self else { return }
                    guard self.clockCount != clock else { return }
                    self.clockCount = clock
                    self.updateClockCount()
                }
            )
        )
        connected = true
    }

    private func updateClockCount() {
        onClockChangeClosures.forEach { $0(clockCount) }
        if clockCount == 127 {
            increaseBarCount()
            onBarChangeClosures.forEach { $0(currentBar) }
        }
        print("CLOCK \(clockCount)")
        let beat = clockCount / 32
        if currentBeat != beat {
            print("CLOCK NEAT \(currentBeat)")
            currentBeat = beat
            onBeatChangedClosures.forEach { $0(currentBeat) }
        }
    }

    private func increaseBarCount() {
        if currentBar < 3 {
            currentBar += 1
        } else {
            currentBar = 0
        }
        print("[BAR] \(currentBar)")
    }
}
