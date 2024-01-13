//
//  LooperState.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

import Foundation

struct LooperState {
    let looperGroupIndex: Int
    let looperIndex: Int
    let baseNote: Int
    let channel: Int
    let isResampling: Bool
    var resamplingNotificationName: Notification.Name?
    let trackName: String
    var barAmount: Double?
    var loopOn: Bool
    var inputOn: Bool
    var soloOn: Bool
    var onOn: Bool

    static func `default`(
        looperGroupIndex: Int,
        looperIndex: Int,
        baseNote: Int,
        channel: Int,
        isResampling: Bool,
        resamplingNotificationName: Notification.Name?,
        trackName: String
    ) -> LooperState {
        .init(
            looperGroupIndex: looperGroupIndex,
            looperIndex: looperIndex,
            baseNote: baseNote,
            channel: channel,
            isResampling: isResampling,
            resamplingNotificationName: resamplingNotificationName,
            trackName: trackName,
            barAmount: nil,
            loopOn: false,
            inputOn: true,
            soloOn: false,
            onOn: true
        )
    }

    func valueForAction(_ action: LooperAction) -> Bool {
        switch action {
        case .loop:
            return loopOn
        case .input:
            return inputOn
        case .solo:
            return soloOn
        case .on:
            return onOn
        }
    }
}
