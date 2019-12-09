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
        case badPixelFormat(target: [MTLPixelFormat])
        case imageFailed(String)
    }
    
    public convenience init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        let textureLoader = MTKTextureLoader(device: SMRenderer.metalDevice)
        guard let texture: MTLTexture = try? textureLoader.newTexture(cgImage: cgImage, options: [
            .origin: MTKTextureLoader.Origin.bottomLeft as NSObject
        ]) else { return nil }
        self.init(texture: texture)
    }
    
    public init(texture: MTLTexture) {
        self.texture = texture
        super.init()
        self.snippet = { "t\(self.index ?? -1)" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    
    public func sample(at uv: SMFloat2) -> SMFloat4 {
        SMFloat4(sample: self, at: uv)
    }
    
//    public func sample(rel offest: SMFloat2) -> SMFloat4 {
//        SMFloat4(sample: self, at: SMUV() + offest)
//    }
//    
//    public func sample() -> SMFloat4 {
//        SMFloat4(sample: self, at: SMUV())
//    }
    
    // MARK: - Export

    public func image() throws -> UIImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let ciImage = CIImage(mtlTexture: texture, options: [.colorSpace: colorSpace]) else {
            throw TextureError.imageFailed("CIImage")
        }
        let ciFormat: CIFormat
        switch texture.pixelFormat {
        case .rgba8Unorm: ciFormat = .RGBA8
        case .rgba16Float: ciFormat = .RGBA16
        default:
            throw TextureError.badPixelFormat(target: [.rgba8Unorm, .rgba16Float])
        }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: ciFormat, colorSpace: colorSpace) else {
            throw TextureError.imageFailed("CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
    
    func raw<T>(fill: T) -> [T] {
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<T>(repeating: fill, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow: Int = MemoryLayout<T>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    public func raw8() throws -> [UInt8] {
        guard texture.pixelFormat == .rgba8Unorm else {
            throw TextureError.badPixelFormat(target: [.rgba8Unorm])
        }
        return raw(fill: 0)
    }
    
    public func raw16() throws -> [Float] {
        guard texture.pixelFormat == .rgba16Float else {
            throw TextureError.badPixelFormat(target: [.rgba16Float])
        }
        var raw16: [Float16] = raw(fill: 0)
        return float16to32(&raw16, count: raw16.count)
    }
    
    public func raw32() throws -> [Float] {
        guard texture.pixelFormat == .rgba32Float else {
            throw TextureError.badPixelFormat(target: [.rgba32Float])
        }
        return raw(fill: 0.0)
    }
    
    public func pixels() throws -> [[[Float]]] {
        let rawFloats: [Float]
        switch texture.pixelFormat {
        case .rgba8Unorm:
            let raw = try raw8()
            rawFloats = raw.map({ Float($0) / 255 })
        case .rgba16Float:
            rawFloats = try raw16()
        case .rgba32Float:
            rawFloats = try raw32()
        default:
            throw TextureError.badPixelFormat(target: [.rgba8Unorm, .rgba16Float, .rgba32Float])
        }
        var pixels: [[[Float]]] = []
        var row: [[Float]]!
        var pixel: [Float]!
        for (i, rawFloat) in rawFloats.enumerated() {
            if i % (texture.width * 4) == 0 {
                row = []
            }
            if i % 4 == 0 {
                pixel = []
            }
            pixel.append(rawFloat)
            if i % 4 == 3 {
                row.append(pixel)
            }
            if i % (texture.width * 4) == (texture.width * 4) - 1 {
                pixels.append(row)
            }
        }
        return pixels
    }
    
    public func pixels() throws -> [[(r: Float, g: Float, b: Float, a: Float)]] {
        try pixels().map({ $0.map({ (r: $0[0],
                                     g: $0[1],
                                     b: $0[2],
                                     a: $0[3]) }) })
    }
    
    public func pixels() throws -> [[UIColor]] {
        try pixels().map({ $0.map({ UIColor(red: CGFloat($0[0]),
                                            green: CGFloat($0[1]),
                                            blue: CGFloat($0[2]),
                                            alpha: CGFloat($0[3])) }) })
    }
    
}

extension SMFloat4 {
    
    convenience init(sample texture: SMTexture, at uv: SMFloat2) {
        self.init()
        sampleTexture = texture
        sampleUV = uv
        self.snippet = {
            "\(texture.name).sample(smp, \(uv.snippet()))"
        }
    }
    
}
