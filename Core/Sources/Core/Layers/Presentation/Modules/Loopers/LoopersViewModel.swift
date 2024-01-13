//
//  LoopersViewModel.swift
//  LinkHut
//
//  Created by Tom Novotny on 20.02.2023.
//

import Combine
import Midi
import SwiftUI

class LoopersViewModel: ObservableObject {
    @Published private(set) var looperStates: [LooperGroupState] = []
    @Published private(set) var selectedLooperGroupIndex: Int = 0
    @Published var activeActions: [(channel: Int, controller: Int)] = []
    @Published var outputAvailable = false

    private let looperMessageInteractor: LooperMessageInteractor
    private let generalMessageInteractor: GeneralMessageInteractor
    private let midiBus: MIDIBus
    private var cancellables = Set<AnyCancellable>()

    init(
        looperMessageInteractor: LooperMessageInteractor,
        generalMessageInteractor: GeneralMessageInteractor,
        midiBus: MIDIBus
    ) {
        self.looperMessageInteractor = looperMessageInteractor
        self.generalMessageInteractor = generalMessageInteractor
        self.midiBus = midiBus
        observeMessages()
        loadDefaultLooperGroupStates()

        addMidiListener(controller: 36, barAmount: 16, looperGroupIndex: 3, looperIndex: 1, barsIndex: 0)
        addMidiListener(controller: 37, barAmount: 8, looperGroupIndex: 3, looperIndex: 1, barsIndex: 1)
        addMidiListener(controller: 38, barAmount: 4, looperGroupIndex: 3, looperIndex: 1, barsIndex: 2)
        addMidiListener(controller: 39, barAmount: 2, looperGroupIndex: 3, looperIndex: 1, barsIndex: 3)
        addMidiListener(controller: 40, barAmount: 1, looperGroupIndex: 3, looperIndex: 1, barsIndex: 4)
        addMidiListener(controller: 41, barAmount: 16, looperGroupIndex: 3, looperIndex: 0, barsIndex: 0)
        addMidiListener(controller: 42, barAmount: 8, looperGroupIndex: 3, looperIndex: 0, barsIndex: 1)
        addMidiListener(controller: 43, barAmount: 4, looperGroupIndex: 3, looperIndex: 0, barsIndex: 2)
        addMidiListener(controller: 44, barAmount: 2, looperGroupIndex: 3, looperIndex: 0, barsIndex: 3)
        addMidiListener(controller: 45, barAmount: 1, looperGroupIndex: 3, looperIndex: 0, barsIndex: 4)

        addMidiListener(controller: 46, barAmount: 16, looperGroupIndex: 4, looperIndex: 1, barsIndex: 0)
        addMidiListener(controller: 47, barAmount: 8, looperGroupIndex: 4, looperIndex: 1, barsIndex: 1)
        addMidiListener(controller: 48, barAmount: 4, looperGroupIndex: 4, looperIndex: 1, barsIndex: 2)
        addMidiListener(controller: 49, barAmount: 2, looperGroupIndex: 4, looperIndex: 1, barsIndex: 3)
        addMidiListener(controller: 50, barAmount: 1, looperGroupIndex: 4, looperIndex: 1, barsIndex: 4)
        addMidiListener(controller: 51, barAmount: 16, looperGroupIndex: 4, looperIndex: 0, barsIndex: 0)
        addMidiListener(controller: 52, barAmount: 8, looperGroupIndex: 4, looperIndex: 0, barsIndex: 1)
        addMidiListener(controller: 53, barAmount: 4, looperGroupIndex: 4, looperIndex: 0, barsIndex: 2)
        addMidiListener(controller: 54, barAmount: 2, looperGroupIndex: 4, looperIndex: 0, barsIndex: 3)
        addMidiListener(controller: 45, barAmount: 1, looperGroupIndex: 4, looperIndex: 0, barsIndex: 4)
    }

    func addMidiListener(controller: Int, barAmount: Double, looperGroupIndex: Int, looperIndex: Int, barsIndex: Int) {
        midiBus.listeners.append(MidiMessageListener(channel: 1, controller: controller, onMessageReceived: { _ in
            self.onLooperAction(.barAmountChange(self.looperStates[looperGroupIndex].looperStates[looperIndex], barAmount: barAmount, index: barsIndex))
        }))
    }


    func onLooperAction(_ action: LooperGroup.Action) {
        switch action {
        case .clearButtonTap(let looperState):
            onClearButtonTap(state: looperState)
        case .looperActionTap(let looperState, let looperAction):
            onLooperActionTap(state: looperState, action: looperAction)
        case .barAmountChange(let looperState, let barAmout, let index):
            onLooperSegmentChange(state: looperState, barAmount: barAmout, index: index)
        case .looperDrag(let looperGroupState, let value):
            onLooperDrag(looperGroupState: looperGroupState, value: value)
        case .looperBottomDrag(let looperGroupState, let value):
            onLooperBottomDrag(looperGroupState: looperGroupState, value: value)
        }
    }

