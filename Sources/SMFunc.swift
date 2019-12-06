//
//  SMFunc.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
//import Metal

public struct SMFunc {
    
//    public typealias V = SMFloat4
    
    let code: SMCode
    
    public init(_ code: SMCode) {
        self.code = code
    }
    
    public func make() -> String {
        code.code()
    }
    
}
