//
//  SMVar.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMVariable {
    let entity: SMEntity
    let index: Int
    var name: String {
        return "v\(index)"
    }
    var code: String {
        "\(entity.type) \(name) = \(entity.snippet());"
    }
}
