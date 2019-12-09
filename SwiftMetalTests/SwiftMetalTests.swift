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
        
        let shader = SMShader { uv in
            var v = float4(0.0, 0.0, 0.0, 0.0)
            for _ in 0..<5 {
                v += float4(0.1, 0.2, 0.3, 0.4)
            }
            let c: SMFloat4 = v
            return c
        }
        print(shader.code())

        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! renderer.render(shader, at: res, as: .rgba32Float)
        
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
        } else if let raw32 = try? render.raw32() {
            if raw32.count == 4 {
                print("raw32", raw32)
            }
            XCTAssertNotEqual(raw32.first!, 0.0)
        }
        
    }

}
