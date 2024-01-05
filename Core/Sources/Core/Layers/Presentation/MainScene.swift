//
//  File.swift
//
//
//  Created by Tom Novotny on 17.06.2023.
//

import Combine
import Midi
import SwiftUI

import ReplayKit

public struct MainScene: Scene {
    @Environment(\.scenePhase) private var scenePhase

    var midiBus: MIDIBus
    var barCountInteractor: BarCountInteractor
    var midiLoopersViewModel: MidiLoopersViewModel
    var midiLooperActionInteractor: MidiLooperActionInteractor

    public init() {
        createMIDIFile()
        midiBus = MIDIBus()
        barCountInteractor = BarCountInteractor(midiBus: midiBus)
        midiLooperActionInteractor = MidiLooperActionInteractor(midiBus: midiBus)
        midiLoopersViewModel = MidiLoopersViewModel(
            barCountInteractor: barCountInteractor,
            midiLooperActionInteractor: midiLooperActionInteractor,
            midiBus: midiBus
        )
    }

    public var body: some Scene {
        WindowGroup {
            #if os(iOS)
            mainView
                .defersSystemGestures(on: .vertical)
                .statusBar(hidden: true)
                .ignoresSafeArea()
            #else
            ZStack {
                KeystrokeView(midiBus: midiBus)
                mainView
            }
            #endif
        }
    }

    @ViewBuilder
    var mainView: some View {
        let looperMessageInteractor = LooperMessageInteractor(midiBus: midiBus)
        let generalMessageInteractor = GeneralMessageInteractor(midiBus: midiBus)
        MainView(
            loopersViewModel: LoopersViewModel(
                looperMessageInteractor: looperMessageInteractor,
                generalMessageInteractor: generalMessageInteractor,
                midiBus: midiBus
            ),
            fxPanelViewModel: FxPanelViewModel(
                generalMessageInteractor: generalMessageInteractor,
                looperMessageInteractor: looperMessageInteractor
            ),
            bottomPanelViewModel: BottomPanelViewModel(
                looperMessageInteractor: looperMessageInteractor,
                generalMessageInteractor: generalMessageInteractor
            ), barCountInteractor: barCountInteractor,
            midiLoopersViewModel: midiLoopersViewModel,
            midiLooperActionInteractor: midiLooperActionInteractor
        )
        .environmentObject(midiBus)
    }
}

struct WeatherData: Identifiable {
    let index: Int
    var value: Int

    var id: Int { index }
}




import Charts

