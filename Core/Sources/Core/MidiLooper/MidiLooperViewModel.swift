//
//  File.swift
//  
//
//  Created by Tom Novotny on 16.07.2023.
//

import Combine
import Foundation
import Midi
import PianoRoll

class MidiLooperViewModel: ObservableObject {
    @Published var pianoRollModel = PianoRollModel(notes: [], length: 256, height: 51, range: 35..<51)
    @Published var quantizationOption: QuantizationOption?
    @Published var quantizationOptionIndex: Int = 0 {
        didSet {
            if quantizationOptionIndex > 0 {
                quantizationOption = QuantizationOption.allCases[quantizationOptionIndex - 1]
            } else {
                quantizationOption = nil
            }
        }
    }
    @Published var selectedNotes: [PianoRollNote] = [] {
        didSet {
            if selectedNotes.isEmpty {
                enabledNoteActions.remove(.delete)
                enabledNoteActions.remove(.mute)
            } else {
                enabledNoteActions.insert(.delete)
                enabledNoteActions.insert(.mute)
            }
        }
    }
    @Published var isPlaying: Bool = false
    @Published var isArmed: Bool = false {
        didSet {
            midiBus.onMessageReceivedWithVelocity = { [weak self] noteMessage in
                self?.processIncomingNote(noteMessage)
            }
        }
    }
    @Published var clickIsOn: Bool = false
    @Published var enabledNoteActions: Set<MidiLooperNoteAction> = Set([.muteAll, .unmuteAll])
    @Published var undoActionsAvailable: Bool = false
    @Published var redoActionsAvailable: Bool = false
    @Published var gridDensityIndex = 3 { didSet { gridDensityDivider = QuantizationOption.allCases[gridDensityIndex].gridDensityDivider } }
    @Published var gridDensityDivider = 16
    private var notesBuffer: [PianoRollNote] = []
    private var playingNotes: [PianoRollNote] = []
    private var cancellables = Set<AnyCancellable>()
    private var actionHistory: [MidiLooperNoteActionModel] = [] {
        didSet { DispatchQueue.main.async { [unowned self] in self.undoActionsAvailable = !actionHistory.isEmpty } }
    }
    private var undoHistory: [MidiLooperNoteActionModel] = [] {
        didSet { DispatchQueue.main.async { [unowned self] in self.redoActionsAvailable = !undoHistory.isEmpty } }
    }
    @Published var bars = 2 {
        didSet {
            let newLoopLenght = bars * 128
            pianoRollModel.length = newLoopLenght
        }
    }
    private var playheadPosition = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.playheadPercentage = CGFloat(self.playheadPosition) / CGFloat(self.pianoRollModel.length)
            }
        }
    }
    private var currentBar = 0
    @Published var playheadPercentage: CGFloat = 0

    private let barCountInteractor: BarCountInteractor
    private let midiBus: MIDIBus
    private let midiLooperActionInteractor: MidiLooperActionInteractor
    private let channel: Int

    init(
        barCountInteractor: BarCountInteractor,
        midiBus: MIDIBus,
        midiLooperActionInteractor: MidiLooperActionInteractor,
        channel: Int
    ) {
        self.barCountInteractor = barCountInteractor
        self.midiBus = midiBus
        self.midiLooperActionInteractor = midiLooperActionInteractor
        self.channel = channel
        observeIncomingNotes()

        NotificationCenter.default.publisher(for: .deletePressed)
            .sink(receiveValue: { [weak self] _ in self?.onDelete() })
            .store(in: &cancellables)
    }

    private func observeIncomingNotes() {
        barCountInteractor.observeCurrentBar(
            onClockChange: { [weak self] clockPosition in
                self?.onClockPositionChange(clockPosition)
            },
            onStopEvent: { [weak self] in
                self?.currentBar = 0
                self?.playheadPosition = 0
            }
        )
    }

    private func processIncomingNote(_ noteMessage: NoteMessage) {
        if isPlaying && isArmed {
            if noteMessage.noteOn {
                updateNoteBuffer(noteMessage)
            } else {
                recordFinishedNote(noteMessage)
            }
        }
    }

    private func updateNoteBuffer(_ noteMessage: NoteMessage) {
        let note = PianoRollNote(start: Double(playheadPosition), length: 0, pitch: noteMessage.pitch, velocity: noteMessage.velocity)
        notesBuffer.append(note)
    }

    private func recordFinishedNote(_ noteMessage: NoteMessage) {
        if let matchingNote = notesBuffer.first(where: { note in note.pitch == noteMessage.pitch }) {
            let duration =  Double(playheadPosition) - matchingNote.start
            let completeNote = PianoRollNote(start: matchingNote.start , length: duration, pitch: matchingNote.pitch,velocity: matchingNote.velocity)
            notesBuffer.removeAll(where: { $0.pitch == noteMessage.pitch })
            onNoteCreated(completeNote)
        }
    }

    private func onClockPositionChange(_ clockPosition: Int) {
        playheadPosition = clockPosition + (currentBar * 128)
        if clockPosition == 127 {
            if currentBar == bars - 1 {
                currentBar = 0
            } else {
                currentBar += 1
            }
        }
        sendNoteOnEvents(clockPosition: playheadPosition)
        sendNoteOffEvents(clockPosition: playheadPosition)
    }

    private func sendNoteOnEvents(clockPosition: Int) {
        pianoRollModel.notes.filter({
            Int($0.start)  == clockPosition && !$0.muted
        }).forEach { note in
            let pitch = note.pitch
            midiBus.sendEvent(midiAction: .noteOn, channel: channel, controller: Int(pitch), velocity: note.velocity)
            playingNotes.append(note)
            print("[LOOPER] \(pitch) velocity: \(note.velocity) at clock \(clockPosition)")
        }
    }

    private func sendNoteOffEvents(clockPosition: Int) {
        pianoRollModel.notes.filter({ clockPosition >= Int($0.start) + Int($0.length) && playingNotes.contains($0) })
            .forEach { note in
                let pitch = note.pitch
                midiBus.sendEvent(midiAction: .noteOff, channel: channel, controller: Int(pitch), velocity: 0)
                playingNotes.removeAll(where: { $0.id == note.id })
                print("[LOOPER] Stoped \(pitch) velocity: \(0) at clock \(clockPosition)")
            }
    }
}

