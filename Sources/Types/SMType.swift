//
//  SMType.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMType: SMCode {
   
    public func code() -> String { "" }
    
    static func + (lhs: SMType, rhs: SMType) -> SMAdd {
        SMAdd(lhs: lhs, rhs: rhs)
    }
    static func + (lhs: SMType, rhs: Float) -> SMAdd {
        SMAdd(lhs: lhs, rhs: SMFloat(rhs))
    }
    static func + (lhs: Float, rhs: SMType) -> SMAdd {
        SMAdd(lhs: SMFloat(lhs), rhs: rhs)
    }
       
}
