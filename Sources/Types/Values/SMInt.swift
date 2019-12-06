//
//  SMInt.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt: SMEntity, SMValue, ExpressibleByIntegerLiteral {
        
    public var value: Int
    
    required public init(_ value: Int) {
        self.value = value
        super.init(type: "int")
    }
    
    required public init(integerLiteral value: Int) {
        self.value = value
        super.init(type: "int")
    }
    
//    public override func build() -> SMCode {
//        SMCode(String(describing: value))
//    }
    public override func snippet() -> String {
        String(describing: value)
    }
    
}
