//
//  LooperMessage.swift
//  LinkHut
//
//  Created by Tom Novotny on 26.02.2023.
//

enum LooperMessage {
    case barAmountChanged(looperGroupIndex: Int, looperIndex: Int, index: Int, isResampling: Bool)
    case clear(looperGroupIndex: Int, looperIndex: Int)
    case loopOn(looperGroupIndex: Int, looperIndex: Int, isOn: Bool)
    case inputOn(looperGroupIndex: Int, looperIndex: Int, isOn: Bool)
    case soloOn(looperGroupIndex: Int, looperIndex: Int, isOn: Bool)
    case looperOn(looperGroupIndex: Int, looperIndex: Int, isOn: Bool)
    case resetFx(fxBaseNote: Int)
    case resetAllFx
}
