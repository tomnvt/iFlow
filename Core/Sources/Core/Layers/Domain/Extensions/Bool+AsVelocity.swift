//
//  Bool+AsVelocity.swift
//  iFlow
//
//  Created by Tom Novotny on 05.03.2023.
//

import Foundation

extension Bool {
    var asVelocity: Int {
        self ? 127 : 0
    }
}
