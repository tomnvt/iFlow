//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Midi
import SwiftUI
import PianoKeyboard

struct Page2: View {
    @EnvironmentObject var loopersViewModel: LoopersViewModel
    @EnvironmentObject var fxPanelViewModel: FxPanelViewModel
    @EnvironmentObject var bottomPanelViewModel: BottomPanelViewModel
    @EnvironmentObject var midiLooperActionInteractor: MidiLooperActionInteractor
    @EnvironmentObject var midiBus: MIDIBus
    @State var selectedBpmButtonIndex = 2
    @State var bpmButtonsLocked = true
    @StateObject var pianoKeyboardViewModel = {
        let viewModel = PianoKeyboardViewModel()
        viewModel.numberOfKeys = 88
        viewModel.noteOffset = 9
        return viewModel
    }()

    var body: some View {
        HStack {
            VStack {
                VStack {
                    PrimaryButton(title: "BPM", interactionStyle: .toggle, midiMessageStyle: .specialAction({
                        bpmButtonsLocked.toggle()
                    }))
                    .frame(height: 20)
                    VStack {
                        makeBpmButton(index: 0)
                        makeBpmButton(index: 1)
                        makeBpmButton(index: 2)
                        makeBpmButton(index: 3)
                        makeBpmButton(index: 4)
                        makeBpmButton(index: 5)
                    }
                    .overlay {
                        Color.black.opacity(bpmButtonsLocked ? 0.5 : 0)
                    }
                }
                .frame(width: 60)
                .padding(.top)
                VStack {
                    PrimaryButton(title: "RESET", interactionStyle: .doubleTap, midiMessageStyle: .specialAction({
                        bottomPanelViewModel.onAction(.resetAll)
                    }))
                    PlayButton(interactor: midiLooperActionInteractor)
                        .frame(height: 40)
                    Knob(
                        title: "CLICK",
                        midiController: Constants.MidiMessages.Automation.click,
                        midiChannel: Constants.MidiChannels.automation,
                        extraMessage: MidiMessage(
                            channel: Constants.MidiChannels.automation,
                            controller: Constants.MidiMessages.Automation.clickToggle,
                            velocity: 127
                        )
                    )
                }
                .frame(width: 60, height: 120)
                FaderSlider(channel: 5, controller: 13)
                    .frame(width: 50)
            }
            InputFxView(layout: .v1, onAction: fxPanelViewModel.onAction)
            VStack {
                Sampler()
                    .frame(height: 100)
                Grid {
                    GridRow {
                        HStack {
                            ArpQuantControl()
                            XYPad2(
                                title: "PERCS\nDRUMS",
                                messages: [
                                    XYPadMessages(midiChannelX: 4, midiControllerX: 8, midiChannelY: 4, midiControllerY: 9),
                                    XYPadMessages(midiChannelX: 4, midiControllerX: 28, midiChannelY: 4, midiControllerY: 29),
                                ]
                            )
                            .frame(width: 100)
                        }
                        HStack {
                            XYPad2(
                                title: "BASS\nPERKS\nDRUMS",
                                messages: [
                                    XYPadMessages(midiChannelX: 4, midiControllerX: 8, midiChannelY: 4, midiControllerY: 9),
                                    XYPadMessages(midiChannelX: 4, midiControllerX: 28, midiChannelY: 4, midiControllerY: 29),
                                    XYPadMessages(midiChannelX: 4, midiControllerX: 48, midiChannelY: 4, midiControllerY: 49),
                                ]
                            )
                            .frame(width: 100)
                            ArpQuantControl2()
                        }
                    }
                    .frame(height: 100)
                    GridRow {
                        makeLooperGroup(index: 2, barAmounts: LooperBarAmount.standard)
                        makeLooperGroup(index: 4, barAmounts: LooperBarAmount.standard)
                    }
                    GridRow {
                        VStack {
                            makeLooperGroup(index: 1, barAmounts: LooperBarAmount.eightLowest, showFxKnobs: false)
                            HStack {
                                makeLooperGroup(index: 0, barAmounts: LooperBarAmount.quaterLowest, showFxKnobs: false)
                                VStack {
                                    PrimaryButton(config:
                                        .init(
                                            title: "4x4\nON",
                                            interactionStyle: .momentary,
                                            midiMessageStyle: .onOffSame(
                                                MidiMessage(channel: Constants.MidiChannels.automation, controller: Constants.MidiMessages.Automation.fourByFourOn)
                                            )
                                        )
                                    )
                                    .frame(width: 50)
                                    PrimaryButton(config:
                                            .init(
                                                title: "4x4\nOFF",
                                                interactionStyle: .momentary,
                                                midiMessageStyle: .onOffSame(
                                                    MidiMessage(channel: Constants.MidiChannels.automation, controller: Constants.MidiMessages.Automation.fourByFourOff)
                                                )
                                            )
                                    )
                                    .frame(width: 50)
                                }
                            }
                        }
                        makeLooperGroup(index: 3, barAmounts: LooperBarAmount.standard)
                    }
                }
                BottomPanel(
                    onAction: bottomPanelViewModel.onAction
                )
            }
            OutputFxView(layout: .v1, onAction: fxPanelViewModel.onAction)
        }
        .onAppear {
            let offset = 21
            midiBus.noteOnEvents = { event in
                DispatchQueue.main.async { [self] in
                    if event.controller - offset >= 0 && event.controller - offset < pianoKeyboardViewModel.keys.count {
                        pianoKeyboardViewModel.keys[event.controller - offset].touchDown = true
                    }

                }
            }
            midiBus.noteOffEvents = {event in
                DispatchQueue.main.async { [self] in
                    if event.controller - offset >= 0 && event.controller - offset < pianoKeyboardViewModel.keys.count {
                        pianoKeyboardViewModel.keys[event.controller - offset].touchDown = false
                    }
                }
            }
        }
    }

    func makeBpmButton(index: Int) -> some View {
        let bpmValues = [92, 110, 128, 140, 160, 174]
        let midiValues = [0, 27, 55, 74, 105, 127]
        return PrimaryButton(
            title: "\(bpmValues[index])",
            isOn: selectedBpmButtonIndex == index,
            interactionStyle: .listToggle,
            midiMessageStyle: .specialAction({
                selectedBpmButtonIndex = index
                bottomPanelViewModel.onAction(
                    .midiMessage(
                        MidiMessage(
                            channel: 7,
                            controller: 56,
                            velocity: midiValues[index]
                        )
                    )
                )
            })
        )
        .frame(height: 20)
    }

    func makeLooperGroup(
        index: Int,
        barAmounts: [LooperBarAmount],
        showFxKnobs: Bool = true
    ) -> some View {
        HStack {
            LooperGroup(
                state: loopersViewModel.looperStates[index],
                onAction: loopersViewModel.onLooperAction,
                barAmounts: barAmounts
            )
            FxPanel(
                layout: .v1,
                fxBaseNote: loopersViewModel.looperStates[index].fxBaseNote,
                index: index,
                title: loopersViewModel.looperStates[index].title,
                showFxKnobs: showFxKnobs
            )
        }
    }
}
