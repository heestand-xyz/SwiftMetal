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
    @State var value: Float = 0.5
    var body: some View {
        VStack {
            HStack {
                Image("photo1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                Image("photo2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
            }
            SMView {
                SMShader { uv in
                    let tex1 = SMTexture(image: UIImage(named: "photo1")!)!
                    let tex2 = SMTexture(image: UIImage(named: "photo2")!)!
                    let val = SMLiveFloat(self.$value)
                    let val4 = float4(val)
                    return (tex1 + tex2) * val4
//                    float4(uv.x, uv.y, 0.0, 1.0)
                }
            }
                .aspectRatio(1.5, contentMode: .fit)
                .cornerRadius(10)
//            if main.renderedImage != nil {
//                Image(uiImage: main.renderedImage!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .cornerRadius(5)
//            }
            Slider(value: $value)
//            Slider(value: $main.value)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
