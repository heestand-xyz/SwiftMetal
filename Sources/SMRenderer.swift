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

class SMRenderer {
    
    public static let metalDevice: MTLDevice = {
        guard let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device not found.")
        }
        return metalDevice
    }()
    let commandQueue: MTLCommandQueue
    
    var commandEncoder: MTLComputeCommandEncoder!
    
    enum RenderError: Error {
        case commandBuffer
        case commandEncoder
        case sampler
        case uniformBuffer
        case emptyTexture(String)
    }
    
    init?() {
        
//        guard let metalDevice = MTLCreateSystemDefaultDevice() else { return nil }
//        self.metalDevice = metalDevice
        
        guard let commandQueue = SMRenderer.metalDevice.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue

    }

    func render(function: SMShader, at size: CGSize, as pixelFormat: MTLPixelFormat) throws -> SMTexture {

        
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        commandEncoder = commandBuffer.makeComputeCommandEncoder()
        guard commandEncoder != nil else {
            throw RenderError.commandEncoder
        }

        let shader: MTLFunction = try function.make(with: SMRenderer.metalDevice)
        let pipelineState: MTLComputePipelineState = try SMRenderer.metalDevice.makeComputePipelineState(function: shader)
        commandEncoder.setComputePipelineState(pipelineState)
        
        var values: [Float] = function.values
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
        
        let drawableTexture: MTLTexture = try emptyTexture(at: size, as: pixelFormat)
        commandEncoder.setTexture(drawableTexture, index: 0)
        for (i, texture) in function.textures.enumerated() {
            commandEncoder.setTexture(texture.texture, index: i + 1)
        }

        let threadsPerThreadgroup = MTLSize(width: 8, height: 8, depth: 1)
        let threadsPerGrid = MTLSize(width: Int(size.width), height: Int(size.height), depth: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        
//        commandBuffer.addCompletedHandler { _ in }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        commandEncoder = nil
        
        return SMTexture(texture: drawableTexture)
    }
    
    func emptyTexture(at size: CGSize, as pixelFormat: MTLPixelFormat) throws -> MTLTexture {
        guard size.width > 0 && size.height > 0 else { throw RenderError.emptyTexture("Size is zero.") }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue)
        guard let texture = SMRenderer.metalDevice.makeTexture(descriptor: descriptor) else {
            throw RenderError.emptyTexture("Make failed.")
        }
        return texture
    }
    
}