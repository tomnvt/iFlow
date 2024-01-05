//
//  MainView.swift
//  LinkHut
//
//  Created by Tom Novotny on 19.02.2023.
//

import Midi
import SwiftUI

struct MainView: View {
    @State private var page: Int = 0

    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var loopersViewModel: LoopersViewModel
    @ObservedObject var fxPanelViewModel: FxPanelViewModel
    @ObservedObject var bottomPanelViewModel: BottomPanelViewModel
    #if os(iOS)
    @State var pageOpacities: [CGFloat] = [0, 1, 0, 0]
    #else
    @State var pageOpacities: [CGFloat] = [0, 1, 0, 0]
    #endif
    @State var shownPageIndex: Int = 0
    @State private var showAlert = false
    @State var pageIndex = 0

    let barCountInteractor: BarCountInteractor
    let midiLoopersViewModel: MidiLoopersViewModel
    let midiLooperActionInteractor: MidiLooperActionInteractor

    var outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("screen", conformingTo: .data)

    init(
        loopersViewModel: LoopersViewModel,
        fxPanelViewModel: FxPanelViewModel,
        bottomPanelViewModel: BottomPanelViewModel,
        barCountInteractor: BarCountInteractor,
        midiLoopersViewModel: MidiLoopersViewModel,
        midiLooperActionInteractor: MidiLooperActionInteractor
    ) {
        self.loopersViewModel = loopersViewModel
        self.fxPanelViewModel = fxPanelViewModel
        self.bottomPanelViewModel = bottomPanelViewModel
        self.barCountInteractor = barCountInteractor
        self.midiLoopersViewModel = midiLoopersViewModel
        self.midiLooperActionInteractor = midiLooperActionInteractor
    }

    var body: some View {
        VStack {
            if loopersViewModel.outputAvailable {
                ShareLink(item: outputURL)
            }
            ZStack {
                switch pageIndex {
                case 0:
                    ShareLink(item: outputURL)
                case 1:
                    Page2()
                case 2:
                    Page3()
                case 3:
                    Page4()
                default:
                    Text("")
                }
            }

            HStack {
                BarCountView(
                    viewModel: BarCountViewModel(
                        barCountInteractor: barCountInteractor
                    ),
                    onBarViewTap: {
                        shownPageIndex = $0
                    }
                )
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .onChange(of: shownPageIndex, perform: { shownPageIndex in
            setPage(page: shownPageIndex)
            UserDefaults.standard.setValue(shownPageIndex, forKey: "page")
        })
        .animation(.linear(duration: 0.1), value: pageOpacities)
        .onAppear {
            page = UserDefaults.standard.integer(forKey: "page")
            setPage(page: page)
        }
        .environmentObject(loopersViewModel)
        .environmentObject(fxPanelViewModel)
        .environmentObject(bottomPanelViewModel)
        .environmentObject(midiLoopersViewModel)
        .environmentObject(midiLooperActionInteractor)
    }

    func setPage(page: Int) {
        self.pageIndex = page
    }
}
