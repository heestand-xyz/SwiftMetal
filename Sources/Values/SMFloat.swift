//
//  SMFloat.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMFloat: SMValue {

    public var value: Float
    
    public init(_ value: Float) {
        self.value = value
    }
    
    public func code() -> String {
        String(describing: value)
    }
    
}
