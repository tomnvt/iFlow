//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct Page4: View {
    @EnvironmentObject var loopersViewModel: LoopersViewModel
    @EnvironmentObject var fxPanelViewModel: FxPanelViewModel
    @EnvironmentObject var bottomPanelViewModel: BottomPanelViewModel
    @EnvironmentObject var midiLooperActionInteractor: MidiLooperActionInteractor

    var body: some View {
        HStack {
            Loopers(
                states: loopersViewModel.looperStates,
                indices: [3, 4, 5],
                onLooperAction: loopersViewModel.onLooperAction
            )
            .rightSideContent {
//                Rectangle()
//                    .foregroundColor(GrayScaleColor.backgroundDisabled.color)
//                    .frame(width: 300)
            }
            OutputFxView(layout: .v2, onAction: fxPanelViewModel.onAction)
        }
    }
}
