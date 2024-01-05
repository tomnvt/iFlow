//
//  LooperGroupState.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

struct FxState {
    var automationOn = false
    var recordingOn = false
    var barCount = 2
    var holding = false
}

struct LooperGroupState {
    let title: String
    let looperGroupIndex: Int
    let baseNote: Int
    let channel: Int
    var looperStates: [LooperState]
    let fxBaseNote: Int
    let barAmounts: [LooperBarAmount]
    let masterResampler: Bool
    var volume: Int
    var muted: Bool
    var fxState: FxState

    init(
        title: String,
        looperGroupIndex: Int,
        baseNote: Int,
        channel: Int,
        fxBaseNote: Int,
        barAmounts: [LooperBarAmount],
        resamplingTracksCount: Int,
        trackNames: [String],
        masterResampler: Bool = false,
        volume: Int = 127,
        muted: Bool = false,
        fxState: FxState = FxState()
    ) {
        self.title = title
        self.looperGroupIndex = looperGroupIndex
        self.baseNote = baseNote
        self.channel = channel
        looperStates = trackNames.enumerated().map { index, trackName in
            Self.makeLooperState(
                looperGroupIndex: looperGroupIndex,
                looperIndex: index,
                baseNote: baseNote,
                channel: channel,
                isResampling: (0 ..< resamplingTracksCount + 1).contains(4 - index),
                trackName: trackName
            )
        }
        self.fxBaseNote = fxBaseNote
        self.barAmounts = barAmounts
        self.masterResampler = masterResampler
        self.volume = volume
        self.muted = muted
        self.fxState = fxState
    }

    private static func makeLooperState(
        looperGroupIndex: Int,
        looperIndex: Int,
        baseNote: Int,
        channel: Int,
        isResampling: Bool,
        trackName: String
    ) -> LooperState {
        .default(
            looperGroupIndex: looperGroupIndex,
            looperIndex: looperIndex,
            baseNote: baseNote + looperIndex * 10,
            channel: channel,
            isResampling: isResampling,
            trackName: trackName
        )
    }
}

extension LooperGroupState {
    static var defaultStates: [LooperGroupState] {
        [
            LooperGroupState(
                title: "KICK\n&\nSNARE",
                looperGroupIndex: 0,
                baseNote: 0,
                channel: Constants.MidiChannels.firstLooperTriplet,
                fxBaseNote: 0,
                barAmounts: LooperBarAmount.quaterLowest,
                resamplingTracksCount: 0,
                trackNames: [
                    "KICK",
                    "SNARE",
                ]
            ),
            LooperGroupState(
                title: "HATS\n&\nSTUFF",
                looperGroupIndex: 1,
                baseNote: 40,
                channel: Constants.MidiChannels.firstLooperTriplet,
                fxBaseNote: 20,
                barAmounts: LooperBarAmount.eightLowest,
                resamplingTracksCount: 0,
                trackNames: [
                    "HIHAT",
                    "GROOVE",
                ]
            ),
            LooperGroupState(
                title: "BASS",
                looperGroupIndex: 2,
                baseNote: 80,
                channel: Constants.MidiChannels.firstLooperTriplet,
                fxBaseNote: 40,
                barAmounts: LooperBarAmount.standard,
                resamplingTracksCount: 2,
                trackNames: [
                    "GUITAR",
                    "SYNTH",
                    "RSMPL",
                    "RSMPL",
                ]
            ),
            LooperGroupState(
                title: "HARMONY",
                looperGroupIndex: 3,
                baseNote: 0,
                channel: Constants.MidiChannels.secondLooperTriplet,
                fxBaseNote: 60,
                barAmounts: LooperBarAmount.standard,
                resamplingTracksCount: 2,
                trackNames: [
                    "LAYER 1",
                    "LAYER 2",
                    "RSMPL",
                    "RSMPL",
                ]
            ),
            LooperGroupState(
                title: "MELODY",
                looperGroupIndex: 4,
                baseNote: 40,
                channel: Constants.MidiChannels.secondLooperTriplet,
                fxBaseNote: 80,
                barAmounts: LooperBarAmount.standard,
                resamplingTracksCount: 2,
                trackNames: [
                    "PLUCK",
                    "LINE",
                    "RSMPL",
                    "RSMPL",
                ]
            ),
            LooperGroupState(
                title: "RESAMPLE",
                looperGroupIndex: 5,
                baseNote: 80,
                channel: Constants.MidiChannels.secondLooperTriplet,
                fxBaseNote: 100,
                barAmounts: LooperBarAmount.standard,
                resamplingTracksCount: 4,
                trackNames: [
                    "DRUMS",
                    "MELOD",
                    "MEL+BASS",
                    "ALL",
                ],
                masterResampler: true
            ),
        ]
    }
}
