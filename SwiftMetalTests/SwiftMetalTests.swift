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
        let f = SMFunc<SMFloat4> { args in
            (args[0] as! SMFloat4) +
            (args[1] as! SMFloat4)
        }
        let shader = SMShader {
            let a = float4(0.1, 0.0, 0.0, 1.0)
            let b = float4(0.2, 0.0, 0.0, 1.0)
            let tex = SMTexture(image: img)!
            let c: SMFloat4 = f.call(a, a) * f.call(b, b) + tex
            return c
        }
        print("> > > > > > >")
        print(shader.code())
        print("< < < < < < <")
        let res = CGSize(width: 1024, height: 1024)
        let render: SMTexture = try! renderer.render(shader: shader, at: res)
        let texture: MTLTexture = render.texture
        let raw = try! render.raw()
        if raw.count == 4 {
            print(raw.map({ CGFloat($0) / 255 }))
        } else {
            print("raw count:", raw.count)
        }
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
