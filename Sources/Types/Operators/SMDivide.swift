//
//  SMDivide.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMDivide: SMEntity, SMOperator {
    
    var lhs: SMEntity
    var rhs: SMEntity

    required public init(lhs: SMEntity, rhs: SMEntity) {
        self.lhs = lhs
        self.rhs = rhs
        super.init(type: lhs.type)
    }

//    public override func build() -> SMCode {
//        SMBuilder.buildOperatorCode(lhs: lhs, "/", rhs: rhs)
//    }
    public override func snippet() -> String {
        "(\(lhs.snippet()) / \(rhs.snippet()))"
    }

}
