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
import simd


extension Float: SMRawType {
    public static let typeName: String = "float"
}


public class SMFloat: SMValue<Float>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    static let kType: String = "float"
    public typealias RT = Float
    
    override var rawUniforms: [SMRawType]? { value != nil ? [value!] : nil }
    
    init(entity: SMEntity, at index: Int) {
        super.init(type: SMFloat.kType)
        subscriptEntity = entity
        snippet = { "\(entity.snippet())[\(index)]" }
    }

    public init(_ value: RT) {
        super.init(value, type: SMFloat.kType)
        snippet = { self.value != nil ? String(describing: self.value!) : "#" }
    }

    public init(_ futureValue: @escaping () -> (RT)) {
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
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    required public convenience init(integerLiteral value: Int) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
}

public typealias SMFloat2 = SMVector<Float, SMVec2>
public typealias SMFloat3 = SMVector<Float, SMVec3>
public typealias SMFloat4 = SMVector<Float, SMVec4>

//extension SMFloat2: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
//    convenience public init(floatLiteral value: Float) {
//        self.init(SMFloat(value))
//    }
//    convenience public init(integerLiteral value: Int) {
//        self.init(SMFloat(Float(value)))
//    }
//}

//public extension SMFloat2 {
//    static func + (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat2, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat2, rhs: SMFloat) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat, rhs: SMFloat2) -> SMFloat2 {
//        SMFloat2(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func <=> (lhs: SMFloat2, rhs: SMFloat2) -> (SMFloat2, SMFloat2) {
//        return (lhs, rhs)
//    }
//    prefix static func - (operand: SMFloat2) -> SMFloat2 {
//        let tuple = SMFloat2(fromEntities: [operand])
//        tuple.snippet = { "-\(operand.snippet())" }
//        return tuple
//    }
//}
//public extension SMFloat3 {
//    static func + (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat3, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat3, rhs: SMFloat) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat, rhs: SMFloat3) -> SMFloat3 {
//        SMFloat3(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func <=> (lhs: SMFloat3, rhs: SMFloat3) -> (SMFloat3, SMFloat3) {
//        return (lhs, rhs)
//    }
//    prefix static func - (operand: SMFloat3) -> SMFloat3 {
//        let tuple = SMFloat3(fromEntities: [operand])
//        tuple.snippet = { "-\(operand.snippet())" }
//        return tuple
//    }
//}
//public extension SMFloat4 {
//    static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func + (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func - (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func * (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat4, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat4, rhs: SMFloat) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func / (lhs: SMFloat, rhs: SMFloat4) -> SMFloat4 {
//        SMFloat4(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" })
//    }
//    static func <=> (lhs: SMFloat4, rhs: SMFloat4) -> (SMFloat4, SMFloat4) {
//        return (lhs, rhs)
//    }
//    prefix static func - (operand: SMFloat4) -> SMFloat4 {
//        let tuple = SMFloat4(fromEntities: [operand])
//        tuple.snippet = { "-\(operand.snippet())" }
//        return tuple
//    }
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
