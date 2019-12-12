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
    
    override func setUp() {}

    override func tearDown() {}

    func testShader() {
                
        let shader = SMShader { uv in
            let a = float4(1, 1, 1, 1)
            let b = float4(2, 2, 2, 2)
            let c = float4(2, 2, 2, 2)
            let d = float4(3)
            let e = float4(4)
            let aa = a + a - a
            let bb = b + b - b
            let cc = c + c - c
            return (d * e) + (aa * bb * cc) + (d * e)
        }

        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! SMRenderer.render(shader, at: res, as: .rgba16Float)
        
        if let raw8 = try? render.raw8() {
            if raw8.count <= 256 {
                print("raw8", raw8.map({ CGFloat($0) / 255 }))
            }
            XCTAssertNotEqual(raw8.first!, 0)
        } else if let raw16 = try? render.raw16() {
            if raw16.count <= 256 {
                print("raw16", raw16)
            }
            XCTAssertNotEqual(raw16.first!, 0.0)
        } else if let raw32 = try? render.raw32() {
            if raw32.count <= 256 {
                print("raw32", raw32)
            }
            XCTAssertNotEqual(raw32.first!, 0.0)
        }
        
    }

}
