//
//  Dom.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation


/// Dom 属性
/// eg：<div id="container" class="row xxx"></div>
///    ["class": "row xxx", "id": "container", ...]
public typealias AttributeMap = [String: String]

public struct ElementData {
    
    public var tagName: String
    public var attributes: AttributeMap
}

public enum NodeType {
    // 文本
    case text(String)
    // 标签
    case element(ElementData)
}


public struct Node {
    /// 子节点
    public var children: [Node]
    /// 节点类型
    public var nodeType: NodeType
}

public extension Node {
    
    /// 初始化文本 Node
    ///
    /// - Parameter text: content
    init(text: String) {
        
        self.init(children: [], nodeType: .text(text))
    }
    
    
    /// 初始化标签 Node
    ///
    /// - Parameters:
    ///   - name: tag name
    ///   - attrMap: attributes map
    ///   - children: children
    init(name: String, attrMap: AttributeMap, children: [Node]) {
        
        let element = ElementData(tagName: name, attributes: attrMap)
        let nodeType = NodeType.element(element)
        self.init(children: children, nodeType: nodeType)
    }
}

extension Node {
    
    private func prettyPrint(indentation: String) -> String {
        var content = ""
        switch nodeType {
        case .element(let data):
            content += indentation + "<\(data.tagName)>"
            let attr = data.attributes.map {
                $0.key + ": " + $0.value
                }.joined(separator: ", ")
            content += "{\(attr)}\n"
        case .text(let text):
            content += indentation + "<Text>\(text)\n"
        }
        if children.count > 0 {
            
            content += children.reduce("") {
                $0 + $1.prettyPrint(indentation: indentation + "  ")
            }
        }
        return content
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        
        return prettyPrint(indentation: "")
    }
}




public extension ElementData {
    
    var id: String? {
        
        return attributes["id"]
    }
    
    var classes: Set<String> {
        
        let classText = attributes["class"] ?? ""
        let arr = classText.components(separatedBy: .whitespacesAndNewlines)
        return Set(arr.filter { $0.count > 0 })
    }
}
