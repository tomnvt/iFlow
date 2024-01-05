// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKitUI/

import PianoRoll
import SwiftUI

public struct PianoRollDemoView: View {
    public init() {}

    @State var model = PianoRollModel(notes: [
        PianoRollNote(start: 1, length: 2, pitch: 3),
        PianoRollNote(start: 5, length: 1, pitch: 120),
    ], length: 128, height: 128)

    public var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            PianoRoll(model: $model, noteColor: .cyan, layout: .horizontal)
        }.background(Color(white: 0.1))
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        PianoRollDemoView()
    }
}
