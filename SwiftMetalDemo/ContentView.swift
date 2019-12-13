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
//    @EnvironmentObject var main: Main
    var body: some View {
        SMView {
            SMShader { uv in
                let uv4: SMFloat4 = float4(uv.x, uv.y, 0.0, 1.0)
                let c: SMFloat4 = uv4 + float4(0.5)
                return c
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
