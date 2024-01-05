//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct Page3: View {
    @EnvironmentObject var loopersViewModel: LoopersViewModel
    @EnvironmentObject var fxPanelViewModel: FxPanelViewModel
    @EnvironmentObject var bottomPanelViewModel: BottomPanelViewModel

    var body: some View {
        HStack {
            FaderSlider(channel: 5, controller: 13)
                .frame(width: 50)
            VStack {
                Sampler()
                Spacer()
                InputFxView(layout: .v2, onAction: fxPanelViewModel.onAction)
            }
            VStack {
                HStack {
                    Loopers(
                        states: loopersViewModel.looperStates,
                        indices: [0, 1, 2],
                        onLooperAction: loopersViewModel.onLooperAction,
                        fxPanelLayout: .v2
                    )
                    .rightSideContent {
//                        Rectangle()
//                            .foregroundColor(GrayScaleColor.backgroundDisabled.color)
//                            .frame(width: 300)
                    }
                }
                BottomPanel(
                    onAction: bottomPanelViewModel.onAction
                )
            }
        }
    }
}
