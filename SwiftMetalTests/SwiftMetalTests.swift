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
        
        let v: Float = 0.5
        
        let shader = SMShader { uv in
            let base = float4(0.25)
            let future = SMFloat4 {
                SMRawFloat4(v, v, v, v)
            }
            return base + future
        }
        print(shader.code())

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
