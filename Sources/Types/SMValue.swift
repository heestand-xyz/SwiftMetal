//
//  SMValue.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMValue<V>: SMEntity {
    
    public typealias FV = () -> (V)
    
    var futureValue: FV?
    public var value: V? { futureValue?() }
    
    init(_ futureValue: FV? = nil, with operation: SMOperation? = nil, type: String) {
        self.futureValue = futureValue
        super.init(type: type, operation: operation)
        self.snippet = operation?.snippet ?? { String(describing: self.value) }
    }
    
    public static func + (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(with: SMOperation(lhs: lhs, rhs: rhs, snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }), type: lhs.type)
    }
    public static func - (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(with: SMOperation(lhs: lhs, rhs: rhs, snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }), type: lhs.type)
    }
    public static func * (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(with: SMOperation(lhs: lhs, rhs: rhs, snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }), type: lhs.type)
    }
    public static func / (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(with: SMOperation(lhs: lhs, rhs: rhs, snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }), type: lhs.type)
    }

}
