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
    public var value: V? { futureValue?() }
    
    init(_ futureValue: FV? = nil, operation: SMOperation? = nil, snippet: (() -> (String))? = nil, type: String) {
        self.futureValue = futureValue
        super.init(type: type, operation: operation)
        self.snippet = snippet ?? { "#" }
    }

}
