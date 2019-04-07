//
//  HTMLParser.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation


public class HTMLParser: Parser {
    
    private func parseTagName() -> String {
        
        return consumeWhile {
            ($0 >= "a" && $0 <= "z") ||
                ($0 >= "A" && $0 <= "Z")
        }
    }
    
    private func parserNode() -> Node {
        
        if self.nextChar() == "<" {
            
            return parseElement()
        } else {
            
            return parseText()
        }
    }
    
    private func parseText() -> Node {
        
        return Node(text: consumeWhile { $0 != "<" })
    }
    
    private func parseElement() -> Node {
        
        assert(consumeChar() == "<")
        let tagName = parseTagName()
        let attrs = parseAttributes()
        assert(consumeChar() == ">")
        let children = parseNodes()
        assert(consumeChar() == "<")
        assert(consumeChar() == "/")
        assert(parseTagName() == tagName)
        assert(consumeChar() == ">")
        return Node(name: tagName, attrMap: attrs, children: children)
    }
    
    private func parseNodes() -> [Node] {
        
        var nodes = [Node]()
        while true {
            consumeWhiteSpace()
            if eof || startWith("</") {
                break
            }
            nodes.append(parserNode())
        }
        return nodes
    }
    
    private func parseAttribute() -> (String, String) {
        
        let key = parseAttributeKey()
        assert(consumeChar() == "=")
        let value = parseAttributeValue()
        return (key, value)
    }
    
    private func parseAttributeKey() -> String {
        
        return parseTagName()
    }
    
    private func parseAttributeValue() -> String {
        
        let openQuote = consumeChar()
        assert(openQuote == "\"" || openQuote == "'")
        let value = consumeWhile { $0 != openQuote }
        assert(consumeChar() == openQuote)
        return value
    }
    
    private func parseAttributes() -> AttributeMap {
        
        var attributes = AttributeMap()
        
        while true {
            consumeWhiteSpace()
            if nextChar() == ">" {
                break
            }
            let (k, v) = parseAttribute()
            attributes[k] = v
        }
        return attributes
    }
    
    public func parse(_ text: String) -> Node {
        
        let nodes = parseNodes()
        
        if nodes.count == 1 {
            
            return nodes[0]
        } else {
            return Node(name: "html", attrMap: [:], children: nodes)
        }
    }
}
