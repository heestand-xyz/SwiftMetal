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
        
        let a: (Float, Float) = (.random(in: -1.0...1.0), .random(in: -1.0...1.0))
        let b: (Float, Float) = (.random(in: -1.0...1.0), .random(in: -1.0...1.0))
        let c: (Float, Float) = (.random(in: -1.0...1.0), .random(in: -1.0...1.0))
        
        func testCircleCenter(a: CGPoint, b: CGPoint, c: CGPoint) -> CGPoint {
            let yDelta_a: CGFloat = b.y - a.y;
            let xDelta_a: CGFloat = b.x - a.x;
            let yDelta_b: CGFloat = c.y - b.y;
            let xDelta_b: CGFloat = c.x - b.x;
            
            let aSlope: CGFloat = yDelta_a / xDelta_a;
            let bSlope: CGFloat = yDelta_b / xDelta_b;
            
            let v0: CGFloat = aSlope * bSlope * (a.y - c.y)
            let v1: CGFloat = bSlope * (a.x + b.x)
            let v2: CGFloat = aSlope * (b.x + c.x)
            let x: CGFloat = (v0 + v1 - v2) / (2 * (bSlope - aSlope))
            
            let v3: CGFloat = x - (a.x + b.x) / 2
            let v4: CGFloat = (a.y + b.y) / 2
            let y: CGFloat = -1 * v3 / aSlope + v4
            
            return CGPoint(x: x, y: y)
        }
        
        let test: CGPoint = testCircleCenter(a: CGPoint(x: CGFloat(a.0), y: CGFloat(a.1)),
                                             b: CGPoint(x: CGFloat(b.0), y: CGFloat(b.1)),
                                             c: CGPoint(x: CGFloat(c.0), y: CGFloat(c.1)))
                
        let shader = SMShader { uv, _ in
            let circleCenter: SMFunc<SMFloat2> = function { args -> SMFloat2 in
                let a: SMFloat2 = args[0] as! SMFloat2
                let b: SMFloat2 = args[1] as! SMFloat2
                let c: SMFloat2 = args[2] as! SMFloat2
                
                let yDelta_a: SMFloat = b.y - a.y;
                let xDelta_a: SMFloat = b.x - a.x;
                let yDelta_b: SMFloat = c.y - b.y;
                let xDelta_b: SMFloat = c.x - b.x;
                
                let aSlope: SMFloat = yDelta_a / xDelta_a;
                let bSlope: SMFloat = yDelta_b / xDelta_b;
                
                let v0: SMFloat = aSlope * bSlope * (a.y - c.y)
                let v1: SMFloat = bSlope * (a.x + b.x)
                let v2: SMFloat = aSlope * (b.x + c.x)
                let x: SMFloat = (v0 + v1 - v2) / (2 * (bSlope - aSlope))
                
                let v3: SMFloat = x - (a.x + b.x) / 2
                let v4: SMFloat = (a.y + b.y) / 2
                let y: SMFloat = -1 * v3 / aSlope + v4
                
                return float2(x, y)
            }
            let A = float2(float(a.0), float(a.1))
            let B = float2(float(b.0), float(b.1))
            let C = float2(float(c.0), float(c.1))
            let res = circleCenter.call(A, B, C)
            return float4(res.x, res.y, 0.0, 1.0)
        }

        let res = CGSize(width: 1, height: 1)
        let render: SMTexture = try! SMRenderer.render(shader, at: res, as: .rgba32Float)
        
        let result: Float = try! render.raw32()[1]
        let roundedResult: Float = round(result * 1_000_000) / 1_000_000
        let roundedTest: Float = round(Float(test.y) * 1_000_000) / 1_000_000
        XCTAssertEqual(roundedResult, roundedTest)
        
        if let raw8 = try? render.raw8() {
            if raw8.count <= 256 {
                print("raw8", raw8.map({ CGFloat($0) / 255 }))
            }
        } else if let raw16 = try? render.raw16() {
            if raw16.count <= 256 {
                print("raw16", raw16)
            }
        } else if let raw32 = try? render.raw32() {
            if raw32.count <= 256 {
                print("raw32", raw32)
            }
        }
        
    }

}
