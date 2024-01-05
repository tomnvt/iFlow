//
//  File.swift
//  
//
//  Created by Tom Novotny on 16.07.2023.
//

import SwiftUI

enum GrayScaleColor {
    case backgroundEnabled
    case backgroundActive
    case backgroundDisabled
    case foregroundEnabled
    case foregroundActive
    case foregroundDisabled

    var color: Color {
        switch self {
        case .backgroundEnabled:
            return .white.opacity(0.1)
        case .backgroundActive:
            return .white.opacity(0.8)
        case .backgroundDisabled:
            return .white.opacity(0.05)
        case .foregroundEnabled:
            return .white.opacity(0.8)
        case .foregroundActive:
            return .black.opacity(0.8)
        case .foregroundDisabled:
            return .white.opacity(0.4)
        }
    }
}
