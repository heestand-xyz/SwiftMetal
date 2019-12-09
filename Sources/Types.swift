//
//  Types.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMVariable {
    let entity: SMEntity
    let index: Int
    var name: String {
        return "v\(index)"
    }
    var code: String {
        "\(entity.type) \(name) = \(entity.snippet());"
    }
}

struct SMUniform {
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

public class SMTuple<T: SMRaw>: SMRaw {}

public class SMTuple2<T: SMRaw>: SMTuple<T> {
    let value0: SMValue<T>
    let value1: SMValue<T>
    init(_ value0: SMValue<T>,
         _ value1: SMValue<T>) {
        self.value0 = value0
        self.value1 = value1
    }
}

public class SMTuple3<T: SMRaw>: SMTuple<T> {
    let value0: SMValue<T>
    let value1: SMValue<T>
    let value2: SMValue<T>
    init(_ value0: SMValue<T>,
         _ value1: SMValue<T>,
         _ value2: SMValue<T>) {
        self.value0 = value0
        self.value1 = value1
        self.value2 = value2
    }
}

public class SMTuple4<T: SMRaw>: SMTuple<T> {
    let value0: SMValue<T>
    let value1: SMValue<T>
    let value2: SMValue<T>
    let value3: SMValue<T>
    init(_ value0: SMValue<T>,
         _ value1: SMValue<T>,
         _ value2: SMValue<T>,
         _ value3: SMValue<T>) {
        self.value0 = value0
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
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
    public override init() {
        super.init()
        snippet = { "uv" }
    }
    required public convenience init(floatLiteral value: T) {
        fatalError("init(floatLiteral:) has not been implemented")
    }
}
