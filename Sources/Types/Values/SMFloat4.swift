//
//  SMFloat4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat4: SMEntity, SMValue {
    
    public typealias V = (SMFloat, SMFloat, SMFloat, SMFloat)
    
    public var value: V { (SMFloat(), SMFloat(), SMFloat(), SMFloat()) }
    
    init() {
        super.init(type: "float4")
    }
    
    public override func snippet() -> String {
        "float4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }

}


public class SMFloat4Constant: SMFloat4, SMValueConstant, ExpressibleByFloatLiteral {
    
    public let _value: V
    public override var value: V { _value }
    
    required public init(_ value: V) {
        _value = value
    }
    
    required public init(floatLiteral value: Float) {
        _value = (SMFloatConstant(value), SMFloatConstant(value), SMFloatConstant(value), SMFloatConstant(value))
    }
    
}


public class SMFloat4Varaible: SMFloat4, SMValueVaraible {
    
    let futureValue: () -> (V)
    public override var value: V {
        futureValue()
    }
    
    public required init(_ futureValue: @escaping () -> (V)) {
        self.futureValue = futureValue
    }
    
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4Constant {
    SMFloat4Constant((value0, value1, value2, value3))
}
