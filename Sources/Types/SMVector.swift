//
//  SMVector.swift
//  SwiftMetal_iOS
//
//  Created by Anton Heestand on 2019-12-13.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public protocol SMVec {
    static var size: Int { get }
}
public struct SMVec2: SMVec {
    public static let size: Int = 2
}
public struct SMVec3: SMVec {
    public static let size: Int = 3
}
public struct SMVec4: SMVec {
    public static let size: Int = 4
}

public class SMVector<RT: SMRawType, VEC: SMVec>: SMValue<SMTuple<RT>> {
    
    var constructor: String {
        "\(RT.typeName)\(VEC.size)"
    }
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var z: SMFloat { self[2] }
    public var w: SMFloat { self[3] }
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    public var b: SMFloat { self[2] }
    public var a: SMFloat { self[3] }

    
    override var rawUniforms: [SMRawType]? {
        guard let tuple: SMTuple<RT> = value else { return nil }
        var values: [SMRawType] = []
        for value in tuple.values {
            guard let rawValue = value.value else { return nil }
            values.append(rawValue)
        }
        return values
    }
    
    public subscript(index: Int) -> SMFloat {
        guard (0..<VEC.size).contains(index) else {
            fatalError("subscript out of bounds for \(constructor)")
        }
        return SMFloat(entity: self, at: index)
    }
    
    
    public init(_ value: SMValue<RT>) {
        super.init(SMTuple<RT>([SMValue<RT>].init(repeating: value, count: VEC.size)),
                   type: "\(RT.typeName)\(VEC.size)", fromEntities: [value])
        snippet = { "\(self.constructor)(\(value.snippet()))" }
    }
    public init(_ values: [SMValue<RT>]) {
        guard values.count == VEC.size else {
            fatalError("SMVector of size \(VEC.size) can not be constructed with \(values.count) values.")
        }
        super.init(SMTuple<RT>(values), type: "\(RT.typeName)\(values.count)", fromEntities: values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: values) }
    }
    init(_ tuple: SMTuple<RT>) {
        super.init(tuple, type: "\(RT.typeName)\(tuple.count)", fromEntities: tuple.values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: tuple.values) }
    }
    public init(_ futureValue: @escaping () -> (SMTuple<RT>)) {
        super.init(futureValue, type: "\(RT.typeName)\(VEC.size)")
    }
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: "\(RT.typeName)\(VEC.size)")
    }
    init(fromEntities: [SMEntity] = []) {
        super.init(type: "\(RT.typeName)\(VEC.size)", fromEntities: fromEntities)
    }
    
    
//    public static func + <V: SMVec> (lhs: SMFloatTuple<V>, rhs: SMFloatTuple<V>) -> SMFloatTuple<V> {
//        SMFloatTuple<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    public static func - <V: SMVec> (lhs: SMFloatTuple<V>, rhs: SMFloatTuple<V>) -> SMFloatTuple<V> {
//        SMFloatTuple<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    public static func * <V: SMVec> (lhs: SMFloatTuple<V>, rhs: SMFloatTuple<V>) -> SMFloatTuple<V> {
//        SMFloatTuple<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    public static func / <V: SMVec> (lhs: SMFloatTuple<V>, rhs: SMFloatTuple<V>) -> SMFloatTuple<V> {
//        SMFloatTuple<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//
//    public static func <=> <V: SMVec> (lhs: SMFloatTuple<V>, rhs: SMFloatTuple<V>) -> (SMFloatTuple<V>, SMFloatTuple<V>) {
//        return (lhs, rhs)
//    }
//
//    public prefix static func - <V: SMVec> (operand: SMFloatTuple<V>) -> SMFloatTuple<V> {
//        let tuple = SMFloatTuple<V>(fromEntities: [operand])
//        tuple.snippet = { "-\(operand.snippet())" }
//        return tuple
//    }
    
}
