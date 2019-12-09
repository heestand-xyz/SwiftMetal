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
            HStack {
                Image(uiImage: main.photo1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                Image(uiImage: main.photo2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
            }
            if main.renderedImage != nil {
                Image(uiImage: main.renderedImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
            }
            Slider(value: $main.value)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
