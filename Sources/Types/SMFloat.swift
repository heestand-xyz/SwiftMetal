//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat: SMValue<Float>, ExpressibleByFloatLiteral {

    public convenience init(_ value: Float) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> (Float)) {
        super.init(futureValue, type: "float")
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ value })
    }
        
}

public class SMFloat2: SMValue<(SMFloat, SMFloat)>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: (SMFloat, SMFloat)) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> ((SMFloat, SMFloat))) {
        super.init(futureValue, type: "float2")
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ (SMFloat(value), SMFloat(value)) })
    }
        
}

public class SMFloat3: SMValue<(SMFloat, SMFloat, SMFloat)>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: (SMFloat, SMFloat, SMFloat)) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> ((SMFloat, SMFloat, SMFloat))) {
        super.init(futureValue, type: "float3")
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ (SMFloat(value), SMFloat(value), SMFloat(value)) })
    }
        
}

public class SMFloat4: SMValue<(SMFloat, SMFloat, SMFloat, SMFloat)>, ExpressibleByFloatLiteral {
    
    public convenience init(_ value: (SMFloat, SMFloat, SMFloat, SMFloat)) {
        self.init({ value })
    }
    
    public init(_ futureValue: @escaping () -> ((SMFloat, SMFloat, SMFloat, SMFloat))) {
        super.init(futureValue, type: "float4")
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init({ (SMFloat(value), SMFloat(value), SMFloat(value), SMFloat(value)) })
    }
        
}

func float(_ value: Float) -> SMFloat {
    SMFloat(value)
}

func float2(_ value0: SMFloat, _ value1: SMFloat) -> SMFloat2 {
    SMFloat2((value0, value1))
}

func float3(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat) -> SMFloat3 {
    SMFloat3((value0, value1, value2))
}

func float4(_ value0: SMFloat, _ value1: SMFloat, _ value2: SMFloat, _ value3: SMFloat) -> SMFloat4 {
    SMFloat4((value0, value1, value2, value3))
}
