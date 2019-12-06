//
//  SMOperator.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

protocol SMOperator: SMCode {
    
    associatedtype V
    
    var lhs: V { get }
    var rhs: V { get }

    init(lhs: V, rhs: V)
}
