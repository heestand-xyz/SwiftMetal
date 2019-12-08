//
//  SMInt4.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt4: SMEntity, SMValue {
    
    public typealias V = (SMInt, SMInt, SMInt, SMInt)
    
    public var value: V { (SMInt(), SMInt(), SMInt(), SMInt()) }
    
    init() {
        super.init(type: "int4")
    }
    
    public override func snippet() -> String {
        "int4(\(value.0.value), \(value.1.value), \(value.2.value), \(value.3.value))"
    }

}


public class SMInt4Constant: SMInt4, SMValueConstant, ExpressibleByIntegerLiteral {
    
    public let _value: V
    public override var value: V { _value }
    
    required public init(_ value: V) {
        _value = value
    }
    
    required public init(integerLiteral value: Int) {
        _value = (SMIntConstant(value), SMIntConstant(value), SMIntConstant(value), SMIntConstant(value))
    }
    
}


public class SMInt4Varaible: SMInt4, SMValueVaraible {
    
    let futureValue: () -> (V)
    public override var value: V {
        futureValue()
    }
    
    public required init(_ futureValue: @escaping () -> (V)) {
        self.futureValue = futureValue
    }
    
}

func int4(_ value0: SMInt, _ value1: SMInt, _ value2: SMInt, _ value3: SMInt) -> SMInt4Constant {
    SMInt4Constant((value0, value1, value2, value3))
}
