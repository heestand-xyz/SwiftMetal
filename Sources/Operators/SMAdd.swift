//
//  SMAdd.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMAdd<V: SMValue>: SMOperator {
    
    var value0: V
    var value1: V

    public init(_ value0: V, _ value1: V) {
        self.value0 = value0
        self.value1 = value1
    }

    public func code() -> String {
        "\(value0.code()) + \(value1.code())"
    }

}
