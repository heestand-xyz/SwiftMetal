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
        init(entity: SMEntity) {
            self.entity = entity
            branches = entity.children.map { child in
                Branch(entity: child)
            }
        }
        func scanLeafs(_ index: Int = 0) -> Branch? {
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
    
    static func build(for baseEntity: SMEntity) -> SMCode {
        
        let tree: Branch = Branch(entity: baseEntity)
        
        // Uniforms

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
//            let leafs = uniqueFuncBranch.leafs()
//            let argLeafs = leafs.filter({ $0.entity.isArg })
            let argLeafs = uniqueFuncBranch.argLeafs()
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
//            let leafs = funcBranch.leafs()
//            let argLeafs = leafs.filter({ $0.entity.isArg })
            let argLeafs = funcBranch.argLeafs()
            let argEntities = argLeafs.map({ $0.entity })
            let returnEntity = funcBranch.entity
            lastSnippet = lastSnippet.replacingOccurrences(of: returnEntity.snippet(), with: function.snippet(with: argEntities))
        }
        
        // Variables
        
        print("~~~ ~~~ ~~~")
        print(lastSnippet)
        print("~~~ ~~~ ~~~")
        print("<<< <<< <<< A >>> >>> >>>")
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
                        print("DYN", "v\(index)", "<" + leaf.entity.snippet() + ">", "=", "<" + snippet + ">")
                        return snippet
                    })
                    print("while", "<" + leaf.entity.snippet() + ">", "var", "<" + variable.rawCode + ">", "-->", "<" + variable.code + ">")
                    leaf.variable = variable
                    variable.lock()
//                    for branch in variableBranchCopies {
//                        guard branch != leaf else { break }
//                        if branch.entity == leaf.entity {
//                            branch.variable = variable
//                            break
//                        }
//                    }
                    variables.append(variable)
                    lastSnippet = lastSnippet.replacingOccurrences(of: leaf.entity.snippet(), with: variable.name)
//                    print("~~~ ~~~ ~~~")
//                    variables.forEach { variable in
//                        print("~~~", "v\(variable.index)", "<" + variable.code + ">")
//                    }
//                    print(lastSnippet)
//                    print("~~~ ~~~ ~~~")
                } else {
                    print("while", "<" + leaf.entity.snippet() + ">", "old")
                    // ...
                }
            } else {
                print("while", "<" + leaf.entity.snippet() + ">", "new")
                variableBranchCopies.append(leaf)
            }
        }
        print("<<< <<< <<< B >>> >>> >>>")
//        variables.forEach({ $0.unlock() })
//        print("+++ UNLOK +++")
        print("~~~ ~~~ ~~~")
        variables.forEach { variable in
            print("~~~", "v\(variable.index)", "<" + variable.code + ">")
        }
        print(lastSnippet)
        print("~~~ ~~~ ~~~")
        print("=== === ===")
        while let leaf = tree.scanLeafs(2) {
            if let variable = leaf.variable {
                guard !variable.snippet.starts(with: "v") else { continue }
                print(">>>", "v\(variable.index)", "<" + variable.snippet + ">", "-->", "<" + variable.name + ">")
                lastSnippet = lastSnippet.replacingOccurrences(of: variable.snippet, with: variable.name)
            }
        }
        print("~~~ ~~~ ~~~")
        variables.forEach { variable in
            print("~~~", "v\(variable.index)", "<" + variable.code + ">")
        }
        print(lastSnippet)
        print("~~~ ~~~ ~~~")
        print("CLEAN")
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
            if !used && !lastSnippet.contains(variable.name) {
                variables.remove(at: ir)
            }
        }
        print("~~~ ~~~ ~~~")
        variables.forEach { variable in
            print("~~~", "v\(variable.index)", "<" + variable.code + ">")
        }
        print(lastSnippet)
        print("~~~ ~~~ ~~~")
        print("<<< <<< <<< C >>> >>> >>>")
        
        return SMCode(lastSnippet, uniforms: uniforms, variables: variables, functions: functions)
        
    }
    
}
