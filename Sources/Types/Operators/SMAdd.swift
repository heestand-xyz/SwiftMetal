//
//  SMAdd.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMAdd: SMType, SMOperator {
    
    var lhs: SMCode
    var rhs: SMCode

    required public init(lhs: SMCode, rhs: SMCode) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public override func code() -> String {
        "\(lhs.code()) + \(rhs.code())"
    }

}
