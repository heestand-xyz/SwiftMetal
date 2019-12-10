//
//  SMRenderer.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics
import Metal
import MetalKit

public struct SMRenderer {
    
    public static let metalDevice: MTLDevice = {
        guard let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device not found.")
        }
        return metalDevice
    }()
    public static let commandQueue: MTLCommandQueue = {
        guard let commandQueue: MTLCommandQueue = SMRenderer.metalDevice.makeCommandQueue() else {
            fatalError("Metal command queue failed to init.")
        }
        return commandQueue
    }()
    public static let textureCache: CVMetalTextureCache = {
        var textureCache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, SMRenderer.metalDevice, nil, &textureCache)
        guard textureCache != nil else {
            fatalError("Metal texture cache failed to init.")
        }
        return textureCache
    }()
    
    static var commandEncoder: MTLComputeCommandEncoder!
    
    public static var defaultPixelFormat: MTLPixelFormat = .rgba8Unorm
    
    enum RenderError: Error {
        case commandBuffer
        case commandEncoder
        case sampler
        case uniformBuffer
        case emptyTexture(String)
        case renderInProgress
    }
    
    public static func render(_ shader: SMShader, at size: CGSize, as pixelFormat: MTLPixelFormat = defaultPixelFormat) throws -> SMTexture {
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let textures: [MTLTexture] = shader.textures.map({ $0.texture })
        let values: [Float] = shader.values
        let drawableTexture: MTLTexture = try emptyTexture(at: size, as: pixelFormat)
        return try render(function: function,
                          size: size,
                          values: values,
                          drawableTexture: drawableTexture,
                          textures: textures,
                          pixelFormat: pixelFormat)
    }
    
    public static func renderLive(_ shader: SMShader, at size: CGSize, as pixelFormat: MTLPixelFormat = defaultPixelFormat, rendered: @escaping (SMTexture) -> (), failed: @escaping (Error) -> ()) throws {
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let textures: [MTLTexture] = shader.textures.map({ $0.texture })
        let drawableTexture: MTLTexture = try emptyTexture(at: size, as: pixelFormat)
        var rendering: Bool = false
        shader.render = {
            guard !rendering else {
                failed(RenderError.renderInProgress)
                return
            }
            rendering = true
            DispatchQueue.global(qos: .background).async {
                let values: [Float] = shader.values
                do {
                    let texture = try self.render(function: function,
                                                  size: size, values: values,
                                                  drawableTexture: drawableTexture,
                                                  textures: textures,
                                                  pixelFormat: pixelFormat)
                    rendering = false
                    DispatchQueue.main.async {
                        rendered(texture)
                    }
                } catch {
                    rendering = false
                    DispatchQueue.main.async {
                        failed(error)
                    }
                }
            }
        }
        shader.render!()
    }
    
    public static func renderView(_ shader: SMShader, in view: SMUIView) throws { // MTKViewDelegate...
        print("SwiftMetal - Render View")
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let textures: [MTLTexture] = shader.textures.map({ $0.texture })
        var rendering: Bool = false
        shader.render = {
            guard let size = view.res else {
                print("SwiftMetal - Render View - No Res.")
                return
            }
            guard let drawable: CAMetalDrawable = view.currentDrawable else {
                print("SwiftMetal - Render View - No Drawable Texture.")
                return
            }
            guard !rendering else {
                print("SwiftMetal - Render View - Render In Progress...")
                return
            }
            rendering = true
            DispatchQueue.global(qos: .background).async {
                let values: [Float] = shader.values
                do {
                    _ = try self.render(function: function,
                                        size: size, values: values,
                                        drawableTexture: drawable.texture,
                                        drawable: drawable,
                                        textures: textures,
                                        pixelFormat: view.colorPixelFormat)
                    print("SwiftMetal - Render View - Rendered!")
                } catch {
                    print("SwiftMetal - Render View - Render Error:", error)
                }
                rendering = false
            }
        }
        view.renderCallback = {
            shader.render!()
        }
//        shader.render!()
    }

    static func render(function: MTLFunction, size: CGSize, values: [Float], drawableTexture: MTLTexture, drawable: CAMetalDrawable? = nil, textures: [MTLTexture], pixelFormat: MTLPixelFormat) throws -> SMTexture {

        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        commandEncoder = commandBuffer.makeComputeCommandEncoder()
        guard commandEncoder != nil else {
            throw RenderError.commandEncoder
        }

        let pipelineState: MTLComputePipelineState = try SMRenderer.metalDevice.makeComputePipelineState(function: function)
        commandEncoder.setComputePipelineState(pipelineState)
        
        var values: [Float] = values
        if !values.isEmpty {
            let size: Int = MemoryLayout<Float>.size * values.count
            guard let uniformBuffer = SMRenderer.metalDevice.makeBuffer(length: size, options: []) else {
                commandEncoder.endEncoding()
                commandEncoder = nil
                throw RenderError.uniformBuffer
            }
            let bufferPointer = uniformBuffer.contents()
            memcpy(bufferPointer, &values, size)
            commandEncoder.setBuffer(uniformBuffer, offset: 0, index: 0)
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.sAddressMode = .clampToZero
        samplerDescriptor.tAddressMode = .clampToZero
        samplerDescriptor.compareFunction = .never
        guard let sampler: MTLSamplerState = SMRenderer.metalDevice.makeSamplerState(descriptor: samplerDescriptor) else {
            throw RenderError.sampler
        }
        commandEncoder.setSamplerState(sampler, index: 0)
        
        commandEncoder.setTexture(drawableTexture, index: 0)
        for (i, texture) in textures.enumerated() {
            commandEncoder.setTexture(texture, index: i + 1)
        }

        #if !os(tvOS)
        let threadsPerGrid = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 8, height: 8, depth: 1)
//        let w: Int = pipelineState.threadExecutionWidth
//        let h: Int = pipelineState.maxTotalThreadsPerThreadgroup / w
//        let w2: Int = (Int(size.width) + w - 1) / w
//        let h2: Int = (Int(size.height) + h - 1) / h
//        let threadsPerThreadgroup: MTLSize = MTLSizeMake(w2, h2, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        #endif
        
        commandEncoder.endEncoding()
        
        if drawable != nil {
            commandBuffer.present(drawable!)
        }
//        commandBuffer.addCompletedHandler { _ in }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        commandEncoder = nil
        
        return SMTexture(texture: drawableTexture)
    }
    
    static func emptyTexture(at size: CGSize, as pixelFormat: MTLPixelFormat) throws -> MTLTexture {
        guard size.width > 0 && size.height > 0 else { throw RenderError.emptyTexture("Size is zero.") }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let texture = SMRenderer.metalDevice.makeTexture(descriptor: descriptor) else {
            throw RenderError.emptyTexture("Make failed.")
        }
        return texture
    }
    
}
