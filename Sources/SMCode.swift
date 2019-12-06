//
//  SMCode.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMCode {
    
    public var variables: [SMVariable]
    public var snippet: String
    
    public init(_ snippet: String, variables: [SMVariable] = []) {
        self.variables = variables
        self.snippet = snippet
    }
    
    public init(_ snippet: String) {
        variables = []
        self.snippet = snippet
    }
    
    init() {
        variables = []
        snippet = ""
    }
    
}
