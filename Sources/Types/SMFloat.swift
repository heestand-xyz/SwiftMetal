//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension Float: SMRawType {}

public class SMFloat: SMValue<Float>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    static let kType: String = "float"
    public typealias T = Float
    
    override var rawUniforms: [SMRaw] { [value ?? -1] }
    
    init(entity: SMEntity, at index: Int) {
        super.init(type: SMFloat.kType)
        subscriptEntity = entity
        snippet = { "\(entity.snippet())[\(index)]" }
    }

    public init(_ value: T) {
        super.init(value, type: SMFloat.kType)
        snippet = { self.value != nil ? String(describing: self.value!) : "#" }
    }

    public init(_ futureValue: @escaping () -> (T)) {
        super.init(futureValue, type: SMFloat.kType)
    }

    required public convenience init(floatLiteral value: Float) {
        self.init(value)
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(Float(value))
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: SMFloat.kType)
    }
    
    init(fromEntities: [SMEntity]) {
        super.init(type: SMFloat.kType, fromEntities: fromEntities)
    }
    
    public static func + (lhs: SMFloat, rhs: SMFloat) -> SMFloat {
        SMFloat(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" })
    }
    public static func - (lhs: SMFloat, rhs: SMFloat) -> SMFloat {
        SMFloat(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    public static func * (lhs: SMFloat, rhs: SMFloat) -> SMFloat {
        SMFloat(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    public static func / (lhs: SMFloat, rhs: SMFloat) -> SMFloat {
        SMFloat(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    
    public static func < (lhs: SMFloat, rhs: SMFloat) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) < \(rhs.snippet()))" })
    }
    public static func > (lhs: SMFloat, rhs: SMFloat) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) > \(rhs.snippet()))" })
    }
    public static func == (lhs: SMFloat, rhs: SMFloat) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) == \(rhs.snippet()))" })
    }
    public static func != (lhs: SMFloat, rhs: SMFloat) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) != \(rhs.snippet()))" })
    }
    
    public static func <=> (lhs: SMFloat, rhs: SMFloat) -> (SMFloat, SMFloat) {
        return (lhs, rhs)
    }
    
    public prefix static func - (operand: SMFloat) -> SMFloat {
        let float = SMFloat(fromEntities: [operand])
        float.snippet = { "-\(operand.snippet())" }
        return float
    }
    
}

public class SMLiveFloat: SMFloat {
    var valueSink: AnyCancellable!
    public init(_ publisher: Published<Float>.Publisher) {
        var value: Float!
        super.init { value }
        valueSink = publisher.sink { newValue in
            value = newValue
            self.sink?()
        }
        hasSink = true
    }
    public init(_ binding: Binding<Float>) {
        _ = CurrentValueSubject<Float, Never>(binding.wrappedValue)
        // TODO: - Route values:
        //         Currently the CurrentValueSubject triggers the SMView to update,
        //         then the future values is read.
        super.init { binding.wrappedValue }
    }
    deinit {
        valueSink.cancel()
    }
    required public convenience init(floatLiteral value: T) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    required public convenience init(integerLiteral value: Int) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
}


public protocol SMVec {
    var size: Int { get }
    init()
}
public struct SMVec2: SMVec {
    public var size: Int { 2 }
    public init() {}
}
public struct SMVec3: SMVec {
    public var size: Int { 3 }
    public init() {}
}
public struct SMVec4: SMVec {
    public var size: Int { 4 }
    public init() {}
}

public typealias SMFloat2 = SMFloatTuple<SMVec2>
public typealias SMFloat3 = SMFloatTuple<SMVec3>
public typealias SMFloat4 = SMFloatTuple<SMVec4>

public class SMFloatTuple<VEC: SMVec>: SMValue<SMTuple<Float>> {
    
