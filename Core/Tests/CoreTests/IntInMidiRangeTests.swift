//
//  File.swift
//  
//
//  Created by Tom Novotny on 26.11.2023.
//

import XCTest

class IntInMidiRangeTests: XCTestCase {
    func test_IntInMidiRangeTests() {
        let originalRange = 1...360
        let result = 180.inMidiRange(originalRange: originalRange)
        XCTAssertEqual(result, 63)
    }
}
