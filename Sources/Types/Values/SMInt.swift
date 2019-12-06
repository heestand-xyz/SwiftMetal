//
//  SMInt.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt: SMType, SMValue, ExpressibleByIntegerLiteral {
        
    public var value: Int
    
    required public init(_ value: Int) {
        self.value = value
    }
    
    required public init(integerLiteral value: Int) {
        self.value = value
    }
    
    public override func code() -> String {
        String(describing: value)
    }
    
//    static func + (lhs: SMInt, rhs: SMInt) -> SMAdd {
//        SMAdd(lhs: lhs, rhs: rhs)
//    }
    
}
