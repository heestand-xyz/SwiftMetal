//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFloat: SMType, SMValue, ExpressibleByFloatLiteral {
    
    public var value: Float
   
    required public init(_ value: Float) {
        self.value = value
    }
    
    required public init(floatLiteral value: Float) {
        self.value = value
    }
    
    public override func code() -> String {
        String(describing: value)
    }
    
//    public static func + (lhs: SMFloat, rhs: SMFloat) -> SMAdd {
//        SMAdd(lhs: lhs, rhs: rhs)
//    }
    
}
