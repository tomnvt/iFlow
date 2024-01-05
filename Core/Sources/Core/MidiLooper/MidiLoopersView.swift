//
//  File 2.swift
//  
//
//  Created by Tom Novotny on 01.08.2023.
//

import Combine
import SwiftUI
import Midi

class MidiLoopersViewModel: ObservableObject {
    @Published var clickIsOn: Bool = false
    @Published var isPlaying: Bool = false {
        didSet {
            looperViewModels[currentlySelectedLooperIndex].isPlaying = isPlaying
        }
    }
    @Published var isArmed: Bool = false {
        didSet {
            looperViewModels[currentlySelectedLooperIndex].isArmed = isArmed
        }
    }
    @Published var currentlySelectedLooperIndex = 0
    let looperViewModels: [MidiLooperViewModel]

    private var cancellables = Set<AnyCancellable>()

    private let barCountInteractor: BarCountInteractor
    private let midiLooperActionInteractor: MidiLooperActionInteractor
    private let midiBus: MIDIBus

    init(
        barCountInteractor: BarCountInteractor,
        midiLooperActionInteractor: MidiLooperActionInteractor,
        midiBus: MIDIBus
    ) {
        self.barCountInteractor = barCountInteractor
        self.midiLooperActionInteractor = midiLooperActionInteractor
        self.midiBus = midiBus

        self.looperViewModels = [
            MidiLooperViewModel(
                barCountInteractor: barCountInteractor,
                midiBus: midiBus,
                midiLooperActionInteractor: midiLooperActionInteractor,
                channel: 2
            ),
            MidiLooperViewModel(
                barCountInteractor: barCountInteractor,
                midiBus: midiBus,
                midiLooperActionInteractor: midiLooperActionInteractor,
                channel: 3
            ),
        ]

        NotificationCenter.default.publisher(for: .spacebarPresed)
            .sink(receiveValue: { [weak self] _ in self?.onPlayStopButtonTap() })
            .store(in: &cancellables)
    }

    func onPlayStopButtonTap() {
        isPlaying.toggle()

        if isPlaying {
            midiLooperActionInteractor.handleAction(.play)
        } else {
            midiLooperActionInteractor.handleAction(.stop)
        }
    }

    func onClickButtonTap() {
        clickIsOn.toggle()
        if clickIsOn {
            midiLooperActionInteractor.handleAction(.clickOn)
        } else {
            midiLooperActionInteractor.handleAction(.clickOff)
        }
    }

    func onArmRecordingButtonTap() {
        isArmed.toggle()
        midiLooperActionInteractor.handleAction(.arm(on: isArmed, channel: currentlySelectedLooperIndex))
    }

    func onLooperButtonTap(index: Int) {
        looperViewModels[currentlySelectedLooperIndex].isArmed = false
        currentlySelectedLooperIndex = index
        looperViewModels[currentlySelectedLooperIndex].isArmed = isArmed
        midiLooperActionInteractor.handleAction(.arm(on: isArmed, channel: currentlySelectedLooperIndex))
        looperViewModels[currentlySelectedLooperIndex].isPlaying = isPlaying
    }

    func onDisappear() {
        isArmed = false
    }
}

struct MidiLoopersView: View {
    @ObservedObject var viewModel: MidiLoopersViewModel
    @State var firstPageOpacity: CGFloat = 1
    @State var secondPageOpacity: CGFloat = 0

    init(viewModel: MidiLoopersViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ZStack {
                MidiLooperView(viewModel: viewModel.looperViewModels[0])
                    .opacity(viewModel.currentlySelectedLooperIndex == 0 ? 1 : 0)
                MidiLooperView(viewModel: viewModel.looperViewModels[1])
                    .opacity(viewModel.currentlySelectedLooperIndex == 1 ? 1 : 0)
            }

            HStack {
                MidiLooperButton(title: "Drums", onTap: {
                    viewModel.onLooperButtonTap(index: 0)
                })
                MidiLooperButton(title: "Percs", onTap: {
                    viewModel.onLooperButtonTap(index: 1)
                })
                MidiLooperButton(state: viewModel.clickIsOn ? .active : .enabled, systemImageName: viewModel.clickIsOn ? .metronomeFilled : .metronome, onTap: {
                    viewModel.onClickButtonTap()
                })
                MidiLooperButton(state: viewModel.isPlaying ? .active : .enabled, systemImageName: viewModel.isPlaying ? .stop : .play, onTap: {
                    viewModel.onPlayStopButtonTap()
                })
                MidiLooperButton(state: viewModel.isArmed ? .active : .enabled, systemImageName: .notes, onTap: {
                    viewModel.onArmRecordingButtonTap()
                })
                MidiLooperButton(state: viewModel.isArmed ? .active : .enabled, systemImageName: viewModel.isPlaying ? .recordFill : .recordFill, onTap: {
                    viewModel.onArmRecordingButtonTap()
                })
            }
            .frame(height: 60)
        }
        .padding(.horizontal)
        .onDisappear(perform: viewModel.onDisappear)
    }
}
