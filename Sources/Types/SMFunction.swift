//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMFunction<OUT: SMEntity> {
    
    let function: ([SMEntity]) -> (OUT)
    
    public init(_ function: @escaping ([SMEntity]) -> (OUT)) {
        self.function = function
    }
    
    public func call(_ arguments: SMEntity...) -> OUT {
        function(arguments)
    }
    
}
