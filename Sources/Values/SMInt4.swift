//
//  SMInt4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMInt4: SMValue {
    
    public var value: (SMInt, SMInt, SMInt, SMInt)
    
    public init(_ value: (SMInt, SMInt, SMInt, SMInt)) {
        self.value = value
    }
    
    public func code() -> String {
        "int4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
}
