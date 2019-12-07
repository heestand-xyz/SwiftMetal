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
        let img = UIImage(named: "photo1", in: Bundle(for: SwiftMetalTests.self), with: nil)!
        let tex = SMTexture(image: img)!
        let a = float4(2.0, 0.5, 0.0, 1.0)
//        let f = SMFunction<SMFloat4, SMFloat4>({ f4 in
//            f4 * 2
//        })
        let c = tex * a
        let function = SMShader(c)
        print("> > > > > > >")
        print(function.code())
        print("< < < < < < <")
        let res = CGSize(width: 40, height: 20)
        let render: SMTexture = try! renderer.render(function: function, at: res, as: .rgba8Unorm)
        let raw = try! render.raw()
        if raw.count == 4 {
            print(raw.map({ CGFloat($0) / 255 }))
        } else {
            print("raw count:", raw.count)
        }
        print("= = = = = = =")
        var txt = ""
        for (i, val) in raw.enumerated() {
            if i % 4 == 0 {
                if i > 0 && i % (Int(res.width) * 4) == 0 {
                    print(txt)
                    txt = ""
                }
                let c = CGFloat(val) / 255
                txt += "\(Int(c * 10))"
            }
        }
        print("~ ~ ~ ~ ~ ~ ~")
        XCTAssertNotEqual(raw.first!, 0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
