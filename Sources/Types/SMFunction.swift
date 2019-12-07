//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

class SMFunction<OUT: SMEntity, IN>: SMEntity {
    
    init(_ function: (IN) -> (OUT)) {
        super.init(type: "xyz")
    }
    
}
