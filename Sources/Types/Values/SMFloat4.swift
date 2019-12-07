//
//  SMFloat4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat4: SMEntity, SMValue, ExpressibleByFloatLiteral {
    
    public typealias F4 = (SMFloat, SMFloat, SMFloat, SMFloat)
    
    let futureValue: () -> (F4)
    public var value: F4 {
        futureValue()
    }
    
    required public init(_ value: F4) {
        self.futureValue = { value }
        super.init(type: "float4")
    }
    
    public required init(_ futureValue: @escaping () -> (F4)) {
        self.futureValue = futureValue
        super.init(type: "float4")
    }
    
    required public init(floatLiteral value: Float) {
        let smFloat = SMFloat(value)
        self.futureValue = { (smFloat, smFloat, smFloat, smFloat) }
        super.init(type: "float4")
    }
    
//    public override func build() -> SMCode {
//        SMCode("float4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))")
//    }
    public override func snippet() -> String {
        "float4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }
    
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4((value0, value1, value2, value3))
}
