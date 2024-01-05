//
//  LooperIndexHelper.swift
//  iFlow
//
//  Created by Tom Novotny on 05.03.2023.
//

enum LooperIndexHelper {
    static func getBaseNoteAndChannel(looperGroupIndex: Int, looperIndex: Int) -> (channel: Int, baseNote: Int) {
        let channel = looperGroupIndex < 3 ? 2 : 3
        let baseNote = looperGroupIndex * 40 - (looperGroupIndex < 3 ? 0 : 120) + looperIndex * 10
        return (channel, baseNote)
    }
}
