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


public class SMFloatTuple: SMValue<SMTuple<Float>> {
    
    let tupleCount: Int
    var constructor: String {
        "float\(tupleCount)"
    }
    
    override var rawUniforms: [SMRaw] { value?.values.map({ $0.value ?? -1 }) ?? [Float].init(repeating: -1, count: tupleCount) }
    
    public subscript(index: Int) -> SMFloat {
        guard (0..<tupleCount).contains(index) else {
            fatalError("subscript out of bounds for \(constructor)")
        }
        return SMFloat(entity: self, at: index)
    }
    
    init(_ value: SMFloat, tupleCount: Int) {
        self.tupleCount = tupleCount
        super.init(SMTuple<Float>([SMFloat].init(repeating: value, count: tupleCount)), type: "float\(tupleCount)", fromEntities: [value])
        snippet = { "\(self.constructor)(\(value.snippet()))" }
    }
    init(_ values: [SMFloat]) {
        guard (2...4).contains(values.count) else {
            fatalError("SMFloatTuple can only be constructed with 2, 3 or 4 values.")
        }
        self.tupleCount = values.count
        super.init(SMTuple<Float>(values), type: "float\(values.count)", fromEntities: values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: values) }
    }
    init(_ tuple: SMTuple<Float>) {
        self.tupleCount = tuple.count
        super.init(tuple, type: "float\(tuple.count)", fromEntities: tuple.values)
        snippet = { Snippet.functionSnippet(name: self.constructor, from: tuple.values) }
    }
    init(_ futureValue: @escaping () -> (SMTuple<Float>), tupleCount: Int) {
        self.tupleCount = tupleCount
        super.init(futureValue, type: "float\(tupleCount)")
    }
    init(operation: SMOperation, snippet: @escaping () -> (String), tupleCount: Int) {
        self.tupleCount = tupleCount
        super.init(operation: operation, snippet: snippet, type: "float\(tupleCount)")
    }
    init(fromEntities: [SMEntity] = [], tupleCount: Int) {
        self.tupleCount = tupleCount
        super.init(type: "float\(tupleCount)", fromEntities: fromEntities)
    }
    
}


public struct SMRawFloat2 {
    typealias T = Float
    let tuple: SMTuple2<T>
    init(_ value0: T, _ value1: T) {
        tuple = SMTuple2<T>(SMFloat(value0), SMFloat(value1))
    }
}

public class SMFloat2: SMFloatTuple, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat) {
        self.init(SMTuple2<Float>(value0, value1))
    }
    required public convenience init(floatLiteral value: Float) {
        self.init(SMFloat(value), tupleCount: 2)
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(SMFloat(Float(value)), tupleCount: 2)
    }
    public convenience init(_ value: SMFloat) {
        self.init(value, tupleCount: 2)
    }
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat2)) {
        self.init({ futureValue().tuple }, tupleCount: 2)
    }
    
    
    public static func + (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, tupleCount: 2)
    }
    public static func - (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, tupleCount: 2)
    }
    public static func * (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, tupleCount: 2)
    }
    public static func / (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, tupleCount: 2)
    }
    
    public static func <=> (lhs: SMFloat2, rhs: SMFloat2) -> (SMFloat2, SMFloat2) {
        return (lhs, rhs)
    }
    
    public prefix static func - (operand: SMFloat2) -> SMFloat2 {
        let float2 = SMFloat2(fromEntities: [operand], tupleCount: 2)
        float2.snippet = { "-\(operand.snippet())" }
        return float2
    }
        
}


public struct SMRawFloat3 {
    typealias T = Float
    let tuple: SMTuple3<T>
    init(_ value0: T, _ value1: T, _ value2: T) {
        tuple = SMTuple3<T>(SMFloat(value0), SMFloat(value1), SMFloat(value2))
    }
}

public class SMFloat3: SMFloatTuple, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var z: SMFloat { self[2] }
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    public var b: SMFloat { self[2] }
    
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) {
        self.init(SMTuple3<Float>(value0, value1, value2))
    }
    required public convenience init(floatLiteral value: Float) {
        self.init(SMFloat(value), tupleCount: 3)
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(SMFloat(Float(value)), tupleCount: 3)
    }
    public convenience init(_ value: SMFloat) {
        self.init(value, tupleCount: 3)
    }
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat3)) {
        self.init({ futureValue().tuple }, tupleCount: 3)
    }
    
    
    public static func + (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, tupleCount: 3)
    }
    public static func - (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, tupleCount: 3)
    }
    public static func * (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, tupleCount: 3)
    }
    public static func / (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, tupleCount: 3)
    }
    
    public static func <=> (lhs: SMFloat3, rhs: SMFloat3) -> (SMFloat3, SMFloat3) {
        return (lhs, rhs)
    }
    
    public prefix static func - (operand: SMFloat3) -> SMFloat3 {
        let float3 = SMFloat3(fromEntities: [operand], tupleCount: 3)
        float3.snippet = { "-\(operand.snippet())" }
        return float3
    }
        
}


