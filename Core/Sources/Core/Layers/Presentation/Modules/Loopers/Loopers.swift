//
//  MainView+Loopers.swift
//  LinkHut
//
//  Created by Tom Novotny on 20.02.2023.
//

import SwiftUI

struct Loopers: View {
    var states: [LooperGroupState]
    let indices: [Int]
    let onLooperAction: (LooperGroup.Action) -> Void
    var fxPanelLayout: FxPanel.Layout = .v2

    var body: some View {
        makeBody(leftSide: {}, rightSide: {})
    }

    @ViewBuilder
    func makeBody<LeftSideContent: View, RightSideContent: View>(
        @ViewBuilder leftSide: @escaping () -> LeftSideContent,
        @ViewBuilder rightSide: @escaping () -> RightSideContent
    ) -> some View {
        VStack(spacing: 16) {
            if indices.count == 3 {
                makeLooperGroup(index: indices[2], barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                makeLooperGroup(index: indices[1], barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                makeLooperGroup(index: indices[0], barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
            } else {
                HStack(spacing: 16) {
                    makeLooperGroup(index: 2, barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                    makeLooperGroup(index: 5, barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                }
                HStack(spacing: 16) {
                    makeLooperGroup(index: 1, barAmounts: LooperBarAmount.eightLowest, leftSide: leftSide, rightSide: rightSide)
                    makeLooperGroup(index: 4, barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                }

                HStack(spacing: 16) {
                    makeLooperGroup(index: 0, barAmounts: LooperBarAmount.quaterLowest, leftSide: leftSide, rightSide: rightSide)
                    makeLooperGroup(index: 3, barAmounts: LooperBarAmount.standard, leftSide: leftSide, rightSide: rightSide)
                }
            }
        }
    }

    @ViewBuilder
    func makeLooperGroup<LeftSideContent: View, RightSideContent: View>(
        index: Int,
        barAmounts: [LooperBarAmount],
        @ViewBuilder leftSide: @escaping () -> LeftSideContent,
        @ViewBuilder rightSide: @escaping () -> RightSideContent
    ) -> some View {
        HStack {
            leftSide()
            LooperGroup(
                state: states[index],
                onAction: onLooperAction,
                barAmounts: barAmounts
            )
            FxPanel(
                layout: fxPanelLayout,
                fxBaseNote: states[index].fxBaseNote,
                index: index,
                title: states[index].title
            )
            rightSide()
        }
    }

    func sideContent<SideContent: View>(
        @ViewBuilder leftSide: @escaping () -> SideContent,
        @ViewBuilder rightSide: @escaping () -> SideContent
    ) -> some View {
        makeBody(leftSide: leftSide, rightSide: rightSide)
    }

    func leftSideContent<SideContent: View>(
        @ViewBuilder leftSide: @escaping () -> SideContent
    ) -> some View {
        makeBody(leftSide: leftSide, rightSide: {})
    }

    func rightSideContent<SideContent: View>(
        @ViewBuilder rightSide: @escaping () -> SideContent
    ) -> some View {
        makeBody(leftSide: {}, rightSide: rightSide)
    }
}

struct LoopersView_Previews: PreviewProvider {
    static var previews: some View {
        Loopers(
            states: [],
            indices: [],
            onLooperAction: { _ in }
        )
        .preferredColorScheme(.dark)
        .previewInterfaceOrientation(.landscapeLeft)
        .previewLayout(.sizeThatFits)
    }
}
