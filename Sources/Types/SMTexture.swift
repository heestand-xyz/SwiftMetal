//
//  SMTexture.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import MetalKit
import Combine
import SwiftUI

public class SMTexture: SMFloat4 {
            
    var futureTexture: (() -> (MTLTexture?))?
    var _texture: MTLTexture?
    public var texture: MTLTexture? { _texture ?? futureTexture?() }
    
    var index: Int?
    var name: String {
        "tex\(index ?? -1)"
    }
    
    var size: CGSize {
        CGSize(width: texture?.width ?? -1, height: texture?.height ?? -1)
    }
    
    enum TextureError: Error {
        case noTexture
        case badPixelFormat(target: [MTLPixelFormat])
        case imageFailed(String)
        case copyTextureFailed(String)
    }
    
    public convenience init?(image: _Image) {
        guard let texture = SMTexture.convertFrom(image: image) else { return nil }
        self.init(texture: texture)
    }
    
    public convenience init(futureImage: @escaping () -> (_Image?)) {
        self.init(futureTexture: {
            guard let image: _Image = futureImage() else { return nil }
            guard let texture = SMTexture.convertFrom(image: image) else {
                fatalError("Future Image to MTLTexture conversion failed.")
            }
            return texture
        })
    }
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        guard let texture: MTLTexture = SMTexture.convertFrom(pixelBuffer: pixelBuffer) else { return nil }
        self.init(texture: texture)
    }
    
    public convenience init(futurePixelBuffer: @escaping () -> (CVPixelBuffer?)) {
        self.init(futureTexture: {
            guard let pixelBuffer: CVPixelBuffer = futurePixelBuffer() else { return nil }
            guard let texture: MTLTexture = SMTexture.convertFrom(pixelBuffer: pixelBuffer) else {
                fatalError("Future Pixel Buffer to MTLTexture conversion failed.")
            }
            return texture
        })
    }
    
    public init(texture: MTLTexture) {
        self._texture = texture
        super.init()
        self.snippet = { "t\(self.index ?? -1)" }
    }
    
    public init(futureTexture: @escaping () -> (MTLTexture?)) {
        self.futureTexture = futureTexture
        super.init({ SMTuple<Float>([SMFloat(-1.0), SMFloat(-1.0), SMFloat(-1.0), SMFloat(-1.0)]) })
        hasSink = true
        self.snippet = { "t\(self.index ?? -1)" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    required public convenience init(integerLiteral value: Int) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
    
    public func update() {
        sink?()
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

    public func image() throws -> _Image {
        guard let texture: MTLTexture = texture else {
            throw TextureError.noTexture
        }
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let ciImage = CIImage(mtlTexture: texture, options: [.colorSpace: colorSpace]) else {
            throw TextureError.imageFailed("CIImage")
        }
        let ciFormat: CIFormat
        switch texture.pixelFormat {
        case .rgba8Unorm: ciFormat = .RGBA8
        case .rgba16Float: ciFormat = .RGBA16
        case .rgba32Float: ciFormat = .RGBAf
        default:
            throw TextureError.badPixelFormat(target: [.rgba8Unorm, .rgba16Float, .rgba32Float])
        }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: ciFormat, colorSpace: colorSpace) else {
            throw TextureError.imageFailed("CGImage")
        }
        #if os(macOS)
        return NSImage(cgImage: cgImage, size: CGSize(width: texture.width, height: texture.height))
        #else
        return UIImage(cgImage: cgImage)
        #endif
    }
    
    func raw<T>(fill: T) -> [T] {
        guard let texture: MTLTexture = texture else { return [] }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<T>(repeating: fill, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow: Int = MemoryLayout<T>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    public func raw8() throws -> [UInt8] {
        guard let texture: MTLTexture = texture else { return [] }
        guard texture.pixelFormat == .rgba8Unorm else {
            throw TextureError.badPixelFormat(target: [.rgba8Unorm])
        }
        return raw(fill: 0)
    }
    
    public func raw16() throws -> [Float] {
        guard let texture: MTLTexture = texture else { return [] }
        guard texture.pixelFormat == .rgba16Float else {
            throw TextureError.badPixelFormat(target: [.rgba16Float])
        }
        var raw16: [Float16] = raw(fill: 0)
        return float16to32(&raw16, count: raw16.count)
    }
    
    public func raw32() throws -> [Float] {
        guard let texture: MTLTexture = texture else { return [] }
        guard texture.pixelFormat == .rgba32Float else {
            throw TextureError.badPixelFormat(target: [.rgba32Float])
        }
        return raw(fill: 0.0)
    }
    
    public func values() throws -> [[[Float]]] {
        guard let texture: MTLTexture = texture else { return [] }
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
        try values().map({ $0.map({ (r: $0[0],
                                     g: $0[1],
                                     b: $0[2],
                                     a: $0[3]) }) })
    }
    
    public func colors() throws -> [[_Color]] {
        try values().map({ $0.map({ color in
            #if os(macOS)
            return NSColor(deviceRed: CGFloat(color[0]),
                           green: CGFloat(color[1]),
                           blue: CGFloat(color[2]),
                           alpha: CGFloat(color[3]))
            #else
            return UIColor(red: CGFloat(color[0]),
                           green: CGFloat(color[1]),
                           blue: CGFloat(color[2]),
                           alpha: CGFloat(color[3]))
            #endif
        }) })
    }
    
    public func copyTexture() throws -> MTLTexture {
        guard let texture: MTLTexture = texture else {
            throw TextureError.noTexture
        }
        guard let textureCopy = SMTexture.emptyTexture(at: size, as: texture.pixelFormat) else {
            throw TextureError.copyTextureFailed("Empty Texture Failed")
        }
        guard let commandBuffer = SMRenderer.commandQueue.makeCommandBuffer() else {
            throw TextureError.copyTextureFailed("Make Command Buffer Failed")
        }
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.copyTextureFailed("Make Blit Command Encoder Failed")
        }
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1), to: textureCopy, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    // MARK: - Formats
    
    static func convertFrom(pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var imageTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, SMRenderer.textureCache, pixelBuffer, nil, .bgra8Unorm, width, height, 0, &imageTexture)
        guard let unwrappedImageTexture = imageTexture,
              let texture = CVMetalTextureGetTexture(unwrappedImageTexture),
              result == kCVReturnSuccess else {
            return nil
        }
        return texture
    }
    
    static func convertFrom(image: _Image) -> MTLTexture? {
        #if os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #else
        guard let cgImage = image.cgImage else { return nil }
        #endif
        let textureLoader = MTKTextureLoader(device: SMRenderer.metalDevice)
        guard let texture: MTLTexture = try? textureLoader.newTexture(cgImage: cgImage, options: [
            .origin: MTKTextureLoader.Origin.topLeft as NSObject
        ]) else { return nil }
        return texture
    }
    
    public static func emptyTexture(at size: CGSize, as pixelFormat: MTLPixelFormat) -> MTLTexture? {
        guard size.width > 0 && size.height > 0 else { return nil }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let texture = SMRenderer.metalDevice.makeTexture(descriptor: descriptor) else { return nil }
        return texture
    }
    
}

public class SMLiveTexture: SMTexture {
    var valueSink: AnyCancellable!
    public init(_ publisher: Published<_Image?>.Publisher) {
        var value: MTLTexture?
        super.init { value }
        valueSink = publisher.sink { newValue in
            guard newValue != nil else {
                value = nil
                self.sink?()
                return
            }
            guard let texture = SMTexture.convertFrom(image: newValue!) else {
                fatalError("Live Texture with Image to MTLTexture conversion failed.")
            }
            value = texture
            self.sink?()
        }
        hasSink = true
    }
    public init(_ publisher: Published<CVPixelBuffer?>.Publisher) {
        var value: MTLTexture?
        super.init { value }
        valueSink = publisher.sink { newValue in
            guard newValue != nil else {
                value = nil
                self.sink?()
                return
            }
            guard let texture: MTLTexture = SMTexture.convertFrom(pixelBuffer: newValue!) else {
                fatalError("Live Texture with Pixel Buffer to MTLTexture conversion failed.")
            }
            value = texture
            self.sink?()
        }
        hasSink = true
    }
    public init(_ publisher: Published<MTLTexture?>.Publisher) {
        var value: MTLTexture?
        super.init { value }
        valueSink = publisher.sink { newValue in
            value = newValue
            self.sink?()
        }
        hasSink = true
    }
    public init(_ binding: Binding<_Image?>) {
        _ = CurrentValueSubject<_Image?, Never>(binding.wrappedValue)
        // TODO: - Route values:
        //         Currently the CurrentValueSubject triggers the SMView to update,
        //         then the future values is read.
        super.init(futureTexture: {
            guard binding.wrappedValue != nil else { return nil }
            guard let texture = SMTexture.convertFrom(image: binding.wrappedValue!) else {
                fatalError("Live Texture with Image to MTLTexture conversion failed.")
            }
            return texture
        })
    }
    public init(_ binding: Binding<CVPixelBuffer?>) {
        _ = CurrentValueSubject<CVPixelBuffer?, Never>(binding.wrappedValue)
        // TODO: - Route values:
        //         Currently the CurrentValueSubject triggers the SMView to update,
        //         then the future values is read.
        super.init(futureTexture: {
            guard binding.wrappedValue != nil else { return nil }
            guard let texture: MTLTexture = SMTexture.convertFrom(pixelBuffer: binding.wrappedValue!) else {
                fatalError("Live Texture with Pixel Buffer to MTLTexture conversion failed.")
            }
            return texture
        })
    }
    public init(_ binding: Binding<MTLTexture?>) {
        _ = CurrentValueSubject<MTLTexture?, Never>(binding.wrappedValue)
        // TODO: - Route values:
        //         Currently the CurrentValueSubject triggers the SMView to update,
        //         then the future values is read.
        super.init { binding.wrappedValue }
    }
    deinit {
        valueSink.cancel()
    }
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    required public convenience init(integerLiteral value: Int) {
        fatalError("init(integerLiteral:) has not been implemented")
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
