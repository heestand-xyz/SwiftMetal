//
//  Main.swift
//  SwiftMetalDemo
//
//  Created by Anton Heestand on 2019-12-13.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import SwiftMetal
import Metal

class Main: ObservableObject {
    
    let res: CGSize
    
    let camera: Camera
    
    var shader: SMShader!
    
    let drawableTexture: MTLTexture
    @Published var finalTexture: MTLTexture?
    
    @Published var value: Float = 0.5
    
    var displayLink: CADisplayLink!
    var rendering: Bool = false
    
    init() {
        
        let width: CGFloat = UIScreen.main.nativeBounds.width
        res = CGSize(width: width, height: width * (16 / 9))
        
        drawableTexture = SMTexture.emptyTexture(at: res, as: .rgba8Unorm)!
        
        camera = Camera()
        
        shader = SMShader({ uv in
            let cross: SMFunc<SMFloat4> = function { args -> SMFloat4 in
                let a: SMFloat4 = args[0] as! SMFloat4
                let b: SMFloat4 = args[1] as! SMFloat4
                let f: SMFloat = args[2] as! SMFloat
                let f4: SMFloat4 = float4(f)
                return a * (1.0 - f4) + b * f4
            }
            let cam = SMLiveTexture(self.camera.$pixelBuffer)
                .sample(at: float2(uv.y, 1.0 - uv.x))
            let feed = SMTexture(texture: drawableTexture)
            let val: SMFloat = 0.9 + 0.2 * SMLiveFloat($value)
            let disp = feed.sample(at: float2((uv.x - 0.5) * val + 0.5,
                                              (uv.y - 0.5) * val + 0.5))
            return cross.call(cam, disp, float(0.9))
        })
        
        displayLink = CADisplayLink(target: self, selector: #selector(frameLoop))
        displayLink.add(to: .current, forMode: .common)
        
    }
    
    @objc func frameLoop() {
        print("Demo - Frame Loop")
        guard !rendering else { return }
        rendering = true
        DispatchQueue.global(qos: .background).async {
            print("Demo - Render Start")
            let startTime = CFAbsoluteTimeGetCurrent()
            let renderedTexture = try! SMRenderer.render(self.shader, at: self.res, on: self.drawableTexture)
            let endTime = CFAbsoluteTimeGetCurrent()
            let renderTime = endTime - startTime
            let renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            print("Demo - Render Time \(renderTimeMs)ms")
            DispatchQueue.main.async {
                print("Demo - Render Done")
                self.finalTexture = renderedTexture.texture //copyTexture()
                self.rendering = false
            }
        }
        
    }
    
}
