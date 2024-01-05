//
//  View+OnTouch.swift
//  MidiMap
//
//  Created by Tom Novotny on 22.10.2022.
//

import SwiftUI

extension View {
    func onTouch(
        down touchDownCallback: ((DragGesture.Value) -> Void)? = nil,
        up touchUpCallback: ((DragGesture.Value) -> Void)? = nil
    ) -> some View {
        modifier(OnTouchDownGestureModifier(
            touchDownCallback: touchDownCallback,
            touchUpCallback: touchUpCallback
        ))
    }
}

private struct OnTouchDownGestureModifier: ViewModifier {
    @State private var tapped = false
    let touchDownCallback: ((DragGesture.Value) -> Void)?
    let touchUpCallback: ((DragGesture.Value) -> Void)?

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    if !self.tapped {
                        self.tapped = true
                        self.touchDownCallback?(gesture)
                    }
                }
                .onEnded { gesture in
                    self.tapped = false
                    self.touchUpCallback?(gesture)
                })
    }
}
