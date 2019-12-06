//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat: SMEntity, SMValue, ExpressibleByFloatLiteral {
    
    public var value: Float
   
    required public init(_ value: Float) {
        self.value = value
        super.init(type: "float")
    }
    
    required public init(floatLiteral value: Float) {
        self.value = value
        super.init(type: "float")
    }
    
//    public override func build() -> SMCode {
//        SMCode(String(describing: value))
//    }
    public override func snippet() -> String {
        String(describing: value)
    }
    
}
