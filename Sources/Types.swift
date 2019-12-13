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
    let snippet: String
    var name: String {
        return "v\(index)"
    }
    var code: String {
        code(with: snippet)
    }
//    var rawCode: String {
//        code(with: entity.snippet())
//    }
    init(for entity: SMEntity, at index: Int, with snippet: String) {
        self.entity = entity
        self.index = index
        self.snippet = snippet
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
public protocol SMRawType: SMRaw {
    static var typeName: String { get }
}

public class SMTuple<RT: SMRawType>: SMRaw {
    let values: [SMValue<RT>]
    var count: Int { values.count }
    init(_ values: [SMValue<RT>]) {
        self.values = values
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
        super.init()
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

extension String {

    public subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    public subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

}