//struct SimpleLineChartView: View {
//    @EnvironmentObject var midiBus: MIDIBus
//    var segments = 32
//    @State var londonWeatherData: [WeatherData] = []
////    let width: CGFloat = 400 // UIScreen.main.bounds.width
////    let height: CGFloat = 300
//    @State var headPosition: CGFloat = 0
//    @State var index: Int = 0
//    let midiChannel: Int
//    let midiController: Int
//    @State var midiMessagingOn: Bool = true
//
//    var body: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//        ZStack {
//                Chart {
//                    ForEach(londonWeatherData) { item in
//                        LineMark(
//                            x: .value("Month", item.index),
//                            y: .value("Temp", item.value)
//                        )
//                    }
//                }
//                .chartYScale(domain: 0...127)
//                .chartXScale(domain: 0...segments)
//
//                .gesture(DragGesture().onChanged({ drag in
//                    print(drag)
//                    let yPercentage = drag.location.x / proxy.size.width
//                    let xPercentage = drag.location.y / proxy.size.height
//                    //            print(yPercentage)
//                    let index = Int(Double(londonWeatherData.count) * yPercentage)
//                    //            print(index)
//                    let value = abs((1 - xPercentage) * 127)
//                    guard yPercentage >= 0 && yPercentage < 1 && xPercentage >= 0 && xPercentage <= 1 else { return }
//                    londonWeatherData[index].value = Int(value)
//
//                }))
//                .onAppear {
//                    midiBus.onSystemMessageReceive.append({ message in
//                        switch message {
//                        case .clock:
//                            updateClockCount(width: proxy.size.width)
//                        case .stop:
//                            clockCount = 0
//                            currentBar = 0
//                        }
//                    })
//                }
//            }
//
//            Rectangle()
//                .frame(width: 2)
//                .foregroundColor(.gray)
//                .position(x: CGFloat(headPosition), y: proxy.size.height / 2)
//            Text("\(currentBar + 1)")
//            Toggle(isOn: $midiMessagingOn) {
//                Text("On")
//            }
//        }
////        .frame(width: width)
//        .onAppear {
//            londonWeatherData  = (0..<segments).map { WeatherData(index: $0, value: 64) }
//        }
//
//    }
//
//    @State private var clockCount = 0
//    @State private var currentBar = 0
//
//    private func updateClockCount(width: CGFloat) {
////        print(clockCount)
//        let percentage = CGFloat(clockCount) / 95
//        let index = Int(Double(londonWeatherData.count - 1) * percentage)
//        if self.index != index {
//            self.index = index
//            if midiMessagingOn {
//                midiBus.sendEvent(midiAction: .controllerChange, channel: midiChannel, controller: midiController, velocity: londonWeatherData[index].value)
//            }
//        }
//        headPosition = percentage * width
//        if clockCount < 95 {
//            clockCount += 1
//        } else {
//            clockCount = 0
//        }
//        let bar = clockCount / 24
//        if currentBar != bar {
//            currentBar = bar
//        }
//    }
//}

import CoreMIDI
import CoreAudio
import AudioToolbox

func createMIDIFile() {
    var musicSequence: MusicSequence?
    NewMusicSequence(&musicSequence)

    guard let sequence = musicSequence else {
        print("Failed to create MusicSequence.")
        return
    }

    var sequenceTrack: MusicTrack?
    MusicSequenceNewTrack(sequence, &sequenceTrack)

    guard let track = sequenceTrack else {
        print("Failed to create MusicTrack.")
        return
    }

    let chordNotes: [UInt8] = [60, 63, 67, 70] // MIDI note numbers for C, Eb, G, and Bb

    let startTime = MusicTimeStamp(0) // Start time for the chord
    let duration = MusicTimeStamp(8.0) // Duration of the chord in seconds

    for note in chordNotes {
        var noteMessage = MIDINoteMessage(channel: 0,
                                          note: note,
                                          velocity: 64,
                                          releaseVelocity: 0,
                                          duration: Float32(duration))

        MusicTrackNewMIDINoteEvent(track, startTime, &noteMessage)
    }

    for note in chordNotes {
        var noteMessage = MIDINoteMessage(channel: 0,
                                          note: note,
                                          velocity: 64,
                                          releaseVelocity: 0,
                                          duration: Float32(duration))

        MusicTrackNewMIDINoteEvent(track, 9, &noteMessage)
    }

    // Set the sequence to a destination MIDI endpoint
    let destinationEndpoint = MIDIGetDestination(0)
    MusicSequenceSetMIDIEndpoint(sequence, destinationEndpoint)

    // Get the document directory URL
    guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to get document directory URL.")
        return
    }

    // Append the desired file name
    let fileURL = documentDirectoryURL.appendingPathComponent("midiFile.mid")

    // Write the sequence to the file
    var data: Unmanaged<CFData>?
    MusicSequenceFileCreateData(sequence, .midiType, .eraseFile, 480, &data)
    if let cfData = data {
        let dataPtr = CFDataGetBytePtr(cfData.takeUnretainedValue())
        let dataLength = CFDataGetLength(cfData.takeUnretainedValue())
        let fileData = NSData(bytes: dataPtr, length: dataLength)
        fileData.write(to: fileURL, atomically: true)
    }

    // Dispose of the sequence and track
    MusicSequenceDisposeTrack(sequence, track)
    DisposeMusicSequence(sequence)
}
