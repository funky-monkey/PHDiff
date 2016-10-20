//
//  PHDiffTests.swift
//  PHDiffTests
//
//  Created by Andre Alves on 10/16/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import XCTest
@testable import PHDiff

final class PHDiffTests: XCTestCase {

    func testDiff() {
        var oldArray: [String] = []
        var newArray: [String] = []
        var result = DiffResult<String>(deletes: [], inserts: [], moves: [], updates: [])

        oldArray = ["a", "b", "c"]
        newArray = ["a", "b", "c"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = []
        newArray = ["a", "b", "c", "d", "e"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = []
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = ["e", "b", "c", "d", "a"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["p", "U", "b", "A", "5", "F"]
        newArray = ["O", "w", "Z", "U"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["p", "b", "U", "A", "5", "F"]
        newArray = ["O", "w", "Z", "U"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["x", "E", "g", "B", "f", "o", "3", "m"]
        newArray = ["j", "f", "L", "L", "m", "V", "g", "Q", "1"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["j", "E", "g", "B", "f", "o", "3", "m"]
        newArray = ["j", "f", "L", "L", "m", "V", "g", "Q", "1"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = ["e", "b", "c", "d", "a"]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray)
    }

    func testDiffUpdate() {
        var oldArray: [TestUser] = []
        var newArray: [TestUser] = []
        var result = DiffResult<TestUser>(deletes: [], inserts: [], moves: [], updates: [])
        var expectedSteps: [DiffStep<TestUser>] = []

        oldArray = [TestUser(name: "1", age: 0), TestUser(name: "2", age: 0)]
        newArray = [TestUser(name: "1", age: 0), TestUser(name: "2", age: 1)]
        result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
        expectedSteps = [.update(value: TestUser(name: "2", age: 1), index: 1)]
        XCTAssertTrue(result.updates == expectedSteps)
        XCTAssertTrue(oldArray.apply(diffResult: result) == newArray, "simple update")
    }

    func testRandomDiffs() {
        let numberOfTests = 1000

        for i in 1...numberOfTests {
            print("############### Random Diff Test \(i) ###############")
            let oldArray = randomArray(length: randomNumber(0..<500))
            let newArray = randomArray(length: randomNumber(0..<500))

            let result = PHDiff.diff(fromArray: oldArray, toArray: newArray)
            let success = oldArray.apply(diffResult: result) == newArray
            XCTAssertTrue(success)

            if !success {
                print("oldArray = \(oldArray)")
                print("newArray = \(newArray)")
                break
            }
        }
    }

    func testDiffPerformance() {
        let oldArray = randomArray(length: 1000)
        let newArray = randomArray(length: 1000)

        self.measure {
            let _ = PHDiff.diff(fromArray: oldArray, toArray: newArray).applicableSteps
        }
    }
}
