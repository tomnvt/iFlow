@testable import Core
import XCTest

final class QuantizationHelperTests: XCTestCase {
    func testExample() throws {
        var result: Int
        result = QuantizationHelper.quantize(noteStart: 3, quantizationOption: .quarter, barCount: 1)
        XCTAssertEqual(result, 0)
        result = QuantizationHelper.quantize(noteStart: 22, quantizationOption: .quarter, barCount: 1)
        XCTAssertEqual(result, 32)
        result = QuantizationHelper.quantize(noteStart: 125, quantizationOption: .quarter, barCount: 1)
        XCTAssertEqual(result, 0)
        result = QuantizationHelper.quantize(noteStart: 3, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 0)
        result = QuantizationHelper.quantize(noteStart: 7, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 0)
        result = QuantizationHelper.quantize(noteStart: 9, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 16)
        result = QuantizationHelper.quantize(noteStart: 22, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 16)
        result = QuantizationHelper.quantize(noteStart: 112, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 112)
        result = QuantizationHelper.quantize(noteStart: 120, quantizationOption: .eighth, barCount: 1)
        XCTAssertEqual(result, 0)
        result = QuantizationHelper.quantize(noteStart: 125, quantizationOption: .eighth, barCount: 2)
        XCTAssertEqual(result, 128)
        result = QuantizationHelper.quantize(noteStart: 255, quantizationOption: .eighth, barCount: 2)
        XCTAssertEqual(result, 0)
    }
}
