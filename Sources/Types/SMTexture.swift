//
//  SMTexture.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import UIKit
import Metal

public class SMTexture: SMEntity {
    
    let name: String
    let texture: MTLTexture
    
    var size: CGSize {
        CGSize(width: texture.width, height: texture.height)
    }
    
    enum TextureError: Error {
        case pixelFormat(MTLPixelFormat)
    }
    
//    public init(name: String, image: UIImage) {
//        self.name = name
//        super.init(type: "float4")
//    }
    
    public init(name: String, texture: MTLTexture) {
        self.name = name
        self.texture = texture
        super.init(type: "float4")
    }
    
//    override public func build() -> SMCode {
//        SMCode(name)
//    }
    override public func snippet() -> String {
        name
    }
    
    public func raw() throws -> [UInt8] {
        guard texture.pixelFormat == .rgba8Unorm else {
            throw TextureError.pixelFormat(.rgba8Unorm)
        }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<UInt8>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<UInt8>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
}
