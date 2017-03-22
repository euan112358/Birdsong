//
//  BirdsongTests.swift
//  Birdsong
//
//  Created by Simon Manning on {TODAY}.
//  Copyright © 2017 Birdsong. All rights reserved.
//

import Foundation
import XCTest
import Birdsong

class BirdsongTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(Birdsong().text, "Hello, World!")
    }
}

#if os(Linux)
extension BirdsongTests {
    static var allTests : [(String, (BirdsongTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
#endif
