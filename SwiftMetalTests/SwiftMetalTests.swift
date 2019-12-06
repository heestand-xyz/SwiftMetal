//
//  SwiftMetalTests.swift
//  SwiftMetalTests
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import XCTest
@testable import SwiftMetal

class SwiftMetalTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFunc() {
        let float4a: SMAdd = float4(1.0, 0.5, 0.0, 1.0) + 1.0
        let float4b: SMFloat4 = float4(0.0, 0.5, 1.0, 1.0)
        let add: SMAdd = float4a + float4b
        let function = SMFunc(add)
        print("> > > > > > >")
        print(function.make())
        print("< < < < < < <")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
