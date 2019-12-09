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

    public convenience init(_ value: Float) {
        self.init({ value })
    }

    public init(_ futureValue: @escaping () -> (Float)) {
        super.init(futureValue, type: "float")
        snippet = { String(describing: self.value) }
    }

    required public convenience init(floatLiteral value: Float) {
        self.init({ value })
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
    
    public convenience init(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) {
        self.init({ SMTuple4<T>(value0, value1, value2, value3) })
    }
    
    public init(_ value: SMTuple4<T>) {
        super.init(value, type: SMFloat4.kType)
        setSnippet()
    }
    
    public convenience init(_ futureValue: @escaping () -> (SMRawFloat4)) {
        self.init({ futureValue().tuple })
    }
    
    public init(_ futureValue: @escaping () -> (SMTuple4<T>)) {
        super.init(futureValue, type: SMFloat4.kType)
        setSnippet()
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: SMFloat4.kType)
    }
    
    required public convenience init(floatLiteral value: T) {
        self.init({ SMTuple4<T>(SMFloat(value),
                                SMFloat(value),
                                SMFloat(value),
                                SMFloat(value)) })
    }
    
    func setSnippet() {
        snippet = { "\(SMFloat4.kType)(\(self.value?.value0.value ?? -1), \(self.value?.value1.value ?? -1), \(self.value?.value2.value ?? -1), \(self.value?.value3.value ?? -1))" }
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

func float(_ value: Float) -> SMFloat {
    SMFloat(value)
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4(value0, value1, value2, value3)
}
