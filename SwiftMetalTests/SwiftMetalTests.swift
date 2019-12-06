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
    
    var renderer: SMRRenderer!
    
    override func setUp() {
        renderer = SMRRenderer()
        if renderer == nil {
            assertionFailure()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFunc() {
//        let tex = SMTexture(name: "image")
        let a = float4(1.0, 0.5, 0.0, 1.0) / 3
//        let b = float4(0.0, 0.5, 1.0, 1.0)
//        let x = (a + a) + (0.5 * a)
        let function = SMFunc(a)
        print("> > > > > > >")
        print(function.code())
        print("< < < < < < <")
        let render: SMTexture = try! renderer.render(function: function, at: CGSize(width: 1, height: 1), as: .rgba8Unorm)
        let raw = try! render.raw()
        print(raw.map({ CGFloat($0) / 255 }))
        print("= = = = = = =")
        XCTAssertNotEqual(raw.first!, 0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
