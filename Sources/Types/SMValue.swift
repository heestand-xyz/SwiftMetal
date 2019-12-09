//
//  SMValue.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMValue<V: SMRaw>: SMEntity {
    
    public typealias FV = () -> (V)
    
    var futureValue: FV?
    var _value: V?
    public var value: V? { _value ?? futureValue?() }
    
    init(_ value: V, type: String, fromEntities: [SMEntity]) {
        self._value = value
        super.init(type: type, fromEntities: fromEntities)
    }
    
    init(_ futureValue: @escaping FV, type: String) {
        self.futureValue = futureValue
        super.init(type: type, isFuture: true)
    }
    
    init(operation: SMOperation, snippet: @escaping () -> (String), type: String) {
        super.init(type: type, operation: operation)
        self.snippet = snippet
    }
    
    init(type: String, fromEntities: [SMEntity] = []) {
        super.init(type: type, fromEntities: fromEntities)
    }

}
