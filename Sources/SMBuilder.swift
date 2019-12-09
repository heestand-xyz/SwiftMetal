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
        var hitCount: Int = 0
        let entity: SMEntity
        var branches: [Branch] = []
        init(entity: SMEntity) {
            self.entity = entity
            if let operation = entity.operation {
                branches.append(Branch(entity: operation.lhs))
                branches.append(Branch(entity: operation.rhs))
            }
        }
        func leafEntity(_ index: Int = 0) -> SMEntity? {
            guard hitCount < index + 1 else { return nil }
            for branch in branches {
                if let hitEntity = branch.leafEntity(index) {
                    return hitEntity
                }
            }
            hitCount += 1
            return entity
        }
        func funcBranches() -> [Branch] {
            var funcBranches: [Branch] = []
            if let branch = funcRootBranch() {
                funcBranches.append(branch)
                return funcBranches
            }
            for branch in self.branches {
                let subBranches = branch.funcBranches()
                funcBranches.append(contentsOf: subBranches)
            }
            return funcBranches
        }
        func funcRootBranch() -> Branch? {
            guard entity.isReturn else { return nil }
            return funcLeafBranch()
        }
        func funcLeafBranch() -> Branch? {
            let root = Branch(entity: entity)
            guard !entity.isArg else { return root }
            var leafs: [Branch] = []
            for branch in self.branches {
                if let leaf = branch.funcLeafBranch() {
                    leafs.append(leaf)
                }
            }
            root.branches = leafs
            return root
        }
        func leafs() -> [Branch] {
            guard !isLeaf() else {
                return [self]
            }
            var leafs: [Branch] = []
            for branch in self.branches {
                if branch.isLeaf() {
                    leafs.append(branch)
                } else {
                    let subLeafs = branch.leafs()
                    leafs.append(contentsOf: subLeafs)
                }
            }
            return leafs
        }
        func isLeaf() -> Bool {
            branches.isEmpty
        }
        static func sameSignature(lhs: Branch, rhs: Branch) -> Bool {
            guard lhs.entity.isReturn && rhs.entity.isReturn else { return false }
            guard lhs.entity.returnId! == rhs.entity.returnId! else { return false }
            // TODO: - The ID is all we need...
//            guard lhs.entity.type == rhs.entity.type else { return false }
//            let lhsLeafs = lhs.leafs().filter({ $0.entity.isArg })
//            let rhsLeafs = rhs.leafs().filter({ $0.entity.isArg })
//            guard lhsLeafs.count == rhsLeafs.count else { return false }
//            guard zip(lhs.leafs(), rhs.leafs()).filter({ arg -> Bool in
//                let (lhsLeaf, rhsLeaf) = arg
//                return lhsLeaf.entity.type == rhsLeaf.entity.type
//            }).count == lhsLeafs.count else { return false }
            return true
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
        var lastSnippet: String = baseEntity.snippet()
        
        /// Functions

        var functions: [SMFunction] = []
        let funcBranchs: [Branch] = tree.funcBranches()
        var uniqueFuncBranchs: [Branch] = []
        for funcBranch in funcBranchs {
            var exists = false
            for uniqueFuncBranch in uniqueFuncBranchs {
                if Branch.sameSignature(lhs: funcBranch, rhs: uniqueFuncBranch) {
                    exists = true
                    break
                }
            }
            if !exists {
                uniqueFuncBranchs.append(funcBranch)
            }
        }
        for uniqueFuncBranch in uniqueFuncBranchs {
            let leafs = uniqueFuncBranch.leafs()
            let argLeafs = leafs.filter({ $0.entity.isArg })
            let argEntities = argLeafs.map({ $0.entity })
            let returnEntity = uniqueFuncBranch.entity
            let function = SMFunction(argEntities: argEntities, returnEntity: returnEntity, index: functions.count)
            functions.append(function)
        }
        for funcBranch in funcBranchs {
            var function: SMFunction!
            for (i, uniqueFuncBranch) in uniqueFuncBranchs.enumerated() {
                if Branch.sameSignature(lhs: funcBranch, rhs: uniqueFuncBranch) {
                    function = functions[i]
                    break
                }
            }
            let leafs = funcBranch.leafs()
            let argLeafs = leafs.filter({ $0.entity.isArg })
            let argEntities = argLeafs.map({ $0.entity })
            let returnEntity = funcBranch.entity
            lastSnippet = lastSnippet.replacingOccurrences(of: returnEntity.snippet(), with: function.snippet(with: argEntities))
        }
        
        // Variables
        
        var variableEntitieCopies: [SMEntity] = []
        var variables: [SMVariable] = []
        while let leafEntity = tree.leafEntity() {
            if variableEntitieCopies.contains(leafEntity) {
                if !variables.contains(where: { variable -> Bool in
                    variable.entity == leafEntity
                }) {
                    let variable = SMVariable(entity: leafEntity, index: variables.count)
                    variables.append(variable)
                    lastSnippet = lastSnippet.replacingOccurrences(of: leafEntity.snippet(), with: variable.name)
                }
            } else {
                variableEntitieCopies.append(leafEntity)
            }
        }
        
        // Uniforms
        
        var uniforms: [SMUniform] = []
        while let leafEntity = tree.leafEntity(1) {
            if leafEntity.isFuture {
//                if !uniforms.contains(where: { $0.entity == leafEntity }) {
                    let uniform = SMUniform(entity: leafEntity, index: uniforms.count)
                    uniforms.append(uniform)
//                }
            }
        }
        for uniform in uniforms {
            lastSnippet = lastSnippet.replacingOccurrences(of: uniform.entity.futureSnippet, with: uniform.snippet)
        }
        
        return SMCode(lastSnippet, uniforms: uniforms, variables: variables, functions: functions)
        
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
