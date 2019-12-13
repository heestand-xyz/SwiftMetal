//
//  Circles.swift
//  SwiftMetal_iOS
//
//  Created by Hexagons on 2019-12-13.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import SwiftMetal

struct CirclesView: View {
    var body: some View {
        SMView {
            SMShader { uv, aspect in

                let circle: SMFunc<SMBool> = function { args -> SMBool in
                    let s: SMFloat = args[0] as! SMFloat
                    let x: SMFloat = args[1] as! SMFloat
                    let y: SMFloat = args[2] as! SMFloat
                    let c: SMFloat = sqrt(pow(x, 2) + pow(y, 2))
                    return c < s
                }
                
                let c: SMBool = circle.call(float(0.1), (uv.x - 0.5) * aspect, uv.y - 0.5)
                
                return c <?> float4(1.0) <=> float4(0.0, 0.0, 0.0, 1.0)
                
            }
        }
            .edgesIgnoringSafeArea(.all)
    }
    /// circle from 3 points - from some epic dude on stackoverflow
    func calculateCircleCenter(a: SMFloat2, b: SMFloat2, c: SMFloat2) -> SMFloat2 {
        
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
        let v4: SMFloat = aSlope + (a.y + b.y) / 2
        let y: SMFloat = -1 * v3 / v4
        
        return float2(x, y)
        
    }
}

struct CirclesView_Previews: PreviewProvider {
    static var previews: some View {
        CirclesView()
//            .previewLayout(.fixed(width: 750, height: 750))
    }
}
