//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import SwiftUI

struct Page1: View {
    @EnvironmentObject var midiLoopersViewModel: MidiLoopersViewModel

    var body: some View {
        MidiLoopersView(
            viewModel: midiLoopersViewModel
        )
    }
}
