//
//  SMFunction.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMRawFunction: Identifiable, Equatable {
    
    public let id: UUID
    
    let function: ([SMEntity]) -> (SMEntity)
    
    public init(_ function: @escaping ([SMEntity]) -> (SMEntity)) {
        id = UUID()
        self.function = function
    }
    
    public func call(_ arguments: SMEntity...) -> SMEntity {
        function(arguments)
    }
    
    public static func == (lhs: SMRawFunction, rhs: SMRawFunction) -> Bool {
        lhs.id == rhs.id
    }
    
}

public class SMFunction<R: SMEntity>: SMRawFunction {

    public init(_ function: @escaping ([SMEntity]) -> (R)) {
        super.init(function)
    }

    public func call(_ arguments: SMEntity...) -> R {
        function(arguments) as! R
    }

}

//struct SMArg {
//    let entity: SMEntity
//}
