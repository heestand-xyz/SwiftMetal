//
//  Photos.swift
//  SwiftMetal_iOS
//
//  Created by Anton Heestand on 2019-12-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import SwiftMetal

let photosShader: SMShader = SMShader { uv, _ in
    let photo1 = SMTexture(image: UIImage(named: "photo1")!)!
    let photo2 = SMTexture(image: UIImage(named: "photo2")!)!
    let mask: SMBool = photo2.r < 0.1
    return mask <?> photo1 <=> photo2
}

struct PhotosView: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("photo1")
                        .resizable()
                        .aspectRatio(1.5, contentMode: .fit)
                    Image("photo2")
                        .resizable()
                        .aspectRatio(1.5, contentMode: .fit)
                }
                SMView { photosShader }
                    .aspectRatio(1.5, contentMode: .fit)
            }
        }
    }
}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
            .previewLayout(.fixed(width: 750, height: 750))
    }
}
