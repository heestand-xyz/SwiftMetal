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
    
    let renderer: SMRenderer
    
    init() {
        
        photo1 = UIImage(named: "photo1")!
        photo2 = UIImage(named: "photo2")!
        
        renderer = SMRenderer()!
        
        let shader = SMShader { uv in
            let tex1 = SMTexture(image: photo1)!
            let tex2 = SMTexture(image: photo2)!
            return tex1 + tex2.sample(at: uv + float2(0.5, 0.0))
        }
        
        print(shader.code())
        
        do {
            let texture = try renderer.render(shader, at: CGSize(width: 1500, height: 1000))
            renderedImage = try texture.image()
        } catch {
            print("Render Error:", error)
        }
        
    }
    
}
