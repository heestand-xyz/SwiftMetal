//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

//public class SMArg: SMEntity {
//    let entity: SMEntity
//    init(_ entity: SMEntity) {
//        self.entity = entity
//        super.init(type: "arg")
//    }
//}
//
//public class SMReturn: SMEntity {
//    let entity: SMEntity
//    public init(_ entity: SMEntity) {
//        self.entity = entity
//        super.init(type: "return")
//    }
//}

public class SMRawFunc: Identifiable, Equatable {
    
    public let id: UUID
    
    let function: ([SMEntity]) -> (SMEntity)
    
    init(function: @escaping ([SMEntity]) -> (SMEntity)) {
        id = UUID()
        self.function = function
    }
    
    public static func == (lhs: SMRawFunc, rhs: SMRawFunc) -> Bool {
        lhs.id == rhs.id
    }
    
}

public class SMFunc<R: SMEntity>: SMRawFunc {

    public init(_ function: @escaping ([SMEntity]) -> (R)) {
        super.init(function: function)
    }

    public func call(_ arguments: SMEntity...) -> R {
        arguments.forEach { entity in
            entity.isArg = true
        }
        let returnEntity = function(arguments)
        returnEntity.isReturn = true
        return returnEntity as! R
    }

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
            snippet = snippet.replacingOccurrences(of: argEntity.snippet(), with: "a\(i)")
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
