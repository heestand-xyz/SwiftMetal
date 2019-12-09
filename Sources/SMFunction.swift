//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFunc<R: SMEntity>: Identifiable {
    
    public let id: UUID
    
    let function: ([SMEntity]) -> (SMEntity)
    
    public init(_ function: @escaping ([SMEntity]) -> (R)) {
        id = UUID()
        self.function = function
    }

    public func call(_ arguments: SMEntity...) -> R {
        arguments.forEach { entity in
            entity.isArg = true
        }
        let returnEntity = function(arguments)
        returnEntity.returnId = id
        return returnEntity as! R
    }

}

func function<R: SMEntity>(_ function: @escaping ([SMEntity]) -> (R)) -> SMFunc<R> {
    SMFunc<R>(function)
}

struct SMFunction {
    let argEntities: [SMEntity]
    let returnEntity: SMEntity
    let index: Int
    var name: String {
        return "f\(index)"
    }
    var code: String {
        var lines: [Line] = []
        var declaration = ""
        declaration += "\(returnEntity.type) \(name)("
        for (i, argEntity) in argEntities.enumerated() {
            if i > 0 {
                declaration += ", "
            }
            declaration += "\(argEntity.type) a\(i)"
        }
        declaration += ") {"
        lines.append(Line(declaration))
        var snippet: String = returnEntity.snippet()
        for (i, argEntity) in argEntities.enumerated() {
            if let snippetIndexRange = snippet.range(of: argEntity.snippet()) {
                snippet = snippet.replacingCharacters(in: snippetIndexRange, with: "a\(i)")
            }
        }
        lines.append(Line(in: 1, "return \(snippet);"))
        lines.append(Line("}"))
        return Line.merge(lines)
    }
    func snippet(with args: [SMEntity]) -> String {
        var call = ""
        call += "\(name)("
        for (i, arg) in args.enumerated() {
            if i > 0 {
                call += ", "
            }
            call += "\(arg.snippet())"
        }
        call += ")"
        return call
    }
}
