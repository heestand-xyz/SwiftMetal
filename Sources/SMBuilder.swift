//
//  SMBuilder.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMBuilder {
    
    class Branch {
        var hit: Bool = false
        let entity: SMEntity
        var branches: [Branch] = []
        init(entity: SMEntity) {
            self.entity = entity
            if let entityOperator = entity as? SMOperator {
                branches.append(Branch(entity: entityOperator.lhs))
                branches.append(Branch(entity: entityOperator.rhs))
            }
        }
        func leafEntity() -> SMEntity? {
            guard !hit else { return nil }
            for branch in branches {
                if let hitEntity = branch.leafEntity() {
                    return hitEntity
                }
            }
            hit = true
            return entity
        }
    }
    
    static func textures(for baseEntity: SMEntity) -> [SMTexture] {
        
        var textures: [SMTexture] = []
        
        let tree: Branch = Branch(entity: baseEntity)
        
        while let leafEntity = tree.leafEntity() {
            if let texture = leafEntity as? SMTexture {
                if !textures.contains(texture) {
                    textures.append(texture)
                }
            }
        }
        
        return textures
        
    }
    
    static func build(for baseEntity: SMEntity) -> SMCode {
        
        let tree: Branch = Branch(entity: baseEntity)
        
        var entities: [SMEntity] = []
        
        var variables: [SMVariable] = []
        var lastSnippet: String = baseEntity.snippet()
        
        while let leafEntity = tree.leafEntity() {
            if entities.contains(leafEntity) {
                if !variables.contains(where: { variable -> Bool in
                    variable.entity == leafEntity
                }) {
                    let variable = SMVariable(entity: leafEntity, index: variables.count)
                    variables.append(variable)
                    lastSnippet = lastSnippet.replacingOccurrences(of: leafEntity.snippet(), with: variable.name)
                }
            } else {
                entities.append(leafEntity)
            }
        }
        
        return SMCode(lastSnippet, variables: variables)
        
    }
    
//    static func buildOperatorCode(lhs: SMEntity, _ operation: String, rhs: SMEntity) -> SMCode {
//
//        let lhsCode: SMCode = lhs.build()
//        let rhsCode: SMCode = rhs.build()
//
//        let variableCount = lhsCode.variables.count + rhsCode.variables.count
//
//        if lhs == rhs {
//
//            var variables: [SMVariable] = []
//            variables.append(contentsOf: lhsCode.variables)
//            let variable = SMVariable(id: lhs.id, snippet: lhsCode.snippet, type: lhs.type, index: variableCount)
//            variables.append(variable)
//            return SMCode("(\(variable.name) \(operation) \(variable.name))", variables: variables)
//
//        } else if let variable = rhsCode.variables.filter({ variable -> Bool in
//            variable.id == lhs.id
//        }).first {
//
//            var variables: [SMVariable] = []
//            variables.append(contentsOf: lhsCode.variables)
//            variables.append(contentsOf: rhsCode.variables)
//            return SMCode("(\(variable.name) \(operation) \(rhsCode.snippet))", variables: variables)
//
//        } else if let variable = lhsCode.variables.filter({ variable -> Bool in
//            variable.id == rhs.id
//        }).first {
//
//            var variables: [SMVariable] = []
//            variables.append(contentsOf: lhsCode.variables)
//            variables.append(contentsOf: rhsCode.variables)
//            return SMCode("(\(lhsCode.snippet) \(operation) \(variable.name))", variables: variables)
//
//        } else if crawlForEntity(with: rhs.id, in: lhs) {
//
//            var variables: [SMVariable] = []
//            variables.append(contentsOf: lhsCode.variables)
//            variables.append(contentsOf: rhsCode.variables)
//            let variable = SMVariable(id: rhs.id, snippet: rhsCode.snippet, type: rhs.type, index: variableCount)
//            variables.append(variable)
//            let lhsSnippet = lhsCode.snippet.replacingOccurrences(of: rhsCode.snippet, with: variable.name)
//            return SMCode("(\(lhsSnippet) \(operation) \(variable.name))", variables: variables)
//
//        } else if crawlForEntity(with: lhs.id, in: rhs) {
//
//            var variables: [SMVariable] = []
//            variables.append(contentsOf: lhsCode.variables)
//            variables.append(contentsOf: rhsCode.variables)
//            let variable = SMVariable(id: lhs.id, snippet: lhsCode.snippet, type: lhs.type, index: variableCount)
//            variables.append(variable)
//            let rhsSnippet = rhsCode.snippet.replacingOccurrences(of: lhsCode.snippet, with: variable.name)
//            return SMCode("(\(variable.name) \(operation) \(rhsSnippet))", variables: variables)
//
//        } else {
//
//        var variables: [SMVariable] = []
//        variables.append(contentsOf: lhsCode.variables)
//        variables.append(contentsOf: rhsCode.variables)
//        return SMCode("(\(lhsCode.snippet) \(operation) \(rhsCode.snippet))", variables: variables)
//
//        }
//    }
//    
//    static func crawlForEntity(with id: UUID, in entity: SMEntity) -> Bool {
//        if id == entity.id {
//            return true
//        }
//        if let entityOperator = entity as? SMOperator {
//            return crawlForEntity(with: id, in: entityOperator.lhs) ?? crawlForEntity(with: id, in: entityOperator.rhs)
//        }
//        return false
//    }
    
}
