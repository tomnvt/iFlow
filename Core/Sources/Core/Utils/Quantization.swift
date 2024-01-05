//
//  File.swift
//  
//
//  Created by Tom Novotny on 15.07.2023.
//

enum QuantizationOption: Int, CaseIterable {
    case full = 1
    case half = 2
    case quarter = 4
    case eighth = 8
    case sixteenth = 16
    case thirtysecond = 32

    var gridDensityDivider: Int {
        switch self {
        case .full:
            return 128
        case .half:
            return 64
        case .quarter:
            return 32
        case .eighth:
        return 16
        case .sixteenth:
            return 8
        case .thirtysecond:
            return 4
        }
    }
}

class QuantizationHelper {
    static func quantize(noteStart: Int, quantizationOption: QuantizationOption, barCount: Int) -> Int {
        return findClosestInteger(to: noteStart, in: quantizationOption.rawValue, barCount: barCount)
    }

    private static func findClosestInteger(to value: Int, in rangeSteps: Int, barCount: Int) -> Int {
        let stepLenth = 128 * barCount / rangeSteps
        let range: [Int] = (0..<rangeSteps).map { $0 * stepLenth }
        if value >= range.last! + (128 / rangeSteps / 2) {
            return 0
        }

        var closestValue: Int?
        var closestDifference = Int.max

        for element in range {
            let difference = abs(element - value)
            if difference < closestDifference {
                closestDifference = difference
                closestValue = element
            }
        }

        return closestValue ?? 0
    }

}
