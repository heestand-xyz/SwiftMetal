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

class SMRRenderer {
    
    let metalDevice: MTLDevice
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
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else { return nil }
        self.metalDevice = metalDevice
        
        guard let commandQueue = metalDevice.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue

    }

    func render(function: SMFunc, at size: CGSize, as pixelFormat: MTLPixelFormat) throws -> SMTexture {

        
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        commandEncoder = commandBuffer.makeComputeCommandEncoder()
        guard commandEncoder != nil else {
            throw RenderError.commandEncoder
        }

        let shader: MTLFunction = try function.make(with: metalDevice)
        let pipelineState: MTLComputePipelineState = try metalDevice.makeComputePipelineState(function: shader)
        commandEncoder.setComputePipelineState(pipelineState)
        
        let drawableTexture: MTLTexture = try emptyTexture(at: size, as: pixelFormat)
        commandEncoder.setTexture(drawableTexture, index: 0)
        
        var values: [Float] = function.values
        if !values.isEmpty {        
            let size: Int = MemoryLayout<Float>.size * values.count
            guard let uniformBuffer = metalDevice.makeBuffer(length: size, options: []) else {
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
        guard let sampler: MTLSamplerState = metalDevice.makeSamplerState(descriptor: samplerDescriptor) else {
            throw RenderError.sampler
        }
        commandEncoder.setSamplerState(sampler, index: 0)

//        let threadsPerThreadgroup = MTLSize(width: 8, height: 8, depth: 8)
//        let threadsPerGrid = MTLSize(width: width, height: height, depth: depth)
//        #if !os(tvOS)
//        (commandEncoder as! MTLComputeCommandEncoder).dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    
        commandEncoder.endEncoding()
        
//        commandBuffer.addCompletedHandler { _ in }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        commandEncoder = nil
        
        return SMTexture(name: "render", texture: drawableTexture)
    }
    
    func emptyTexture(at size: CGSize, as pixelFormat: MTLPixelFormat) throws -> MTLTexture {
        guard size.width > 0 && size.height > 0 else { throw RenderError.emptyTexture("Size is zero.") }
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let texture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw RenderError.emptyTexture("Make failed.")
        }
        return texture
    }
    
}
