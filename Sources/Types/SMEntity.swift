//
//  SMEntity.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMEntity: SMBuild, Identifiable, Equatable {
    
    public let id: UUID
    
    let type: String
    
    init(type: String) {
        id = UUID()
        self.type = type
    }
   
//    public func build() -> SMCode { SMCode() }
    public func snippet() -> String { "" }
    
    static func + (lhs: SMEntity, rhs: SMEntity) -> SMAdd {
        SMAdd(lhs: lhs, rhs: rhs)
    }
    static func + (lhs: SMEntity, rhs: Float) -> SMAdd {
        SMAdd(lhs: lhs, rhs: SMFloat(rhs))
    }
    static func + (lhs: Float, rhs: SMEntity) -> SMAdd {
        SMAdd(lhs: SMFloat(lhs), rhs: rhs)
    }
    
    static func - (lhs: SMEntity, rhs: SMEntity) -> SMSubtract {
        SMSubtract(lhs: lhs, rhs: rhs)
    }
    static func - (lhs: SMEntity, rhs: Float) -> SMSubtract {
        SMSubtract(lhs: lhs, rhs: SMFloat(rhs))
    }
    static func - (lhs: Float, rhs: SMEntity) -> SMSubtract {
        SMSubtract(lhs: SMFloat(lhs), rhs: rhs)
    }
    
    static func * (lhs: SMEntity, rhs: SMEntity) -> SMMultiply {
        SMMultiply(lhs: lhs, rhs: rhs)
    }
    static func * (lhs: SMEntity, rhs: Float) -> SMMultiply {
        SMMultiply(lhs: lhs, rhs: SMFloat(rhs))
    }
    static func * (lhs: Float, rhs: SMEntity) -> SMMultiply {
        SMMultiply(lhs: SMFloat(lhs), rhs: rhs)
    }
    
    static func / (lhs: SMEntity, rhs: SMEntity) -> SMDivide {
        SMDivide(lhs: lhs, rhs: rhs)
    }
    static func / (lhs: SMEntity, rhs: Float) -> SMDivide {
        SMDivide(lhs: lhs, rhs: SMFloat(rhs))
    }
    static func / (lhs: Float, rhs: SMEntity) -> SMDivide {
        SMDivide(lhs: SMFloat(lhs), rhs: rhs)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: SMEntity, rhs: SMEntity) -> Bool {
        lhs.id == rhs.id
    }
       
}
