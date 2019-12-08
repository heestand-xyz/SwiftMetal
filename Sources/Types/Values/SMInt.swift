//
//  SMInt.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt: SMEntity, SMValue {
    
    public typealias V = Int
    
    public var value: V { 0 }
    
    init() {
        super.init(type: "int")
    }
    
    public override func snippet() -> String {
        String(describing: value)
    }

}


public class SMIntConstant: SMInt, SMValueConstant, ExpressibleByIntegerLiteral {
    
    public let _value: V
    public override var value: V { _value }
    
    required public init(_ value: V) {
        _value = value
    }
    
    required public init(integerLiteral value: Int) {
        _value = value
    }
    
}


public class SMIntVaraible: SMInt, SMValueVaraible {
    
    let futureValue: () -> (V)
    public override var value: V {
        futureValue()
    }
    
    public required init(_ futureValue: @escaping () -> (V)) {
        self.futureValue = futureValue
    }
    
}
