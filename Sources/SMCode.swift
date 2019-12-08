//
//  SMCode.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMCode {
    
    var snippet: String
    var variables: [SMVariable]
    var functions: [SMFunction]
    
    init(_ snippet: String, variables: [SMVariable] = [], functions: [SMFunction] = []) {
        self.snippet = snippet
        self.variables = variables
        self.functions = functions
    }
    
    init(_ snippet: String) {
        self.snippet = snippet
        variables = []
        functions = []
    }
    
    init() {
        snippet = ""
        variables = []
        functions = []
    }
    
}
