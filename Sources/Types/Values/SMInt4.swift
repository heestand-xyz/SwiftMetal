//
//  SMInt4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt4: SMEntity, SMValue, ExpressibleByIntegerLiteral {
        
    public var value: (SMInt, SMInt, SMInt, SMInt)
    
    required public init(_ value: (SMInt, SMInt, SMInt, SMInt)) {
        self.value = value
        super.init(type: "int4")
    }
    
    required public init(integerLiteral value: Int) {
        let smInt = SMInt(value)
        self.value = (smInt, smInt, smInt, smInt)
        super.init(type: "int4")
    }
    
//    public override func build() -> SMCode {
//        SMCode("int4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))")
//    }
    public override func snippet() -> String {
        "int4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
}

func int4(_ value0: SMInt, _ value1: SMInt, _ value2: SMInt, _ value3: SMInt) -> SMInt4 {
    SMInt4((value0, value1, value2, value3))
}
