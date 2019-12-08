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
    
    init(_ futureValue: FV? = nil, operation: SMOperation? = nil, snippet: (() -> (String))? = nil, type: String) {
        self.futureValue = futureValue
        super.init(type: type, operation: operation)
        self.snippet = snippet ?? { "#" }
    }
    
    public static func + (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) + \(rhs.snippet()))" }, type: lhs.type)
    }
    public static func - (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) - \(rhs.snippet()))" }, type: lhs.type)
    }
    public static func * (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) * \(rhs.snippet()))" }, type: lhs.type)
    }
    public static func / (lhs: SMValue<V>, rhs: SMValue<V>) -> SMValue<V> {
        SMValue<V>(operation: SMOperation(lhs: lhs, rhs: rhs), snippet: { "(\(lhs.snippet()) / \(rhs.snippet()))" }, type: lhs.type)
    }

}
