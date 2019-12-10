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
    var uniforms: [SMUniformPack]
    var variables: [SMVariablePack]
    var functions: [SMFunction]
    
    init(_ snippet: String, uniforms: [SMUniformPack], variables: [SMVariablePack], functions: [SMFunction]) {
        self.snippet = snippet
        self.uniforms = uniforms
        self.variables = variables
        self.functions = functions
    }
    
//    init(_ snippet: String) {
//        self.snippet = snippet
//        uniforms = []
//        variables = []
//        functions = []
//    }
    
//    init() {
//        snippet = ""
//        uniforms = []
//        variables = []
//        functions = []
//    }
    
}
