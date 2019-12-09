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
    }

    override func tearDown() {}

    func testFunc() {
//        let img = UIImage(named: "photo1", in: Bundle(for: SwiftMetalTests.self), with: nil)!
//        let tex = SMTexture(image: img)!
        let date = Date()
        var live: Float {
            Float(-date.timeIntervalSinceNow)
        }
        let func0 = function { args -> SMFloat4 in
            (args[0] as! SMFloat4) *
            float4(0.5, 0.5, 0.5, 1.0)
        }
        let shader = SMShader {
            let a = float4(0.1, 0.0, 0.0, 1.0)
            let b = float4(0.2, 0.0, 0.0, 1.0)
            let lv = SMFloat4 {
                SMRawFloat4(live, live, live, 1.0)
            }
            let c: SMFloat4 = func0.call(a) + func0.call(lv)
            return c
        }
        print("> > > > > > >")
        print(shader.code())
        print("< < < < < < <")
        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! renderer.render(shader, at: res)
        let raw = try! render.raw()
        if raw.count == 4 {
            print(raw.map({ CGFloat($0) / 255 }))
        } else {
            print("raw count:", raw.count)
        }
        print("= = = = = = =")
        XCTAssertNotEqual(raw.first!, 0)
    }

}