// MARK: - Interaction handling
extension MidiLooperViewModel {
    func onNoteCreated(_ note: PianoRollNote) {
        var noteCopy = note
        if let quantizationOption {
            let start = Double(QuantizationHelper.quantize(noteStart: Int(note.start), quantizationOption: quantizationOption, barCount: bars))
            noteCopy.start = Double(start)
        }
        DispatchQueue.main.async { [weak self] in
            self?.pianoRollModel.notes.append(noteCopy)
        }
        actionHistory.append(.init(action: .add, notes: [noteCopy]))
        undoHistory = []
    }

    func onNoteAction(_ action: MidiLooperNoteAction) {
        switch action {
        case .add:
            ()
        case .delete:
            onDelete()
        case .muteAll:
            onMuteAllButtonTap(recordToHistory: true)
        case .mute, .unmute:
            onMuteButtonTap()
        case .unmuteAll:
            onUnmuteAllButtonTap(recordToHistory: true)
        }
        undoHistory = []
        selectedNotes = []
    }

    func onNoteActionLongPress(_ action: MidiLooperNoteAction) {
        switch action {
        case .delete:
            // TODO: - Consider solving the double source of thruth about selected notes (in this scope and in the pianoRollModel.notes)
            pianoRollModel.notes.enumerated().forEach { (index, _) in
                pianoRollModel.notes[index].selected = true
            }
            onDelete()
        default: ()
        }
    }

