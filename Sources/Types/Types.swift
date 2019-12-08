//
//  Types.swift
//  SwiftMetal
//
//  Created by Hexagons on 2019-12-08.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

struct SMOperation {
    let lhs: SMEntity
    let rhs: SMEntity
}

public protocol SMRaw {}

public class SMTuple: SMRaw {}

public class SMTuple2<T: SMRaw>: SMTuple {
    let value0: SMValue<T>
    let value1: SMValue<T>
    init(_ value0: SMValue<T>,
         _ value1: SMValue<T>) {
        self.value0 = value0
        self.value1 = value1
    }
}

public class SMTuple3<T: SMRaw>: SMTuple {
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

public class SMTuple4<T: SMRaw>: SMTuple {
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
