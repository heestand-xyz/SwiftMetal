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

    override func tearDown() {
        renderer = nil
    }

    func testFunc() {
//        let img = UIImage(named: "photo1", in: Bundle(for: SwiftMetalTests.self), with: nil)!
//        let tex = SMTexture(image: img)!
//        var live: Float {
//            0.333
//        }
//        let func0 = function { args -> SMFloat4 in
//            (args[0] as! SMFloat4) +
//            (args[1] as! SMFloat4)
//        }
        let shader = SMShader { uv in
            var v = float4(-1.0, 0.0, 1.0, 99.0)
//            for _ in 0..<5 {
//                v += float4(0.1, 0.0, 0.0, 0.0)
//            }
            let c: SMFloat4 = v
            return c
        }
        print("> > > > > > >")
        print(shader.code())
        print("< < < < < < <")
        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! renderer.render(shader, at: res, as: .rgba16Float)
        if let raw8 = try? render.raw8() {
            if raw8.count == 4 {
                print("raw8", raw8.map({ CGFloat($0) / 255 }))
            }
            XCTAssertNotEqual(raw8.first!, 0)
        } else if let raw16 = try? render.raw16() {
            if raw16.count == 4 {
                print("raw16", raw16)
            }
            XCTAssertNotEqual(raw16.first!, 0.0)
        }
        print("= = = = = = =")
    }

}
