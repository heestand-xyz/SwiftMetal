//
//  SMFunc.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import Metal

public struct SMFunc {
    
//    public typealias V = SMFloat4
    
    enum FuncError: Error {
        case shader
    }
    
    var values: [Float] = []
    
    let textures: [SMTexture]
    
    struct Line {
        let indent: Int
        let snippet: String
        init(in indent: Int = 0, _ snippet: String) {
            self.indent = indent
            self.snippet = snippet
        }
    }
    
    let baseEntity: SMEntity
    
    public init(_ entity: SMEntity) {
        baseEntity = entity
        textures = SMBuilder.textures(for: baseEntity)
        for (i, texture) in textures.enumerated() {
            texture.index = i
        }
    }
    
    public func code() -> String {
        
        var lines: [Line] = []
        
        lines.append(Line("//"))
        lines.append(Line("//  SwiftMetal"))
        lines.append(Line("//"))
        lines.append(Line(""))
        
        lines.append(Line("#include <metal_stdlib>"))
        lines.append(Line("using namespace metal;"))
        lines.append(Line(""))
        
        if !values.isEmpty {
            lines.append(Line("struct Uniforms {"))
            for i in 0..<values.count {
                lines.append(Line(in: 1, "float var\(i);"))
            }
            lines.append(Line("};"))
            lines.append(Line(""))
        }
        
        lines.append(Line("kernel void swiftMetal("))
        if !values.isEmpty {
            lines.append(Line(in: 2, "const device Uniforms& vars [[ buffer(0) ]],"))
        }
        lines.append(Line(in: 2, "texture2d<float, access::write> tex [[ texture(0) ]],"))
        for (i, texture) in textures.enumerated() {
            lines.append(Line(in: 2, "texture2d<float, access::read> \(texture.name) [[ texture(\(i + 1)) ]],"))
        }
        lines.append(Line(in: 2, "uint2 pos [[ thread_position_in_grid ]],"))
        lines.append(Line(in: 2, "sampler smp [[ sampler(0) ]]"))
        lines.append(Line(in: 0, ") {"))
        lines.append(Line(in: 1, ""))

        lines.append(Line(in: 1, "if (pos.x >= tex.get_width() || pos.y >= tex.get_height()) { return; }"))
        lines.append(Line(in: 1, ""))
        
        for texture in textures {
            lines.append(Line(in: 1, "float4 \(texture.snippet()) = \(texture.name).read(pos);"))
        }
        lines.append(Line(in: 1, ""))

//        let code: SMCode = SMBuilder.build(for: baseEntity)
//        code.variables.forEach { variable in
//            lines.append(Line(in: 1, variable.code))
//        }
//        lines.append(Line(in: 1, ""))
//        lines.append(Line(in: 1, "float4 val = \(code.snippet);"))
        lines.append(Line(in: 1, "float4 val = \(baseEntity.snippet());"))
        lines.append(Line(in: 1, ""))
        
        lines.append(Line(in: 1, "tex.write(val, pos);"))
        lines.append(Line(in: 1, ""))
        
        lines.append(Line("}"))
        
        return lines.map({ line -> String in
            var row = ""
            for _ in 0..<line.indent {
                row += "    "
            }
            row += line.snippet;
            return row
        }).joined(separator: "\n") + "\n"
    }
    
    public func make(with metalDevice: MTLDevice) throws -> MTLFunction {
        let lib: MTLLibrary = try metalDevice.makeLibrary(source: code(), options: nil)
        guard let shader: MTLFunction = lib.makeFunction(name: "swiftMetal") else {
            throw FuncError.shader
        }
        return shader
    }
    
}
