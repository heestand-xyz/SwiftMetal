//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

extension Float: SMRaw {}

public class SMFloat: SMValue<Float>, ExpressibleByFloatLiteral {
    
    static let kType: String = "float"
    public typealias T = Float
    
    public convenience init(_ value: T) {
        self.init({ value })
    }
    
    init(entity: SMEntity, at index: Int) {
        super.init(type: SMFloat.kType)
        snippet = { "\(entity.snippet())[\(index)]" }
    }

    public init(_ futureValue: @escaping () -> (T)) {
        super.init(futureValue, type: SMFloat.kType)
        snippet = { self.value != nil ? String(describing: self.value!) : "#" }
    }

    required public convenience init(floatLiteral value: T) {
        self.init({ value })
    }

}


public struct SMRawFloat2 {
    typealias T = Float
    let tuple: SMTuple2<T>
    init(_ value0: T, _ value1: T) {
        tuple = SMTuple2<T>(SMFloat(value0), SMFloat(value1))
    }
}

public class SMFloat2: SMValue<SMTuple2<Float>>, ExpressibleByFloatLiteral {
    
    static let kType: String = "float2"
    public typealias T = Float
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    
    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    
    public subscript(index: Int) -> SMFloat {
        guard (0..<2).contains(index) else {
            fatalError("subscript out of bounds for \(SMFloat2.kType)")
        }
        return SMFloat(entity: self, at: index)
    }
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat) {
        self.init(SMTuple2<T>(value0, value1))
    }
    
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat2)) {
        self.init({ futureValue().tuple })
    }
    
    required public convenience init(floatLiteral value: T) {
        self.init(SMTuple2<T>(SMFloat(value),
                              SMFloat(value)))
    }
    
    init(_ value: SMTuple2<T>) {
        super.init(value, type: SMFloat2.kType)
        snippet = { "\(SMFloat2.kType)(\(self.value?.value0.snippet() ?? "#"), \(self.value?.value1.snippet() ?? "#"))" }
    }
    
    init(_ futureValue: @escaping () -> (SMTuple2<T>)) {
        super.init(futureValue, type: SMFloat2.kType)
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: SMFloat2.kType)
    }
    
    init() {
        super.init(type: SMFloat2.kType)
    }
    
    public static func + (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" })
    }
    public static func - (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    public static func * (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    public static func / (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
        
}


public struct SMRawFloat4 {
    typealias T = Float
    let tuple: SMTuple4<T>
    init(_ value0: T, _ value1: T, _ value2: T, _ value3: T) {
        tuple = SMTuple4<T>(SMFloat(value0), SMFloat(value1), SMFloat(value2), SMFloat(value3))
    }
}

public class SMFloat4: SMValue<SMTuple4<Float>>, ExpressibleByFloatLiteral {
    
    static let kType: String = "float4"
    public typealias T = Float
    
    public var x: SMFloat { self[0] }
    public var y: SMFloat { self[1] }
    public var z: SMFloat { self[2] }
    public var w: SMFloat { self[3] }

    public var r: SMFloat { self[0] }
    public var g: SMFloat { self[1] }
    public var b: SMFloat { self[2] }
    public var a: SMFloat { self[3] }

    public subscript(index: Int) -> SMFloat {
        guard (0..<4).contains(index) else {
            fatalError("subscript out of bounds for \(SMFloat2.kType)")
        }
        return SMFloat(entity: self, at: index)
    }
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) {
        self.init(SMTuple4<T>(value0, value1, value2, value3))
    }
    
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat4)) {
        self.init({ futureValue().tuple })
    }
    
    required public convenience init(floatLiteral value: T) {
        self.init(SMTuple4<T>(SMFloat(value),
                              SMFloat(value),
                              SMFloat(value),
                              SMFloat(value)))
    }
    
    init(_ value: SMTuple4<T>) {
        super.init(value, type: SMFloat4.kType)
        snippet = { "\(SMFloat4.kType)(\(self.value?.value0.snippet() ?? "#"), \(self.value?.value1.snippet() ?? "#"), \(self.value?.value2.snippet() ?? "#"), \(self.value?.value3.snippet() ?? "#"))" }
    }
    
    init(_ futureValue: @escaping () -> (SMTuple4<T>)) {
        super.init(futureValue, type: SMFloat4.kType)
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: SMFloat4.kType)
    }
    
    init() {
        super.init(type: SMFloat4.kType)
    }
    
    public static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" })
    }
    public static func - (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
    }
    public static func * (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
    }
    public static func / (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
    }
        
}


public func float(_ value: Float) -> SMFloat {
    SMFloat(value)
}

public func float2(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat2 {
    SMFloat2(value0, value1)
}

public func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4(value0, value1, value2, value3)
}
