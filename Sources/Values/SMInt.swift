//
//  SMInt.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMInt: SMValue {
    
    public var value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public func code() -> String {
        String(describing: value)
    }
    
}
