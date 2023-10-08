
import Foundation
import XCTest
@testable import Ollama_Swift

final class NDJsonParser_SwiftTests: XCTestCase {
    
    let ndJson: String = "{ \"key\": \"value\" }\n"
    
    func testSimpleNDJSON() {
        let twoLines = ndJson + ndJson
        XCTAssert(parseDataFromString(string: twoLines).count == 2)
    }
    
    func testEmptyNDJSON() {
        XCTAssert(parseDataFromString(string: "").count == 0)
    }
    
    func testDoubleNewLineNDJSON() {
        let doubleNewLines = ndJson + "\n" + ndJson
        XCTAssert(parseDataFromString(string: doubleNewLines).count == 2)
    }
    
    func testOneNewLineNDJSON() {
        let doubleNewLines = "\n"
        XCTAssert(parseDataFromString(string: doubleNewLines).count == 0)
    }
    
    func testLeadingNewLineNDJSON() {
        let leadingNewLine = "\n" + ndJson
        XCTAssert(parseDataFromString(string: leadingNewLine).count == 1)
    }
    
    func testNoEndingNewLine() {
        let noEndingNewLine = "{ \"key\": \"value\" }"
        XCTAssert(parseDataFromString(string: noEndingNewLine).count == 1)
    }
    
    func testPerformance() {
        let huge = Array(repeating: ndJson, count: 100000).reduce("", +)
        self.measure {
            self.parseDataFromString(string: huge)
        }
    }
    
    private func parseDataFromString(string: String) -> [AnyObject] {
        let data = string.data(using: String.Encoding.utf8)!
        do {
            let parsed = try JSONParser.JSONObjectsWithData(data: data, options: [])
            return try JSONSerialization.jsonObject(with: parsed, options: []) as! [AnyObject]
        } catch {
            XCTFail("Error")
            return []
        }
    }
}
