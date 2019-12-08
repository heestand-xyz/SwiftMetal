//
//  SMTexture.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import UIKit
import MetalKit

public class SMTexture: SMFloat4 {
        
    let texture: MTLTexture
    
    var index: Int?
    var name: String {
        "tex\(index ?? -1)"
    }
    
    var size: CGSize {
        CGSize(width: texture.width, height: texture.height)
    }
    
    enum TextureError: Error {
        case pixelFormat(MTLPixelFormat)
    }
    
    public convenience init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        let textureLoader = MTKTextureLoader(device: SMRenderer.metalDevice)
        guard let texture: MTLTexture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else { return nil }
        self.init(texture: texture)
    }
    
    public init(texture: MTLTexture) {
        self.texture = texture
        super.init({ (SMFloat(0.0), SMFloat(0.0), SMFloat(0.0), SMFloat(0.0)) })
        self.snippet = { "t\(self.index ?? -1)" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
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
