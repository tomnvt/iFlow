//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.08.2023.
//

import Foundation

enum LooperBarAmount: Double {
    case sixteen = 16
    case eight = 8
    case four = 4
    case two = 2
    case one = 1
    case half = 0.5
    case quater = 0.25
    case eighth = 0.125
    case sixteenth = 0.0625

    var label: String {
        switch self {
        case .sixteen:
            return "16"
        case .eight:
            return "8"
        case .four:
            return "4"
        case .two:
            return "2"
        case .one:
            return "1"
        case .half:
            return "1/2"
        case .quater:
            return "1/4"
        case .eighth:
            return "1/8"
        case .sixteenth:
            return "1/16"
        }
    }

    static var standard: [LooperBarAmount] {
        [.sixteen, .eight, .four, .two, .one]
    }

    static var eightLowest: [LooperBarAmount] {
        [.two, .one, .half, .quater, .eighth]
    }

    static var quaterLowest: [LooperBarAmount] {
        [.four, .two, .one, .half, .quater]
    }
}
