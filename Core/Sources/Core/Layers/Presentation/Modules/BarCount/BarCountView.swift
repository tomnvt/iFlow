//
//  BarCountView.swift
//  iFlow
//
//  Created by Tom Novotny on 07.06.2023.
//

import SwiftUI

struct BarCountView: View {
    @StateObject var viewModel: BarCountViewModel
    let onBarViewTap: (Int) -> Void

    var body: some View {
        HStack {
            ForEach(0 ... 3, id: \.self) { index in
                makeBarView(index: index)
            }
        }
        .frame(height: 30)
        .onAppear(perform: viewModel.onAppear)
    }

    private func makeBarView(index: Int) -> some View {
        Button {
            onBarViewTap(index)
        } label: {
            Rectangle()
                .foregroundColor(viewModel.currentBarIndex == index ? .yellow : GrayScaleColor.backgroundDisabled.color)
                .onTapGesture {
                    onBarViewTap(index)
                }
                .cornerRadius(8)
                .overlay {
                    HStack {
                        ForEach(0 ... 3, id: \.self) { beatIndex in
                            let color: Color = (
                                viewModel.currentBarIndex == index && viewModel.currentBeatIndex == beatIndex
                            ) ? .white.opacity(0.5) : .clear
                            Rectangle()
                                .foregroundColor(color)
                        }
                    }
                }
        }
    }
}
