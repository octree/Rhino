//
//  Style.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation

/// key: CSS property name
/// value: CSS property value
public typealias PropertyMap = [String: Value]

public final class StyledTreeBuilder {
    
    public static func buildStyledTree(root: Node, stylesheet: StyleSheet) -> StyledNode {
        
        var map: PropertyMap = [:]
        if case let .element(elt) = root.nodeType {
            
            map = elt.specifiedValues(stylesheet: stylesheet)
        }
        
        let children = root.children.map { buildStyledTree(root: $0, stylesheet: stylesheet) }
        return StyledNode(node: root,
                          specifiedValues: map,
                          children: children)
    }
}

public class StyledNode {
    
    public let node: Node
    public let specifiedValues: PropertyMap
    public let children: [StyledNode]
    public init(node: Node, specifiedValues: PropertyMap, children: [StyledNode]) {
        
        self.node = node
        self.specifiedValues = specifiedValues
        self.children = children
    }
}

extension ElementData {
    
    
    /// 检查是否与 simple selector 匹配
    ///
    /// - Parameter selector: SimpleSelector
    /// - Returns: 如果匹配返回 true，否则 false
    func isMatchSimpleSelector(_ selector: SimpleSelector) -> Bool {
        
        // selector 有 tagname 并且与 element 不相等
        if let stagName = selector.tagName, stagName != tagName {
            
            return false
        }
        
        if let sid = selector.id, sid != id {
            
            return false
        }
        
        if selector.cls.count > 0 && selector.cls.allSatisfy { !classes.contains($0) } {
            return false
        }
        
        return true
    }
    
    func isMatchSelector(_ selector: Selector) -> Bool {
        
        if case let .simple(sel) = selector {
            
            return isMatchSimpleSelector(sel)
        }
        
        return false
    }
}


typealias MatchedRule = (Specificity, Rule)

extension ElementData {
    
    func matchRule(_ rule: Rule) -> MatchedRule? {
        
        return rule.selectors
            .first { isMatchSelector($0) }
            .map { ($0.specificity, rule) }
    }
    
    func matchRules(_ stylesheet: StyleSheet) -> [MatchedRule] {
        
        return stylesheet.rules.compactMap { matchRule($0) }
    }
    
    func specifiedValues(stylesheet: StyleSheet) -> PropertyMap {
        
        var values = [String: Value]()
        var rules = matchRules(stylesheet)
        rules.sort { specificityToUInt32($0.0) > specificityToUInt32($1.0) }
        
        rules.forEach {
            $0.1.declarations.forEach {
                values[$0.name] = $0.value
            }
        }
        return values
    }
}

public extension StyledNode {
    
    func value(forName name: String) -> Value? {
        
        return specifiedValues[name]
    }
    
    func lookup(_ name: String, _ fallback: String, _ defaultValue: Value) -> Value {
        
        return (value(forName: name) ?? value(forName: fallback)) ?? defaultValue
    }
}
