//
//  SMFloat4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMFloat4: SMValue {
    
    public var value: (SMFloat, SMFloat, SMFloat, SMFloat)
    
    public init(_ value: (SMFloat, SMFloat, SMFloat, SMFloat)) {
        self.value = value
    }
    
    public func code() -> String {
        "float4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
}
