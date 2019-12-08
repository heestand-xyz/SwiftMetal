//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public struct SMArg {
    public let entity: SMEntity
}

public struct SMReturn {
    public let entity: SMEntity
    public init(_ entity: SMEntity) {
        self.entity = entity
    }
}

public class SMRawFunc: Identifiable, Equatable {
    
    public let id: UUID
    
    let function: ([SMArg]) -> (SMReturn)
    
    init(function: @escaping ([SMArg]) -> (SMReturn)) {
        id = UUID()
        self.function = function
    }
    
    public static func == (lhs: SMRawFunc, rhs: SMRawFunc) -> Bool {
        lhs.id == rhs.id
    }
    
}

public class SMFunc<R: SMEntity>: SMRawFunc {

    public init(_ function: @escaping ([SMArg]) -> (SMReturn)) {
        super.init(function: function)
    }

    public func call(_ arguments: SMEntity...) -> R {
        function(arguments.map({ SMArg(entity: $0) })).entity as! R
    }

}

struct SMFunction {
    let argEntities: [SMEntity]
    let returnEntity: SMEntity
    let index: Int
    var name: String {
        return "f\(index)"
    }
    var code: String {
        "..."
    }
}
