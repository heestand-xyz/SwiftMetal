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

precedencegroup TernaryIf {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: ComparisonPrecedence
}
precedencegroup TernaryElse {
    associativity: left
    higherThan: ComparisonPrecedence
    lowerThan: MultiplicationPrecedence
}
infix operator <?>: TernaryIf
infix operator <=>: TernaryElse

extension Bool: SMRawType {
    public static let typeName: String = "bool"
}

public class SMBool: SMValue<Bool>, ExpressibleByBooleanLiteral {
    
    static let kType: String = "bool"
    public typealias T = Bool

    override var rawUniforms: [SMRawType]? { value != nil ? [value!] : nil }

    public init(_ value: T) {
        super.init(value, type: SMBool.kType)
        snippet = { self.value != nil ? (self.value! ? "true" : "false") : "#" }
    }

    public init(_ futureValue: @escaping () -> (T)) {
        super.init(futureValue, type: SMBool.kType)
    }

    required public convenience init(booleanLiteral value: Bool) {
        self.init(value)
    }

    init(operation: SMOperation, snippet: @escaping () -> (String)) {
        super.init(operation: operation, snippet: snippet, type: SMBool.kType)
    }

    init(fromEntities: [SMEntity]) {
        super.init(type: SMBool.kType, fromEntities: fromEntities)
    }
    
    public static func == (lhs: SMBool, rhs: SMBool) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) == \(rhs.snippet()))" })
    }
    public static func != (lhs: SMBool, rhs: SMBool) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) != \(rhs.snippet()))" })
    }
    public static func && (lhs: SMBool, rhs: SMBool) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) && \(rhs.snippet()))" })
    }
    public static func || (lhs: SMBool, rhs: SMBool) -> SMBool {
        SMBool(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) || \(rhs.snippet()))" })
    }
    
//    public static func <?> <V: SMVec> (lhs: SMBool, rhs: (SMFloatTuple<V>, SMFloatTuple<V>)) -> SMFloatTuple<V> {
//        let float = SMFloatTuple<V>(fromEntities: [lhs, rhs.0, rhs.1])
//        float.snippet = { "(\(lhs.snippet()) ? \(rhs.0.snippet()) : \(rhs.1.snippet()))" }
//        return float
//    }
    public static func <?> (lhs: SMBool, rhs: (SMFloat, SMFloat)) -> SMFloat {
        let float = SMFloat(fromEntities: [lhs, rhs.0, rhs.1])
        float.snippet = { "(\(lhs.snippet()) ? \(rhs.0.snippet()) : \(rhs.1.snippet()))" }
        return float
    }
    public static func <?> (lhs: SMBool, rhs: (SMFloat2, SMFloat2)) -> SMFloat2 {
        let float2 = SMFloat2(fromEntities: [lhs, rhs.0, rhs.1])
        float2.snippet = { "(\(lhs.snippet()) ? \(rhs.0.snippet()) : \(rhs.1.snippet()))" }
        return float2
    }
    public static func <?> (lhs: SMBool, rhs: (SMFloat3, SMFloat3)) -> SMFloat3 {
        let float3 = SMFloat3(fromEntities: [lhs, rhs.0, rhs.1])
        float3.snippet = { "(\(lhs.snippet()) ? \(rhs.0.snippet()) : \(rhs.1.snippet()))" }
        return float3
    }
    public static func <?> (lhs: SMBool, rhs: (SMFloat4, SMFloat4)) -> SMFloat4 {
        let float4 = SMFloat4(fromEntities: [lhs, rhs.0, rhs.1])
        float4.snippet = { "(\(lhs.snippet()) ? \(rhs.0.snippet()) : \(rhs.1.snippet()))" }
        return float4
    }

    public prefix static func ! (operand: SMBool) -> SMBool {
        let float = SMBool(fromEntities: [operand])
        float.snippet = { "!\(operand.snippet())" }
        return float
    }

}

public class SMLiveBool: SMBool {
    var valueSink: AnyCancellable!
    public init(_ publisher: Published<Bool>.Publisher) {
        var value: Bool!
        super.init { value }
        valueSink = publisher.sink { newValue in
            value = newValue
            self.sink?()
        }
        hasSink = true
    }
    public init(_ binding: Binding<Bool>) {
        _ = CurrentValueSubject<Bool, Never>(binding.wrappedValue)
        // TODO: - Route values:
        //         Currently the CurrentValueSubject triggers the SMView to update,
        //         then the future values is read.
        super.init { binding.wrappedValue }
    }
    deinit {
        valueSink.cancel()
    }
    required public convenience init(booleanLiteral value: Bool) {
        fatalError("init(booleanLiteral:) has not been implemented")
    }
}
