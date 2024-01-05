//
//  LooperGroup.swift
//  LinkHut
//
//  Created by Tom Novotny on 04.03.2023.
//

import SwiftUI

struct LooperGroup: View {
    enum Action {
        case clearButtonTap(LooperState)
        case looperActionTap(LooperState, LooperAction)
        case barAmountChange(LooperState, barAmount: Double, index: Int)
        case looperDrag(LooperGroupState, value: Double)
        case looperBottomDrag(LooperGroupState, value: Double)
    }

    let state: LooperGroupState
    var onAction: (Action) -> Void
    let barAmounts: [LooperBarAmount]

    private var opacity: Double {
        let ratio = Double(state.volume) / 127
        if ratio > 0.5 {
            return abs(ratio - 1)
        } else {
            return 0.5
        }
    }
    @State private var muted = false

    var body: some View {
        makeLooperGroup(state: state)
    }

    func makeLooperGroup(state: LooperGroupState) -> some View {
        GeometryReader { proxy in
            HStack {
                VStack(spacing: 1) {
                    ForEach(0..<state.looperStates.count, id: \.self) { index in
                        makeLooper(state: state.looperStates[index])
                    }
                }
                .gesture(
                    DragGesture(coordinateSpace: .local)
                        .onChanged { magnification in
                            let positionPercentage = 1 - (proxy.size.height - magnification.location.y) / proxy.size
                                .height
                            if positionPercentage > 0, positionPercentage < 1 {
                                onAction(.looperDrag(state, value: 1 - positionPercentage))
                            }
                        }
                        .onEnded { drag in
                            onAction(.looperBottomDrag(state, value: drag.startLocation.y - drag.location.y))
                        }
                )
            }
        }
        .overlay {
            Color.black
                .opacity(opacity)
                .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: 0.25), value: opacity)
    }

    func makeLooper(state: LooperState) -> some View {
        HStack(spacing: 1) {
            makeRectangle(title: state.trackName)
                .background(.red)
                .onTapGesture(count: 2) { onAction(.clearButtonTap(state)) }
            ForEach(0 ..< barAmounts.count, id: \.self) { index in
                makeBarAmountButton(state: state, barAmount: barAmounts[index], index: index)
            }
            ForEach([LooperAction.on, LooperAction.input], id: \.self) { action in
                makeRectangle(title: action.rawValue)
                    .background(state.valueForAction(action) ? .blue : .black)
                    .onTapGesture {
                        onAction(.looperActionTap(state, action))
                    }
            }
        }
    }

    func makeBarAmountButton(state: LooperState, barAmount: LooperBarAmount, index: Int) -> some View {
        makeRectangle(title: "\(barAmount.label)")
            .onTapGesture(perform: {
                onAction(.barAmountChange(state, barAmount: barAmount.rawValue, index: index))
            })
            .background(getBackgroundColor(barAmount: barAmount, state: state))
    }

    func getBackgroundColor(barAmount: LooperBarAmount, state: LooperState) -> Color {
        let buttonIsOn = barAmount.rawValue <= (state.barAmount ?? 0)
        if buttonIsOn {
            return GrayScaleColor.backgroundDisabled.color.opacity(0.1)
        } else {
            return GrayScaleColor.backgroundEnabled.color.opacity(state.isResampling ? 0.5 : 1)
        }
    }

    func makeRectangle(title: String) -> some View {
        Rectangle()
            .foregroundColor(GrayScaleColor.backgroundEnabled.color)
            .overlay {
                Text(title)
                    .lineLimit(0)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.01)
            }
    }
}
