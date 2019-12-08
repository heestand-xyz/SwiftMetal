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
    
    var renderer: SMRenderer!
    
    override func setUp() {
        renderer = SMRenderer()
        if renderer == nil {
            assertionFailure()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFunc() {
//        let img = UIImage(named: "photo1", in: Bundle(for: SwiftMetalTests.self), with: nil)!
//        let tex = SMTexture(image: img)!
        let v0 = float4(0.0, 0.0, 0.0, 1.0)
        let v1 = float4(0.1, 0.1, 0.1, 1.0)
        let v2 = float4(0.2, 0.2, 0.2, 1.0)
//        func f(a: SMFloat4, b: SMFloat4) -> SMFloat4 {
//            a + b
//        }
        let f = SMFunction { args in
            (args[0] as! SMFloat4) + (args[1] as! SMFloat4)
        }
        let c: SMFloat4 = f.call(v0, v1) + f.call(v0, v1) * v2
        let function = SMShader(c, with: [f])
        print("> > > > > > >")
        print(function.code())
        print("< < < < < < <")
        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! renderer.render(function: function, at: res, as: .rgba8Unorm)
        let raw = try! render.raw()
        if raw.count == 4 {
            print(raw.map({ CGFloat($0) / 255 }))
        } else {
            print("raw count:", raw.count)
        }
        print("= = = = = = =")
//        var txt = ""
//        for (i, val) in raw.enumerated() {
//            if i % 4 == 0 {
//                if i > 0 && i % (Int(res.width) * 4) == 0 {
//                    print(txt)
//                    txt = ""
//                }
//                let c = CGFloat(val) / 255
//                txt += "\(Int(c * 10))"
//            }
//        }
//        print("~ ~ ~ ~ ~ ~ ~")
        XCTAssertNotEqual(raw.first!, 0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
