//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat: SMEntity, SMValue {
    
    public typealias V = Float
    
    public var value: V { 0.0 }
    
    init() {
        super.init(type: "float")
    }
    
    public override func snippet() -> String {
        String(describing: value)
    }

}


public class SMFloatConstant: SMFloat, SMValueConstant, ExpressibleByFloatLiteral {
    
    public let _value: V
    public override var value: V { _value }
    
    required public init(_ value: V) {
        _value = value
    }
    
    required public init(floatLiteral value: Float) {
        _value = value
    }
    
}


public class SMFloatVaraible: SMFloat, SMValueVaraible {
    
    let futureValue: () -> (V)
    public override var value: V {
        futureValue()
    }
    
    public required init(_ futureValue: @escaping () -> (V)) {
        self.futureValue = futureValue
    }
    
}
