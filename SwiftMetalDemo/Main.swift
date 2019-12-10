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
    
    @Published var photo1: UIImage
    @Published var photo2: UIImage
    @Published var renderedImage: UIImage?
    
    @Published var value: Float = 0.5
        
    init() {
        
        photo1 = UIImage(named: "photo1")!
        photo2 = UIImage(named: "photo2")!
                
        let shader = SMShader { uv in
            let tex1 = SMTexture(image: photo1)!
            let tex2 = SMTexture(image: photo2)!
            let val = SMLiveFloat($value)
            let val4 = float4(val, val, val, val)
            return tex1 * (1.0 - val4) + tex2 * val4
        }
        
        print(shader.code())
        
        let res = CGSize(width: 1500, height: 1000)
        
//        do {
//            let texture = try renderer.render(shader, at: res)
//            renderedImage = try texture.image()
//            print("Rendered!")
//        } catch {
//            print("Render Error:", error)
//        }
        
        do {
            try SMRenderer.renderLive(shader, at: res, rendered: { texture in
                print("Rendered!")
                self.renderedImage = try! texture.image()
            }) { error in
                print("Render Error:", error)
            }
        } catch {
            print("Setup Error:", error)
        }
        
    }
    
}
