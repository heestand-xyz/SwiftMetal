//
//  Main.swift
//  SwiftMetalDemo
//
//  Created by Anton Heestand on 2019-12-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import SwiftMetal

class Main: ObservableObject {
    
    let camera: Camera
    
    @Published var cameraPixelBuffer: CVPixelBuffer?
    
    init() {
        
        camera = Camera()
        camera.callback = { pixelBuffer in
            print("Camera Frame")
            self.cameraPixelBuffer = pixelBuffer
        }
        
//        let rawCam = SMLiveTexture(self.main.$cameraPixelBuffer)
//        let cam = rawCam.sample(at: float2(uv.y, 1.0 - uv.x))
        
    }
    
}
