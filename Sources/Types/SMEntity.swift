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
    
    let isFuture: Bool
    var futureSnippet: String {
        "future\(id.uuidString.split(separator: "-").first!)"
    }
    
    var subscriptEntity: SMEntity?
    
    var sampleTexture: SMTexture?
    var sampleUV: SMFloat2?
    
    let fromEntities: [SMEntity]
    
    var children: [SMEntity] {
        var children: [SMEntity] = [
            operation?.lhs,
            operation?.rhs,
            subscriptEntity,
            sampleTexture,
            sampleUV
        ]
            .compactMap({ $0 })
        children.append(contentsOf: fromEntities)
        return children
    }
    
    init(type: String, operation: SMOperation? = nil, isFuture: Bool = false, fromEntities: [SMEntity] = []) {
        id = UUID()
        self.type = type
        self.operation = operation
        self.isFuture = isFuture
        self.fromEntities = fromEntities
        if isFuture {
            snippet = { self.futureSnippet }
        }
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: SMEntity, rhs: SMEntity) -> Bool {
        lhs.id == rhs.id
    }
       
}
