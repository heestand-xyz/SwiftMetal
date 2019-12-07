//
//  SMInt.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public class SMInt: SMEntity, SMValue, ExpressibleByIntegerLiteral {
        
    let futureValue: () -> (Int)
    public var value: Int {
        futureValue()
    }
    
    required public init(_ value: Int) {
        self.futureValue = { value }
        super.init(type: "int")
    }
    
    public required init(_ futureValue: @escaping () -> (Int)) {
        self.futureValue = futureValue
        super.init(type: "int")
    }
    
    required public init(integerLiteral value: Int) {
        self.futureValue = { value }
        super.init(type: "int")
    }
    
//    public override func build() -> SMCode {
//        SMCode(String(describing: value))
//    }
    public override func snippet() -> String {
        String(describing: value)
    }
    
}
