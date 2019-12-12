//
//  Types.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

#if os(macOS)
public typealias _View = NSView
public typealias _Image = NSImage
public typealias _Color = NSColor
#else
public typealias _View = UIView
public typealias _Image = UIImage
public typealias _Color = UIColor
#endif

class SMVariablePack {
    let entity: SMEntity
    let index: Int
    fileprivate let dynamicSnippet: () -> (String)
    fileprivate var lockedSnippet: String?
    var snippet: String {
        lockedSnippet ?? dynamicSnippet()
    }
    var name: String {
        return "v\(index)"
    }
    var code: String {
        code(with: snippet)
    }
    var rawCode: String {
        code(with: entity.snippet())
    }
    init(for entity: SMEntity, at index: Int, with dynamicSnippet: @escaping () -> (String)) {
        self.entity = entity
        self.index = index
        self.dynamicSnippet = dynamicSnippet
    }
    func lock() {
        lockedSnippet = dynamicSnippet()
    }
    func unlock() {
        lockedSnippet = nil
    }
    fileprivate func code(with snippet: String) -> String {
        "\(entity.type) \(name) = \(snippet);"
    }
}

struct SMUniformPack {
    let entity: SMEntity
    let index: Int
    var name: String {
        return "u\(index)"
    }
    var code: String {
        "\(entity.type) \(name);"
    }
    var snippet: String {
        "us.\(name)"
    }
}

struct SMOperation {
    let lhs: SMEntity
    let rhs: SMEntity
}

public protocol SMRaw {}
public protocol SMRawType: SMRaw {}

public class SMTuple<RT: SMRawType>: SMRaw {
    let values: [SMValue<RT>]
    var count: Int { values.count }
    init(_ values: [SMValue<RT>]) {
        self.values = values
    }
}

public class SMTuple2<RT: SMRawType>: SMTuple<RT> {
    let value0: SMValue<RT>
    let value1: SMValue<RT>
    init(_ value0: SMValue<RT>,
         _ value1: SMValue<RT>) {
        self.value0 = value0
        self.value1 = value1
        super.init([value0, value1])
    }
}

public class SMTuple3<RT: SMRawType>: SMTuple<RT> {
    let value0: SMValue<RT>
    let value1: SMValue<RT>
    let value2: SMValue<RT>
    init(_ value0: SMValue<RT>,
         _ value1: SMValue<RT>,
         _ value2: SMValue<RT>) {
        self.value0 = value0
        self.value1 = value1
        self.value2 = value2
        super.init([value0, value1, value2])
    }
}

public class SMTuple4<RT: SMRawType>: SMTuple<RT> {
    let value0: SMValue<RT>
    let value1: SMValue<RT>
    let value2: SMValue<RT>
    let value3: SMValue<RT>
    init(_ value0: SMValue<RT>,
         _ value1: SMValue<RT>,
         _ value2: SMValue<RT>,
         _ value3: SMValue<RT>) {
        self.value0 = value0
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        super.init([value0, value1, value2, value3])
    }
}

struct Line {
    let indent: Int
    let snippet: String
    init(in indent: Int = 0, _ snippet: String = "") {
        self.indent = indent
        self.snippet = snippet
    }
    static func merge(_ lines: [Line]) -> String {
        lines.map({ line -> String in
            var row = ""
            for _ in 0..<line.indent {
                row += "    "
            }
            row += line.snippet;
            return row
        }).joined(separator: "\n") + "\n"
    }
}

public class SMUV: SMFloat2 {
    public init() {
        super.init(tupleCount: 2)
        snippet = { "uv" }
    }
    required public convenience init(floatLiteral value: Float) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
    required public convenience init(integerLiteral value: Int) {
        fatalError("init(integerLiteral:) has not been implemented")
    }
}

struct Snippet {
    static func functionSnippet(name: String, from entities: [SMEntity]) -> String {
        var snippet: String = ""
        snippet += "\(name)("
        for (i, entity) in entities.enumerated() {
            if i > 0 {
                snippet += ", "
            }
            snippet += entity.snippet()
        }
        snippet += ")"
        return snippet
    }
}
