//
//  ContentView.swift
//  SwiftMetalDemo
//
//  Created by Anton Heestand on 2019-12-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import SwiftMetal

struct ContentView: View {
    @EnvironmentObject var main: Main
//    @State var value: Float = 1.0
    var body: some View {
        VStack {
            SMView {
                SMShader { uv in
                    let rawCam = SMLiveTexture(self.main.$cameraPixelBuffer)
                    let cam = rawCam.sample(at: float2(uv.y, 1.0 - uv.x))
                    return cam
                }
            }
//            Slider(value: $value)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
