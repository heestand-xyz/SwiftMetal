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
    
//    static var commandEncoders: [UUID: MTLComputeCommandEncoder] = [:]
    
    public static var defaultPixelFormat: MTLPixelFormat = .rgba8Unorm
    
    enum RenderError: Error {
        case commandBuffer
        case commandEncoder
        case sampler
        case uniformBuffer
        case emptyTextureFailed
        case renderInProgress
        case someTextureIsNil
    }
    
    public static func render(_ shader: SMShader, at size: CGSize, on texture: MTLTexture? = nil, as pixelFormat: MTLPixelFormat = defaultPixelFormat) throws -> SMTexture {
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let textures: [MTLTexture] = shader.textures.compactMap({ $0.texture })
        guard textures.count == shader.textures.count else {
            throw RenderError.someTextureIsNil
        }
        let rawUniforms: [SMRaw] = try shader.rawUniforms()
        guard let drawableTexture: MTLTexture =  texture ?? SMTexture.emptyTexture(at: size, as: pixelFormat) else {
            throw RenderError.emptyTextureFailed
        }
        return try render(function: function,
                          size: size,
                          rawUniforms: rawUniforms,
                          drawableTexture: drawableTexture,
                          textures: textures,
                          pixelFormat: pixelFormat)
    }
    
    public static func renderLive(_ shader: SMShader, at size: CGSize, as pixelFormat: MTLPixelFormat = defaultPixelFormat, rendered: @escaping (SMTexture) -> (), failed: @escaping (Error) -> ()) throws {
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let preTextures: [MTLTexture?] = shader.textures.map({ !$0.isFuture ? $0.texture! : nil })
        guard let drawableTexture: MTLTexture = SMTexture.emptyTexture(at: size, as: pixelFormat) else {
            throw RenderError.emptyTextureFailed
        }
        var rendering: Bool = false
        shader.render = {
            guard !rendering else {
                failed(RenderError.renderInProgress)
                return
            }
            rendering = true
            do {
                let rawUniforms: [SMRaw] = try shader.rawUniforms()
                let postTextures: [MTLTexture?] = shader.textures.map({ $0.isFuture ? $0.texture : nil })
                let textures: [MTLTexture] = zip(preTextures, postTextures).compactMap { textureAB -> MTLTexture? in
                    textureAB.0 ?? textureAB.1
                }
                guard textures.count == shader.textures.count else {
                    failed(RenderError.someTextureIsNil)
                    return
                }
                DispatchQueue.global(qos: .background).async {
                    do {
                        let texture = try self.render(function: function,
                                                      size: size, rawUniforms: rawUniforms,
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
            } catch {
                rendering = false
                DispatchQueue.main.async {
                    failed(error)
                }
            }
        }
        shader.render!()
    }
    
    public static func renderView(_ shader: SMShader, in view: SMUIView) throws {
        print("SwiftMetal - Render View")
        let function: MTLFunction = try shader.make(with: SMRenderer.metalDevice)
        let preTextures: [MTLTexture?] = shader.textures.map({ !$0.isFuture ? $0.texture! : nil })
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
            print("SwiftMetal - Render View - Render...")
            do {
                let rawUniforms: [SMRaw] = try shader.rawUniforms()
                let postTextures: [MTLTexture?] = shader.textures.map({ $0.isFuture ? $0.texture : nil })
                let textures: [MTLTexture] = zip(preTextures, postTextures).compactMap { textureAB -> MTLTexture? in
                    textureAB.0 ?? textureAB.1
                }
                guard textures.count == shader.textures.count else {
                    print("SwiftMetal - Render View - Render Error:", RenderError.someTextureIsNil)
                    rendering = false
                    return
                }
                DispatchQueue.global(qos: .background).async {
                    do {
                        _ = try self.render(function: function,
                                            size: size, rawUniforms: rawUniforms,
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
            } catch {
                print("SwiftMetal - Render View - Render Setup Error:", error)
                rendering = false
            }
        }
        view.renderCallback = {
            shader.render!()
        }
//        shader.render!()
    }

    static func render(function: MTLFunction, size: CGSize, rawUniforms: [SMRaw], drawableTexture: MTLTexture, drawable: CAMetalDrawable? = nil, textures: [MTLTexture], pixelFormat: MTLPixelFormat) throws -> SMTexture {

        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        let commandEncoder: MTLComputeCommandEncoder! = commandBuffer.makeComputeCommandEncoder()
        guard commandEncoder != nil else {
            throw RenderError.commandEncoder
        }

        let pipelineState: MTLComputePipelineState = try SMRenderer.metalDevice.makeComputePipelineState(function: function)
        commandEncoder.setComputePipelineState(pipelineState)
        
        var rawUniforms: [SMRaw] = rawUniforms
        if !rawUniforms.isEmpty {
            var size: Int = 0
            for rawUniform in rawUniforms {
                if rawUniform is Float {
                    size += MemoryLayout<Float>.size
                } else if rawUniform is Bool {
                    size += MemoryLayout<Bool>.size
                }
            }
            guard let uniformBuffer = SMRenderer.metalDevice.makeBuffer(length: size, options: []) else {
                commandEncoder.endEncoding()
//                commandEncoder = nil
                throw RenderError.uniformBuffer
            }
            let bufferPointer = uniformBuffer.contents()
            memcpy(bufferPointer, &rawUniforms, size)
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
        let tw = Int(size.width)
        let th = Int(size.height)
        let threadsPerGrid = MTLSize(width: tw, height: th, depth: 1)
        let threadsPerThreadgroup = MTLSize(width: 8, height: 8, depth: 1)
//        let w: Int = pipelineState.threadExecutionWidth
//        let h: Int = pipelineState.maxTotalThreadsPerThreadgroup / w
////        let w2: Int = (tw + w - 1) / w
////        let h2: Int = (th + h - 1) / h
//        let threadsPerThreadgroup: MTLSize = MTLSizeMake(w, h, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        #endif
        
        commandEncoder.endEncoding()
        
        if drawable != nil {
            commandBuffer.present(drawable!)
        }
//        commandBuffer.addCompletedHandler { _ in }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

//        commandEncoder = nil
        
        return SMTexture(texture: drawableTexture)
    }
    
}
