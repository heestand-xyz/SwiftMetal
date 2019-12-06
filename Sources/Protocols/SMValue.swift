//
//  SMValue.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public protocol SMValue: SMBuild {
    
    associatedtype V
    
    var value: V { get }
    
    init(_ value: V)
    
}
