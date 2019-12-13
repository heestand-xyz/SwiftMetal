//
//  Logo.swift
//  SwiftMetalDemo
//
//  Created by Anton Heestand on 2019-12-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import SwiftMetal

let aspect: Float = 2.5

 func color(_ hex: String, alpha: SMFloat = 1.0) -> SMFloat4 {
    var hex = hex
    if hex[0..<1] == "#" {
        if hex.count == 4 {
            hex = hex[1..<4]
        } else {
            hex = hex[1..<7]
        }
    }
    if hex.count == 3 {
        let r = hex[0..<1]
        let g = hex[1..<2]
        let b = hex[2..<3]
        hex = r + r + g + g + b + b
    }
    var hexInt: UInt32 = 0
    let scanner: Scanner = Scanner(string: hex)
    scanner.scanHexInt32(&hexInt)
    let r = SMFloat(Float((hexInt & 0xff0000) >> 16) / 255.0)
    let g = SMFloat(Float((hexInt & 0xff00) >> 8) / 255.0)
    let b = SMFloat(Float((hexInt & 0xff) >> 0) / 255.0)
    return SMFloat4([r, g, b, alpha])
}

let logoShader: SMShader = SMShader { uv in
    
    let swiftColorA: SMFloat4 = color("#fd442a")
    let swiftColorB: SMFloat4 = color("#faa33d")
    let metalColorA: SMFloat4 = color("#1ffe72")
    let metalColorB: SMFloat4 = color("#1efdc6")
    
    let circle: SMFunc<SMBool> = function { args -> SMBool in
        let s: SMFloat = args[0] as! SMFloat
        let x: SMFloat = args[1] as! SMFloat
        let y: SMFloat = args[2] as! SMFloat
        let c: SMFloat = sqrt(pow(x, 2) + pow(y, 2))
        return c < s
    }
    let gradient: SMFunc<SMFloat4> = function { args -> SMFloat4 in
        let v: SMFloat = args[0] as! SMFloat
        let a: SMFloat4 = args[1] as! SMFloat4
        let b: SMFloat4 = args[2] as! SMFloat4
        let f: SMFloat4 = float4(v)
        return (1.0 - f) * a + f * b
    }
    
    let x: SMFloat = uv.x - 0.5
    let y: SMFloat = (uv.y - 0.5) / SMFloat(aspect)
    let h: SMFloat = sqrt(3 / 4)
    let s: SMFloat = (1.0 / 5.0)
    let s2: SMFloat = s * h
    let s3: SMFloat = s * sqrt(1.75)
    
    let aCL: SMBool = circle.call(s, x + s * 1.5, y)
    let bCL: SMBool = circle.call(s / 2, x + s * 1.5, y)
    let aCR: SMBool = circle.call(s, x - s * 1.5, y)
    let bCR: SMBool = circle.call(s / 2, x - s * 1.5, y)
    let aCB: SMBool = circle.call(s * 2, x, y - s2 * 3)
    let aCT: SMBool = circle.call(s * 2, x, y + s2 * 3)
    let aCX: SMBool = circle.call(s3, x, y)
    
    let o1: SMBool = aCB || aCT
    let o2: SMBool = (aCL || aCR || aCX) && !o1
    let c: SMFloat4 = float4(o2 <?> 1.0 <=> 0.0)
    
    let swiftGradient: SMFloat4 = gradient.call(1.0 - uv.y, swiftColorA, swiftColorB)
    let metalGradient: SMFloat4 = gradient.call(1.0 - uv.y, metalColorA, metalColorB)
    let ug: SMFloat = uv.x * 2 - 0.5
    let swiftMetalGradient: SMFloat4 = gradient.call(ug, swiftGradient, metalGradient)
    
    let white: SMFloat4 = float4(1.0, 1.0, 1.0, 1.0)
    let black: SMFloat4 = float4(0.0, 0.0, 0.0, 1.0)
    
    let final: SMFloat4 = bCL <?> white <=> (bCR <?> black <=> (c * swiftMetalGradient))
    
    return final
}

struct LogoView: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            SMView { logoShader }
                .aspectRatio(CGFloat(aspect), contentMode: .fit)
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
            .previewLayout(.fixed(width: CGFloat(aspect) * 350, height: 350))
    }
}
