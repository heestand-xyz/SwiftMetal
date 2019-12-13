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
    var body: some View {
        VStack {
            SMView { SMShader { _ in SMLiveTexture(self.$main.finalTexture) } }
                .aspectRatio(9 / 16, contentMode: .fit)
            Slider(value: $main.value)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
