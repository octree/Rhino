//
//  CSS.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation

public struct Color {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8
}

extension Color: Equatable {
    
    public static func == (lhs: Color, rhs: Color) -> Bool {
        
        return lhs.r == rhs.r &&
            lhs.g == rhs.g &&
            lhs.b == rhs.b &&
            lhs.a == rhs.a
    }
}

/// only support px now
///
public enum Unit {
    case px
//    case percent
//    case em
}

public enum Value {
    case keyword(String)
    case length(Double, Unit)
    case color(Color)
}

extension Value: Equatable {
    
    public static func == (lhs: Value, rhs: Value) -> Bool {
        
        switch (lhs, rhs) {
        case let (.keyword(k1), .keyword(k2)):
            return k1 == k2
        case let (.length(l1, _), .length(l2, _)):
            return l1 == l2
        case let (.color(c1), .color(c2)):
            return c1 == c2
        default:
            return false
        }
    }
}

public struct Declaration {
    public var name: String
    public var value: Value
}

public struct SimpleSelector {
    
    public var tagName: String?
    public var id: String?
    public var cls: [String]
}

public enum Selector {
    
    case simple(SimpleSelector)
}

public struct Rule {
    public var selectors: [Selector]
    public var declarations: [Declaration]
}

public struct StyleSheet {
    
    public var rules: [Rule]
}


/// https://www.w3.org/TR/selectors/#specificity
public typealias Specificity = (UInt8, UInt8, UInt8)

private func count<T>(_ opt: Optional<T>) -> Int {
    
    if case .some(_) = opt {
        return 1
    }
    return 0
}

public extension Selector {
    
    var specificity: Specificity {
        
        if case let .simple(simple) = self {
            
            return (UInt8(count(simple.id)),
                    UInt8(simple.cls.count),
                    UInt8(count(simple.tagName)))
        }
        return (0, 0, 0)
    }
}

public extension Value {
    
    var px: Double {
        
        switch self {
        case let .length(val, _):
            return val
        default:
            return 0
        }
    }
}

/// 为了比较两个 specificity
func specificityToUInt32(_ specificity: Specificity) -> UInt32 {
    
    return (UInt32(specificity.0) << 16) |
        (UInt32(specificity.1) << 8) |
        (UInt32(specificity.2) << 0)
}
