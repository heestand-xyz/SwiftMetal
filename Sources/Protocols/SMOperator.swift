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
    
    var value0: V { get }
    var value1: V { get }

    init(_ value0: V, _ value1: V)
}