    private func onLooperSegmentChange(state: LooperState, barAmount: Double, index: Int) {
        looperStates[state.looperGroupIndex].looperStates[state.looperIndex].barAmount = barAmount

        updateLooperState(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex, changes: [
            (\LooperState.loopOn, true),
            (\LooperState.inputOn, false),
        ])

        // TODO: - Deduplicta
        if looperStates[state.looperGroupIndex].masterResampler {
            for looperState in looperStates where looperState.looperGroupIndex != state.looperGroupIndex {
                looperStates[state.looperGroupIndex].looperStates.forEach {
                    onOnButtonTap(state: looperStates[looperState.looperGroupIndex].looperStates[$0.looperIndex], specificState: false)
                }
            }
            looperMessageInteractor.handleMessage(.resetAllFx)

            looperStates[state.looperGroupIndex].looperStates.forEach {
                if $0.looperIndex != state.looperIndex {
                    onOnButtonTap(state: looperStates[state.looperGroupIndex].looperStates[$0.looperIndex], specificState: false)
                } else {
                    onOnButtonTap(state: looperStates[state.looperGroupIndex].looperStates[$0.looperIndex], specificState: true)
                }
            }
        } else if state.isResampling {
            looperStates[state.looperGroupIndex].volume = 127
            looperStates[state.looperGroupIndex].muted = false
            looperStates[state.looperGroupIndex].looperStates.forEach {
                if $0.looperIndex != state.looperIndex {
                    onOnButtonTap(state: looperStates[state.looperGroupIndex].looperStates[$0.looperIndex], specificState: false)
                } else {
                    onOnButtonTap(state: looperStates[state.looperGroupIndex].looperStates[$0.looperIndex], specificState: true)
                }
            }
            looperMessageInteractor.handleMessage(.resetFx(fxBaseNote: looperStates[state.looperGroupIndex].fxBaseNote))
            if let resamplingNotificationName = state.resamplingNotificationName {
                NotificationCenter.default.post(name: resamplingNotificationName, object: nil)
            }
        } else {
            looperStates[state.looperGroupIndex].looperStates.forEach {
                if !$0.isResampling && $0.looperIndex == state.looperIndex {
                    onOnButtonTap(state: looperStates[state.looperGroupIndex].looperStates[$0.looperIndex], specificState: true)
                }
            }
        }

        looperMessageInteractor
            .handleMessage(.barAmountChanged(
                looperGroupIndex: state.looperGroupIndex,
                looperIndex: state.looperIndex,
                index: index,
                isResampling: state.isResampling
            ))
    }

    private func onClearButtonTap(state: LooperState) {
        looperStates[state.looperGroupIndex].looperStates[state.looperIndex].barAmount = nil
        looperStates[state.looperGroupIndex].volume = 127
        updateLooperState(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex, changes: [
            (\LooperState.inputOn, true),
            (\LooperState.loopOn, false),
            (\LooperState.onOn, true),
        ])

        looperMessageInteractor
            .handleMessage(.clear(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex))
    }

    private func updateLooperState(trackBaseNote: Int, channel: Int, changes: [(WritableKeyPath<LooperState, Bool>, Bool)]) {
        guard let looperGroupIndex = looperStates
            .firstIndex(where: {
                [$0.baseNote, $0.baseNote + 10, $0.baseNote + 20, $0.baseNote + 30]
                    .contains(trackBaseNote) && channel == channel
            })
        else { return }
        let baseNote = looperStates[looperGroupIndex].baseNote
        guard let looperIndex = [baseNote, baseNote + 10, baseNote + 20, baseNote + 30].firstIndex(of: trackBaseNote)
        else { return }
        updateLooperState(looperGroupIndex: looperGroupIndex, looperIndex: looperIndex, changes: changes)
    }

    private func updateLooperState(
        looperGroupIndex: Int,
        looperIndex: Int,
        changes: [(WritableKeyPath<LooperState, Bool>, Bool)]
    ) {
        for (keyPath, value) in changes {
            looperStates[looperGroupIndex].looperStates[looperIndex][keyPath: keyPath] = value
        }
    }

    private func onLooperActionTap(state: LooperState, action: LooperAction) {
        switch action {
        case .loop:
            onLoopButtonTap(state: state)
        case .input:
            onInputButtonTap(state: state)
        case .solo:
            onSoloButtonTap(state: state)
        case .on:
            onOnButtonTap(state: state)
        }
    }

    private func onLoopButtonTap(state: LooperState) {
        looperStates[state.looperGroupIndex].looperStates[state.looperIndex].loopOn.toggle()
        let loopIsOn = looperStates[state.looperGroupIndex].looperStates[state.looperIndex].loopOn
        looperMessageInteractor
            .handleMessage(.loopOn(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex,
                                   isOn: loopIsOn))
    }