    private func onDelete() {
        actionHistory.append(.init(action: .delete, notes: pianoRollModel.notes.filter(\.selected)))
        pianoRollModel.notes.removeAll(where: { $0.selected })
    }

    private func onMuteAllButtonTap(recordToHistory: Bool) {
        guard pianoRollModel.notes.contains(where: { !$0.muted }) else { return }
        pianoRollModel.notes.enumerated().forEach { index, note in
            pianoRollModel.notes[index].muted = true
        }
        if recordToHistory {
            actionHistory.append(MidiLooperNoteActionModel(action: .muteAll))
        }
    }

    private func onMuteButtonTap() {
        var selectedNotes = pianoRollModel.notes.filter { $0.selected }
        let shouldMute = !selectedNotes.allSatisfy { $0.muted }
        if shouldMute {
            selectedNotes = selectedNotes.filter { !$0.muted }
            actionHistory.append(MidiLooperNoteActionModel(action: .mute, notes: selectedNotes))
        } else {
            actionHistory.append(MidiLooperNoteActionModel(action: .unmute, notes: selectedNotes))
        }
        selectedNotes
            .forEach { note in
                if let index = pianoRollModel.notes.firstIndex(where: { $0.id == note.id }) {
                    pianoRollModel.notes[index].muted = shouldMute
                }
            }
    }

    private func onUnmuteAllButtonTap(recordToHistory: Bool) {
        guard pianoRollModel.notes.contains(where: { $0.muted }) else { return }
        pianoRollModel.notes.enumerated().forEach { index, note in
            pianoRollModel.notes[index].muted = false
        }
        if recordToHistory {
            actionHistory.append(MidiLooperNoteActionModel(action: .unmuteAll))
        }
    }

    func onUndoButtonTap() {
        guard let lastAction = actionHistory.popLast() else { return }
        switch lastAction.action {
        case .add:
            pianoRollModel.notes.removeAll(where: { lastAction.notes.map(\.id).contains($0.id) })
        case .delete:
            pianoRollModel.notes += lastAction.notes
        case .muteAll:
            onUnmuteAllButtonTap(recordToHistory: false)
        case .mute:
            let indices = lastAction.notes.compactMap { note in pianoRollModel.notes.firstIndex(where: { $0.id == note.id }) }
            for index in indices {
                pianoRollModel.notes[index].muted = false
            }
        case .unmute:
            let indices = lastAction.notes.compactMap { note in pianoRollModel.notes.firstIndex(where: { $0.id == note.id }) }
            for index in indices {
                pianoRollModel.notes[index].muted = true
            }
        case .unmuteAll:
            onMuteAllButtonTap(recordToHistory: false)
        }
        selectedNotes = lastAction.notes
        undoHistory.append(lastAction)
    }

    func onRedoButtonTap() {
        guard let lastUndoneAction = undoHistory.popLast() else { return }
        switch lastUndoneAction.action {
        case .add:
            pianoRollModel.notes += lastUndoneAction.notes
        case .delete:
            pianoRollModel.notes.removeAll(where: { lastUndoneAction.notes.contains($0) })
        case .muteAll:
            onMuteAllButtonTap(recordToHistory: true)
        case .mute:
            let indices = lastUndoneAction.notes.compactMap { note in pianoRollModel.notes.firstIndex(where: { $0.id == note.id }) }
            for index in indices {
                pianoRollModel.notes[index].muted = true
            }
        case .unmute:
            let indices = lastUndoneAction.notes.compactMap { note in pianoRollModel.notes.firstIndex(where: { $0.id == note.id }) }
            for index in indices {
                pianoRollModel.notes[index].muted = false
            }
        case .unmuteAll:
            onUnmuteAllButtonTap(recordToHistory: true)
        }
        selectedNotes = lastUndoneAction.notes
        actionHistory.append(lastUndoneAction)
    }

    func onDivideLoopButtonTap() {
        guard bars > 1 else { return }
        bars /= 2
    }

    func onMultiplyLoopButtonTap() {
        bars *= 2
    }
}
