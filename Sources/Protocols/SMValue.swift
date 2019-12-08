//
//  SMValue.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public protocol SMValue: SMBuild {

    associatedtype V

    var value: V { get }

}


public protocol SMValueConstant: SMValue {

    init(_ value: V)

}


public protocol SMValueVaraible: SMValue {

    init(_ futureValue: @escaping () -> (V))

}

//public class SMValue<V>: SMEntity {
//
//    init() {
//        super.init(type: "float")
//    }
//
//    public override func snippet() -> String {
//        String(describing: value)
//    }
//
//}
//
//
//public class SMValueConstant<V>: SMValue<V>, ExpressibleByFloatLiteral {
//
//    public let value: V
//
//    required public init(_ value: V) {
//        self.value = value
//    }
//
//    required public init(floatLiteral value: V) {
//        self.value = value
//    }
//
//}
//
//
//public class SMValueVaraible<V>: SMValue<V> {
//
//    let futureValue: () -> (V)
//    public var value: V {
//        futureValue()
//    }
//
//    public required init(_ futureValue: @escaping () -> (V)) {
//        self.futureValue = futureValue
//    }
//
//}
