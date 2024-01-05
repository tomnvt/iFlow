//
//  View+If.swift
//  LinkHut
//
//  Created by Tom Novotny on 19.02.2023.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool,
        modify modification: (Self) -> Content,
        else elseModification: ((Self) -> Content)?
    ) -> some View {
        if condition() {
            modification(self)
        } else if let elseModification {
            elseModification(self)
        } else {
            self
        }
    }
}
