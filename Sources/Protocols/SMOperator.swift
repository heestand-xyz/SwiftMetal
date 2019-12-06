//
//  SMOperator.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

protocol SMOperator: SMBuild {
    
    var lhs: SMEntity { get }
    var rhs: SMEntity { get }

    init(lhs: SMEntity, rhs: SMEntity)
}