    var vec: SMVec { VEC.init() }
    var constructor: String {
        "float\(vec.size)"
    }
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var z: SMFloat { self[2] }
    public var w: SMFloat { self[3] }
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    public var b: SMFloat { self[2] }
    public var a: SMFloat { self[3] }

    
    override var rawUniforms: [SMRaw] { value?.values.map({ $0.value ?? -1 }) ?? [Float].init(repeating: -1, count: vec.size) }
    
    public subscript(index: Int) -> SMFloat {
        guard (0..<vec.size).contains(index) else {
            fatalError("subscript out of bounds for \(constructor)")
        }
        return SMFloat(entity: self, at: index)
    }
    
    
    public init(_ value: SMFloat) {
        super.init(SMTuple<Float>([SMFloat].init(repeating: value, count: VEC.init().size)),
                   type: "float\(VEC.init().size)", fromEntities: [value])
        snippet = { "\(self.constructor)(\(value.snippet()))" }
    }
    public init(_ values: [SMFloat]) {
        guard (2...4).contains(values.count) else {
            fatalError("SMFloatTuple can only be constructed with 2, 3 or 4 values.")
        }
        super.init(SMTuple<Float>(values), type: "float\(values.count)", fromEntities: values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: values) }
    }
    init(_ tuple: SMTuple<Float>) {
        super.init(tuple, type: "float\(tuple.count)", fromEntities: tuple.values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: tuple.values) }
    }
    public init(_ futureValue: @escaping () -> (SMTuple<Float>)) {
        super.init(futureValue, type: "float\(VEC.init().size)")
    }
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: "float\(VEC.init().size)")
    }
    init(fromEntities: [SMEntity] = []) {
        super.init(type: "float\(VEC.init().size)", fromEntities: fromEntities)
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

//extension SMFloat2: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
//    convenience public init(floatLiteral value: Float) {
//        self.init(SMFloat(value))
//    }
//    convenience public init(integerLiteral value: Int) {
//        self.init(SMFloat(Float(value)))
//    }
//}

public extension SMFloat2 {
    static func + (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func <=> (lhs: SMFloat2, rhs: SMFloat2) -> (SMFloat2, SMFloat2) {
        return (lhs, rhs)
    }
    prefix static func - (operand: SMFloat2) -> SMFloat2 {
        let tuple = SMFloat2(fromEntities: [operand])
        tuple.snippet = { "-\(operand.snippet())" }
        return tuple
    }
}
public extension SMFloat3 {
    static func + (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func <=> (lhs: SMFloat3, rhs: SMFloat3) -> (SMFloat3, SMFloat3) {
        return (lhs, rhs)
    }
    prefix static func - (operand: SMFloat3) -> SMFloat3 {
        let tuple = SMFloat3(fromEntities: [operand])
        tuple.snippet = { "-\(operand.snippet())" }
        return tuple
    }
}
public extension SMFloat4 {
    static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func + (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func - (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func * (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func / (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
    static func <=> (lhs: SMFloat4, rhs: SMFloat4) -> (SMFloat4, SMFloat4) {
        return (lhs, rhs)
    }
    prefix static func - (operand: SMFloat4) -> SMFloat4 {
        let tuple = SMFloat4(fromEntities: [operand])
        tuple.snippet = { "-\(operand.snippet())" }
        return tuple
    }
}


//public struct SMRawFloat2 {
//    typealias T = Float
//    let tuple: SMTuple2<T>
//    init(_ value0: T, _ value1: T) {
//        tuple = SMTuple2<T>(SMFloat(value0), SMFloat(value1))
//    }
//}
//
//public class SMFloat2: SMFloatTuple<SMVec2>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
//
//    public var x: SMFloat { self[0] }
//    public var y: SMFloat { self[1] }
//    public var r: SMFloat { self[0] }
//    public var g: SMFloat { self[1] }
//
//
//    public convenience init(_ value0: SMFloat, _ value1: SMFloat) {
//        self.init(SMTuple2<Float>(value0, value1))
//    }
//    required public convenience init(floatLiteral value: Float) {
//        self.init(SMFloat(value))
//    }
//    required public convenience init(integerLiteral value: Int) {
//        self.init(SMFloat(Float(value)))
//    }
//    public convenience init(_ futureValue: @escaping () -> (SMRawFloat2)) {
//        self.init({ futureValue().tuple })
//    }
//
//
////    public static func + (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
////        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, vec.size: 2)
////    }
////    public static func - (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
////        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, vec.size: 2)
////    }
////    public static func * (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
////        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, vec.size: 2)
////    }
////    public static func / (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
////        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, vec.size: 2)
////    }
////
////    public static func <=> (lhs: SMFloat2, rhs: SMFloat2) -> (SMFloat2, SMFloat2) {
////        return (lhs, rhs)
////    }
////
////    public prefix static func - (operand: SMFloat2) -> SMFloat2 {
////        let float2 = SMFloat2(fromEntities: [operand], vec.size: 2)
////        float2.snippet = { "-\(operand.snippet())" }
////        return float2
////    }
//
//}
//
//
//public struct SMRawFloat3 {
//    typealias T = Float
//    let tuple: SMTuple3<T>
//    init(_ value0: T, _ value1: T, _ value2: T) {
//        tuple = SMTuple3<T>(SMFloat(value0), SMFloat(value1), SMFloat(value2))
//    }
//}
//
//public class SMFloat3: SMFloatTuple<SMVec3>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
//
//    public var x: SMFloat { self[0] }
//    public var y: SMFloat { self[1] }
//    public var z: SMFloat { self[2] }
//    public var r: SMFloat { self[0] }
//    public var g: SMFloat { self[1] }
//    public var b: SMFloat { self[2] }
//
//
//    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) {
//        self.init(SMTuple3<Float>(value0, value1, value2))
//    }
//    required public convenience init(floatLiteral value: Float) {
//        self.init(SMFloat(value))
//    }
//    required public convenience init(integerLiteral value: Int) {
//        self.init(SMFloat(Float(value)))
//    }
//    public convenience init(_ futureValue: @escaping () -> (SMRawFloat3)) {
//        self.init({ futureValue().tuple })
//    }
//
//
////    public static func + (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
////        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, vec.size: 3)
////    }
////    public static func - (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
////        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, vec.size: 3)
////    }
////    public static func * (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
////        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, vec.size: 3)
////    }
////    public static func / (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
////        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, vec.size: 3)
////    }
////
////    public static func <=> (lhs: SMFloat3, rhs: SMFloat3) -> (SMFloat3, SMFloat3) {
////        return (lhs, rhs)
////    }
////
////    public prefix static func - (operand: SMFloat3) -> SMFloat3 {
////        let float3 = SMFloat3(fromEntities: [operand], vec.size: 3)
////        float3.snippet = { "-\(operand.snippet())" }
////        return float3
////    }
//
//}
//
//
//public struct SMRawFloat4 {
//    typealias T = Float
//    let tuple: SMTuple4<T>
//    init(_ value0: T, _ value1: T, _ value2: T, _ value3: T) {
//        tuple = SMTuple4<T>(SMFloat(value0), SMFloat(value1), SMFloat(value2), SMFloat(value3))
//    }
//}
//
//public class SMFloat4: SMFloatTuple<SMVec4>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
//
//    public var x: SMFloat { self[0] }
//    public var y: SMFloat { self[1] }
//    public var z: SMFloat { self[2] }
//    public var w: SMFloat { self[3] }
//    public var r: SMFloat { self[0] }
//    public var g: SMFloat { self[1] }
//    public var b: SMFloat { self[2] }
//    public var a: SMFloat { self[3] }
//
//
//    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) {
//        self.init(SMTuple4<Float>(value0, value1, value2, value3))
//    }
//    required public convenience init(floatLiteral value: Float) {
//        self.init(SMFloat(value))
//    }
//    required public convenience init(integerLiteral value: Int) {
//        self.init(SMFloat(Float(value)))
//    }
//    public convenience init(_ futureValue: @escaping () -> (SMRawFloat4)) {
//        self.init({ futureValue().tuple })
//    }
//    /// Very convenience... Not a part of Metal...
//    public convenience init(_ hex: String, alpha: SMFloat = 1.0) {
//        var hex = hex
//        if hex[0..<1] == "#" {
//            if hex.count == 4 {
//                hex = hex[1..<4]
//            } else {
//                hex = hex[1..<7]
//            }
//        }
//        if hex.count == 3 {
//            let r = hex[0..<1]
//            let g = hex[1..<2]
//            let b = hex[2..<3]
//            hex = r + r + g + g + b + b
//        }
//        var hexInt: UInt32 = 0
//        let scanner: Scanner = Scanner(string: hex)
//        scanner.scanHexInt32(&hexInt)
//        let r = SMFloat(Float((hexInt & 0xff0000) >> 16) / 255.0)
//        let g = SMFloat(Float((hexInt & 0xff00) >> 8) / 255.0)
//        let b = SMFloat(Float((hexInt & 0xff) >> 0) / 255.0)
//        self.init([r, g, b, alpha])
//    }
//
//
////    public static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
////        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, vec.size: 4)
////    }
////    public static func - (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
////        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, vec.size: 4)
////    }
////    public static func * (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
////        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, vec.size: 4)
////    }
////    public static func / (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
////        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, vec.size: 4)
////    }
////
////    public static func <=> (lhs: SMFloat4, rhs: SMFloat4) -> (SMFloat4, SMFloat4) {
////        return (lhs, rhs)
////    }
////
////    public prefix static func - (operand: SMFloat4) -> SMFloat4 {
////        let float4 = SMFloat4(fromEntities: [operand], vec.size: 4)
////        float4.snippet = { "-\(operand.snippet())" }
////        return float4
////    }
//
//}


public func float(_ value: Float) -> SMFloat {
    SMFloat(value)
}

public func float2(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat2 {
    SMFloat2([value0, value1])
}
public func float2(_ value: SMFloat) -> SMFloat2 {
    SMFloat2(value)
}

public func float3(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) -> SMFloat3 {
    SMFloat3([value0, value1, value2])
}
public func float3(_ value: SMFloat) -> SMFloat3 {
    SMFloat3(value)
}

public func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4([value0, value1, value2, value3])
}
public func float4(_ value: SMFloat) -> SMFloat4 {
    SMFloat4(value)
}

public func min(_ values: SMFloat4...) -> SMFloat4 {
    let float = SMFloat4(fromEntities: values)
    float.snippet = { Snippet.functionSnippet(name: "min", from: values)  }
    return float
}

public func max(_ values: SMFloat4...) -> SMFloat4 {
    let float = SMFloat4(fromEntities: values)
    float.snippet = { Snippet.functionSnippet(name: "max", from: values) }
    return float
}

public func fmod(_ value0: SMFloat4, _ value1: SMFloat4) -> SMFloat4 {
    let float = SMFloat4(fromEntities: [value0, value1])
    float.snippet = { "fmod(\(value0.snippet()), \(value1.snippet()))" }
    return float
}

public func abs(_ value: SMFloat4) -> SMFloat4 {
    let float = SMFloat4(fromEntities: [value])
    float.snippet = { "abs(\(value.snippet()))" }
    return float
}

public func sqrt(_ value: SMFloat) -> SMFloat {
    let float = SMFloat(fromEntities: [value])
    float.snippet = { "sqrt(\(value.snippet()))" }
    return float
}

public func pow(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat {
    let float = SMFloat(fromEntities: [value0, value1])
    float.snippet = { "pow(\(value0.snippet()), \(value1.snippet()))" }
    return float
}
