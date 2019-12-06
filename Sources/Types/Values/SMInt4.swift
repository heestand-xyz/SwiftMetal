//
//  SMInt4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt4: SMType, SMValue, ExpressibleByIntegerLiteral {
        
    public var value: (SMInt, SMInt, SMInt, SMInt)
    
    required public init(_ value: (SMInt, SMInt, SMInt, SMInt)) {
        self.value = value
    }
    
    required public init(integerLiteral value: Int) {
        let smInt = SMInt(value)
        self.value = (smInt, smInt, smInt, smInt)
    }
    
    public override func code() -> String {
        "int4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
//    static func + (lhs: SMInt4, rhs: SMInt4) -> SMAdd {
//        SMAdd(lhs: lhs, rhs: rhs)
//    }
    
}

func int4(_ value0: SMInt, _ value1: SMInt, _ value2: SMInt, _ value3: SMInt) -> SMInt4 {
    SMInt4((value0, value1, value2, value3))
}
