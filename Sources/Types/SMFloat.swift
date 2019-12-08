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

public class SMFloat2: SMValue<SMTuple2<Float>>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: SMTuple2<Float>) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> (SMTuple2<Float>)) {
        super.init(futureValue, type: "float2")
        snippet = { "float2(\(self.value?.value0.value ?? -1), \(self.value?.value1.value ?? -1))" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ SMTuple2<Float>(SMFloat(value),
                                    SMFloat(value)) })
    }
        
}

public class SMFloat3: SMValue<SMTuple3<Float>>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: SMTuple3<Float>) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> (SMTuple3<Float>)) {
        super.init(futureValue, type: "float3")
        snippet = { "float3(\(self.value?.value0.value ?? -1), \(self.value?.value1.value ?? -1), \(self.value?.value2.value ?? -1))" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ SMTuple3<Float>(SMFloat(value),
                                    SMFloat(value),
                                    SMFloat(value)) })
    }
        
}

public class SMFloat4: SMValue<SMTuple4<Float>>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: SMTuple4<Float>) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> (SMTuple4<Float>)) {
        super.init(futureValue, type: "float4")
        snippet = { "float4(\(self.value?.value0.value ?? -1), \(self.value?.value1.value ?? -1), \(self.value?.value2.value ?? -1), \(self.value?.value3.value ?? -1))" }
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ SMTuple4<Float>(SMFloat(value),
                                    SMFloat(value),
                                    SMFloat(value),
                                    SMFloat(value)) })
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(nil, operation: operation, snippet: snippet, type: "float4")
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

func float2(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat2 {
    SMFloat2(SMTuple2<Float>(value0, value1))
}

func float3(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) -> SMFloat3 {
    SMFloat3(SMTuple3<Float>(value0, value1, value2))
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4(SMTuple4<Float>(value0, value1, value2, value3))
}