public struct SMRawFloat4 {
    typealias T = Float
    let tuple: SMTuple4<T>
    init(_ value0: T, _ value1: T, _ value2: T, _ value3: T) {
        tuple = SMTuple4<T>(SMFloat(value0), SMFloat(value1), SMFloat(value2), SMFloat(value3))
    }
}

public class SMFloat4: SMFloatTuple, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var z: SMFloat { self[2] }
    public var w: SMFloat { self[3] }
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    public var b: SMFloat { self[2] }
    public var a: SMFloat { self[3] }
    
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) {
        self.init(SMTuple4<Float>(value0, value1, value2, value3))
    }
    required public convenience init(floatLiteral value: Float) {
        self.init(SMFloat(value), tupleCount: 4)
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(SMFloat(Float(value)), tupleCount: 4)
    }
    public convenience init(_ value: SMFloat) {
        self.init(value, tupleCount: 4)
    }
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat4)) {
        self.init({ futureValue().tuple }, tupleCount: 4)
    }
    /// Very convenience... Not a part of Metal...
    public convenience init(_ hex: String, alpha: SMFloat = 1.0) {
        var hex = hex
        if hex[0..<1] == "#" {
            if hex.count == 4 {
                hex = hex[1..<4]
            } else {
                hex = hex[1..<7]
            }
        }
        if hex.count == 3 {
            let r = hex[0..<1]
            let g = hex[1..<2]
            let b = hex[2..<3]
            hex = r + r + g + g + b + b
        }
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hex)
        scanner.scanHexInt32(&hexInt)
        let r = SMFloat(Float((hexInt & 0xff0000) >> 16) / 255.0)
        let g = SMFloat(Float((hexInt & 0xff00) >> 8) / 255.0)
        let b = SMFloat(Float((hexInt & 0xff) >> 0) / 255.0)
        self.init([r, g, b, alpha])
    }
    
    
    public static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, tupleCount: 4)
    }
    public static func - (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, tupleCount: 4)
    }
    public static func * (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, tupleCount: 4)
    }
    public static func / (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, tupleCount: 4)
    }
    
    public static func <=> (lhs: SMFloat4, rhs: SMFloat4) -> (SMFloat4, SMFloat4) {
        return (lhs, rhs)
    }
    
    public prefix static func - (operand: SMFloat4) -> SMFloat4 {
        let float4 = SMFloat4(fromEntities: [operand], tupleCount: 4)
        float4.snippet = { "-\(operand.snippet())" }
        return float4
    }
        
}


public func float(_ value: Float) -> SMFloat {
    SMFloat(value)
}

public func float2(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat2 {
    SMFloat2(value0, value1)
}
public func float2(_ value: SMFloat) -> SMFloat2 {
    SMFloat2(value)
}

public func float3(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) -> SMFloat3 {
    SMFloat3(value0, value1, value2)
}
public func float3(_ value: SMFloat) -> SMFloat3 {
    SMFloat3(value)
}

public func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4(value0, value1, value2, value3)
}
public func float4(_ value: SMFloat) -> SMFloat4 {
    SMFloat4(value)
}

public func min(_ values: SMFloat4...) -> SMFloat4 {
    let float = SMFloat4(fromEntities: values, tupleCount: 4)
    float.snippet = { Snippet.functionSnippet(name: "min", from: values)  }
    return float
}

public func max(_ values: SMFloat4...) -> SMFloat4 {
    let float = SMFloat4(fromEntities: values, tupleCount: 4)
    float.snippet = { Snippet.functionSnippet(name: "max", from: values) }
    return float
}

public func fmod(_ value0: SMFloat4, _ value1: SMFloat4) -> SMFloat4 {
    let float = SMFloat4(fromEntities: [value0, value1], tupleCount: 4)
    float.snippet = { "fmod(\(value0.snippet()), \(value1.snippet()))" }
    return float
}

public func abs(_ value: SMFloat4) -> SMFloat4 {
    let float = SMFloat4(fromEntities: [value], tupleCount: 4)
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
