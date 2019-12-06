//
//  SMFloat4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat4: SMType, SMValue, ExpressibleByFloatLiteral {
        
    public var value: (SMFloat, SMFloat, SMFloat, SMFloat)
    
    required public init(_ value: (SMFloat, SMFloat, SMFloat, SMFloat)) {
        self.value = value
    }
    
    required public init(floatLiteral value: Float) {
        let smFloat = SMFloat(value)
        self.value = (smFloat, smFloat, smFloat, smFloat)
    }
    
    public override func code() -> String {
        "float4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
//    static func + (lhs: SMFloat4, rhs: SMFloat4) -> SMAdd {
//        SMAdd(lhs: lhs, rhs: rhs)
//    }
    
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4((value0, value1, value2, value3))
}
