//
//  SMEntity.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMEntity: Identifiable, Equatable {
    
    public let id: UUID
    
    let type: String
    
    public var snippet: () -> (String) = { "#" }
    
    let operation: SMOperation?
    var isArg: Bool = false
    var returnId: UUID?
    var isReturn: Bool { returnId != nil }
    
    init(type: String, operation: SMOperation? = nil) {
        id = UUID()
        self.type = type
        self.operation = operation
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: SMEntity, rhs: SMEntity) -> Bool {
        lhs.id == rhs.id
    }
       
}
