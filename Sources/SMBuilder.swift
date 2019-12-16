//
//  SMBuilder.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMBuilder {
    
    class Branch: Equatable {
        var hitCount: Int = 0
        let entity: SMEntity
        var variable: SMVariablePack?
        var branches: [Branch] = []
        init(entity: SMEntity, limit: ((SMEntity) -> (Bool))? = nil) {
            self.entity = entity
            branches = entity.children.compactMap { child in
                if limit == nil || !limit!(child) {
                    return Branch(entity: child, limit: limit)
                }
                return nil
            }
        }
        func scanLeafs(_ index: Int) -> Branch? {
            guard hitCount < index + 1 else { return nil }
            for branch in branches {
                if let hitEntity = branch.scanLeafs(index) {
                    return hitEntity
                }
            }
            hitCount += 1
            return self
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
        func argLeafs() -> [Branch] {
            guard !isArgLeaf() else {
                return [self]
            }
            var leafs: [Branch] = []
            for branch in self.branches {
                if branch.isArgLeaf() {
                    leafs.append(branch)
                } else {
                    let subLeafs = branch.argLeafs()
                    leafs.append(contentsOf: subLeafs)
                }
            }
            return leafs
        }
        func isArgLeaf() -> Bool {
            entity.isArg
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
        func log() -> String {
            return log(indent: 0)
        }
        func log(indent: Int) -> String {
            var log = "\n"
            for _ in 0..<indent {
                log += "    "
            }
            log += "\(variable?.name ?? "<\(entity.isArg ? "a" : "-")>")"
            for branch in branches {
                log += branch.log(indent: indent + 1)
            }
            return log
        }
        static func == (lhs: Branch, rhs: Branch) -> Bool {
            lhs.entity == rhs.entity
        }
    }
    
    static func connectSinks(for baseEntity: SMEntity, sinked: @escaping () -> ()) {
                
        let tree: Branch = Branch(entity: baseEntity)
        
        while let leafEntity = tree.leafEntity() {
            if leafEntity.hasSink {
                leafEntity.sink = {
                    sinked()
                }
            }
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
        
        for (i, texture) in textures.enumerated() {
            texture.index = i
        }
        
        return textures
        
    }
    
    // MARK: - Build
    
    static func build(for baseEntity: SMEntity) -> SMCode {
        
        let tree: Branch = Branch(entity: baseEntity)
        var baseSnippet: String = baseEntity.snippet()

        let uniforms: [SMUniformPack] = buildUniforms(tree: tree)
        let functions: [SMFunction] = buildFunctions(tree: tree, with: &baseSnippet)
        let variables: [SMVariablePack] = buildVaraibles(tree: tree, with: &baseSnippet)
        let regexVariables: [SMVariablePack] = buildRegexVaraibles(tree: tree, from: variables, with: &baseSnippet)
        
        return SMCode(snippet: baseSnippet, uniforms: uniforms, variables: variables, regexVariables: regexVariables, functions: functions)
        
    }
    
    static func buildUniforms(tree: Branch) -> [SMUniformPack] {
        var uniforms: [SMUniformPack] = []
        while let leafEntity = tree.leafEntity(0) {
            if leafEntity.isFuture && !(leafEntity is SMTexture) {
                if !uniforms.contains(where: { $0.entity == leafEntity }) {
                    leafEntity.futureIndex = uniforms.count
                    let uniform = SMUniformPack(entity: leafEntity, index: uniforms.count)
                    uniforms.append(uniform)
                }
            }
        }
        return uniforms
    }
    
    static func buildFunctions(tree: Branch, with baseSnippet: inout String) -> [SMFunction] {
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
            let argLeafs: [Branch] = uniqueFuncBranch.argLeafs()
            let argEntities: [SMEntity] = argLeafs.map({ $0.entity })
            var uniqueArgEntities: [SMEntity] = []
            for argEntity in argEntities {
                if !uniqueArgEntities.contains(argEntity) {
                    uniqueArgEntities.append(argEntity)
                }
            }
            let returnEntity = uniqueFuncBranch.entity
            let function = SMFunction(argEntities: uniqueArgEntities, returnEntity: returnEntity, index: functions.count)
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
            let argLeafs = funcBranch.argLeafs()
            let argEntities = argLeafs.map({ $0.entity })
            var uniqueArgEntities: [SMEntity] = []
            for argEntity in argEntities {
                if !uniqueArgEntities.contains(argEntity) {
                    uniqueArgEntities.append(argEntity)
                }
            }
            let returnEntity = funcBranch.entity
            baseSnippet = baseSnippet.replacingOccurrences(of: returnEntity.snippet(), with: function.snippet(with: uniqueArgEntities))
        }
        return functions
    }
    
    static func buildVaraibles(tree: Branch, with baseSnippet: inout String) -> [SMVariablePack] {
        var variableBranchCopies: [Branch] = []
        var variables: [SMVariablePack] = []
        while let leaf = tree.scanLeafs(1) {
            if variableBranchCopies.contains(leaf) {
                if !variables.contains(where: { variable -> Bool in
                    variable.entity == leaf.entity
                }) {
                    let index = variables.count
                    let variable = SMVariablePack(for: leaf.entity, at: index, with: {
                        var snippet: String = leaf.entity.snippet()
                        for subVariable in variables {
                            guard subVariable.entity != leaf.entity else { continue }
                            snippet = snippet.replacingOccurrences(of: subVariable.entity.snippet(), with: subVariable.name)
                        }
                        return snippet
                    }())
                    leaf.variable = variable
                    variables.append(variable)
                    baseSnippet = baseSnippet.replacingOccurrences(of: leaf.entity.snippet(), with: variable.name)
                }
            } else {
                variableBranchCopies.append(leaf)
            }
        }
        while let leaf = tree.scanLeafs(2) {
            if let variable = leaf.variable {
                guard !variable.snippet.starts(with: "v") else { continue }
                baseSnippet = baseSnippet.replacingOccurrences(of: variable.snippet, with: variable.name)
            }
        }
        /// Clean
        // TODO - Fix case where v10 is mistaken for v1, as we get unused variables in metal code.
        let count = variables.count
        for i in 0..<count {
            let ir = count - i - 1
            let variable = variables[ir]
            var used = false
            for subVariable in variables {
                guard subVariable.entity != variable.entity else { continue }
                if subVariable.snippet.contains(variable.name) {
                    used = true
                    break
                }
            }
            if !used && !baseSnippet.contains(variable.name) {
                variables.remove(at: ir)
            }
        }
        return variables
    }
    
    static func buildRegexVaraibles(tree: Branch, from previusVariables: [SMVariablePack], with baseSnippet: inout String) -> [SMVariablePack] {
        var variables: [SMVariablePack] = []
        while true {
            let range = NSRange(location: 0, length: baseSnippet.utf16.count)
            let regex = try! NSRegularExpression(pattern: "(\\((?:\\1??[^\\(]*?\\)))+")
            let results: [NSTextCheckingResult] = regex.matches(in: baseSnippet, options: [], range: range)
            let rawResults: [String] = results.map { result -> String in
                baseSnippet[result.range.lowerBound..<result.range.upperBound]
            }
            var duplicateResults: [String] = []
            var checkedResults: [String] = []
            for rawResult in rawResults {
                guard !rawResult.contains(",") else { continue }
                if checkedResults.contains(rawResult) {
                    if !duplicateResults.contains(rawResult) {
                        var exists = false
                        for pastVariable in variables {
                            if pastVariable.code.contains(rawResult) {
                                exists = true
                                break
                            }
                        }
                        if !exists {
                            duplicateResults.append(rawResult)
                        }
                    }
                    continue
                }
                checkedResults.append(rawResult)
            }
            guard !duplicateResults.isEmpty else { break }
            for duplicateResult in duplicateResults {
                // FIXME: - Find the real entity.
                var firstEntity: SMEntity!
                let vn0 = duplicateResult.dropFirst()
                let vn1 = vn0.split(separator: " ").first!
                let vn2 = vn1.split(separator: ",").first!
                let variableName: String = String(vn2)
                for previusVariable in previusVariables {
                    if variableName == previusVariable.name {
                        firstEntity = previusVariable.entity
                        break
                    }
                }
                if firstEntity == nil {
                    for pastVariable in variables {
                        if variableName == pastVariable.name {
                            firstEntity = pastVariable.entity
                            break
                        }
                    }
                }
                let variable = SMVariablePack(shortCode: "r", for: firstEntity, at: variables.count, with: duplicateResult)
                variables.append(variable)
                baseSnippet = baseSnippet.replacingOccurrences(of: duplicateResult, with: variable.name)
            }
        }
        return variables
    }
    
}
