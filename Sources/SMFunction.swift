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
    let argTypes: [String]
    let returnType: String
    let index: Int
    var name: String {
        return "f\(index)"
    }
    var code: String {
        var lines: [Line] = []
        var declaration = ""
        declaration += "\(returnType) \(name)("
        for (i, argType) in argTypes.enumerated() {
            if i > 0 {
                declaration += ", "
            }
            declaration += "\(argType) a\(i)"
        }
        declaration += ") {"
        lines.append(Line(declaration))
        lines.append(Line(in: 1, "return 0;"))
        lines.append(Line("}"))
        return Line.merge(lines)
    }
}