    private func onInputButtonTap(state: LooperState) {
        looperStates[state.looperGroupIndex].looperStates[state.looperIndex].inputOn.toggle()
        let inputIsOn = looperStates[state.looperGroupIndex].looperStates[state.looperIndex].inputOn
        looperMessageInteractor
            .handleMessage(.inputOn(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex,
                                    isOn: inputIsOn))
    }

    private func onSoloButtonTap(state: LooperState) {
        let currentTargetChannelSoloState = looperStates[state.looperGroupIndex].looperStates[state.looperIndex].soloOn
        for (index, _) in looperStates.enumerated() {
            looperStates[index].looperStates[0].soloOn = false
            looperStates[index].looperStates[1].soloOn = false
            looperStates[index].looperStates[2].soloOn = false
            looperStates[index].looperStates[3].soloOn = false
        }
        looperStates[state.looperGroupIndex].looperStates[state.looperIndex].soloOn = !currentTargetChannelSoloState
        let soloIsOn = looperStates[state.looperGroupIndex].looperStates[state.looperIndex].soloOn
        looperMessageInteractor
            .handleMessage(.soloOn(looperGroupIndex: state.looperGroupIndex, looperIndex: state.looperIndex,
                                   isOn: soloIsOn))
    }

    private func onOnButtonTap(state: LooperState, specificState: Bool? = nil) {
        if let specificState {
            looperStates[state.looperGroupIndex].looperStates[state.looperIndex].onOn = specificState
        } else {
            looperStates[state.looperGroupIndex].looperStates[state.looperIndex].onOn.toggle()
        }
        let looperIsOn = looperStates[state.looperGroupIndex].looperStates[state.looperIndex].onOn
        looperMessageInteractor
            .handleMessage(
                .looperOn(
                    looperGroupIndex: state.looperGroupIndex,
                    looperIndex: state.looperIndex,
                    isOn: looperIsOn
                )
            )
    }

    private func observeMessages() {
        generalMessageInteractor.observeMessages(onReceived: { [weak self] generalMessage in
            DispatchQueue.main.async {
                if generalMessage.midiValues.velocity == 127 {
                    self?.activeActions
                        .append((generalMessage.midiValues.channel, generalMessage.midiValues.controller))
                } else {
                    self?.activeActions
                        .removeAll(where: {
                            $0.channel == generalMessage.midiValues.channel && $0.controller == generalMessage
                                .midiValues
                                .controller
                        })
                }
            }
        })

        NotificationCenter.default.publisher(for: .resetAll)
            .sink(receiveValue: { [weak self] _ in
                self?.loadDefaultLooperGroupStates()
                Constants.MidiMessages.onResetAll.forEach { message in
                    self?.midiBus.sendEvent(message: message)
                }
            })
            .store(in: &cancellables)
    }

    private func onLooperDrag(looperGroupState: LooperGroupState, value: Double) {
        let velocity = Int(127 * value)
        looperStates[looperGroupState.looperGroupIndex].volume = velocity
        let controller = 17 + looperGroupState.looperGroupIndex
        generalMessageInteractor
            .handleMessage(.general(channel: 7, controller: controller, velocity: velocity))
    }

    private func onLooperBottomDrag(looperGroupState: LooperGroupState, value: Double) {
        if value < 0 && Double(looperStates[looperGroupState.looperGroupIndex].volume / 127) < 0.5 && looperStates[looperGroupState.looperGroupIndex].muted {
            looperGroupState.looperStates.forEach { state in
                onClearButtonTap(state: state)
            }
            looperStates[looperGroupState.looperGroupIndex].muted = false
            looperStates[looperGroupState.looperGroupIndex].volume = 127
            looperMessageInteractor.handleMessage(.resetFx(fxBaseNote: looperGroupState.fxBaseNote))
            let controller = 17 + looperGroupState.looperGroupIndex
            generalMessageInteractor
                .handleMessage(.general(channel: 7, controller: controller, velocity: 127))
        } else if value < 0 && Double(looperStates[looperGroupState.looperGroupIndex].volume / 127) < 0.5 && !looperStates[looperGroupState.looperGroupIndex].muted {
            looperStates[looperGroupState.looperGroupIndex].muted = true
        } else {
            looperStates[looperGroupState.looperGroupIndex].muted = false
        }
    }

    private func loadDefaultLooperGroupStates() {
        looperStates = LooperGroupState.defaultStates
        looperMessageInteractor.handleMessage(.resetAllFx)
        looperStates.forEach {
            looperMessageInteractor.handleMessage(.clear(looperGroupIndex: $0.looperGroupIndex, looperIndex: 0))
            looperMessageInteractor.handleMessage(.clear(looperGroupIndex: $0.looperGroupIndex, looperIndex: 1))
            looperMessageInteractor.handleMessage(.clear(looperGroupIndex: $0.looperGroupIndex, looperIndex: 2))
            looperMessageInteractor.handleMessage(.clear(looperGroupIndex: $0.looperGroupIndex, looperIndex: 3))
            onLooperDrag(looperGroupState: $0, value: 1)
        }
    }
}
