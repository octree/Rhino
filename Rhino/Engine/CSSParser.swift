//
//  CSSParser.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation

public class CSSParser: Parser {
    
    public static func parse(_ css: String) -> StyleSheet {
        
        return StyleSheet(rules: CSSParser(input: css).parseRules())
    }
    
    private func parseRules() -> [Rule] {
        
        var rules = [Rule]()
        
        while true {
            consumeWhiteSpace()
            if self.eof {
                break
            }
            rules.append(parseRule())
        }
        
        return rules
    }
    
    private func parseRule() -> Rule {
        
        return Rule(selectors: parseSelectors(), declarations: parseDeclarations())
    }
    
    private func parseSelectors() -> [Selector] {
        
        var sels = [Selector]()
        
        while true {
            
            sels.append(.simple(parseSimpleSelector()))
            consumeWhiteSpace()
            let ch = nextChar()
            if ch == "," {
                
                consumeChar()
                consumeWhiteSpace()
            } else if ch == "{" {
                
                break
            } else {
                fatalError("Unexpected character \(ch) in selector list")
            }
        }
        
        sels.sort {
            specificityToUInt32($0.specificity) > specificityToUInt32($1.specificity)
        }
        return sels
    }
    
    private func parseSimpleSelector() -> SimpleSelector {
        
        var selector = SimpleSelector(tagName: nil, id: nil, cls: [])
        
        loop:
            while !self.eof {
                if validIdentifierChar(self.nextChar()) {
                    selector.tagName = parseIdentifier()
                    continue;
                }
                switch self.nextChar() {
                case "#":
                    consumeChar()
                    selector.id = parseIdentifier()
                case ".":
                    consumeChar()
                    selector.cls.append(parseIdentifier())
                case "*":
                    consumeChar()
                default:
                    break loop
                }
        }
        return selector
    }
    
    private func parseDeclarations() -> [Declaration] {
        
        assert(consumeChar() == "{")
        var declarations = [Declaration]()
        while true {
            
            consumeWhiteSpace()
            if self.nextChar() == "}" {
                consumeChar()
                break
            }
            declarations.append(parseDeclaration())
        }
        return declarations
    }
    
    private func parseDeclaration() -> Declaration {
        
        let key = parseIdentifier()
        consumeWhiteSpace()
        assert(consumeChar() == ":")
        consumeWhiteSpace()
        let value = parseValue()
        consumeWhiteSpace()
        assert(consumeChar() == ";")
        return Declaration(name: key, value: value)
    }
    
    private func parseValue() -> Value {
        
        switch nextChar() {
        case "0"..."9":
            return parseLength()
        case "#":
            return parseColor()
        default:
            return .keyword(parseIdentifier())
        }
    }
    
    private func parseLength() -> Value {
        
        return .length(parseFloat(), parseUnit())
    }
    
    private func parseFloat() -> Double {
        
        let s = consumeWhile {
            ($0 >= "0" && $0 <= "9") ||
                $0 == "."
        }
        return Double(s)!
    }
    
   private func parseUnit() -> Unit {
        
        let id = parseIdentifier().lowercased()
        if id == "px" {
            
            return .px
        }
        fatalError("unrecognized unit")
    }
    
    private func parseColor() -> Value {
        
        assert(consumeChar() == "#")
        return .color(Color(r: parseHexPair(),
                            g: parseHexPair(),
                            b: parseHexPair(),
                            a: 255))
    }
    
    private func parseHexPair() -> UInt8 {
        
        let s = input[pos ..< (pos + 2)]
        defer {
            pos += 2
        }
        return UInt8(s, radix: 16)!
    }
    
    private func parseIdentifier() -> String {
        
        return consumeWhile(validIdentifierChar)
    }
    
}

private func validIdentifierChar(_ ch: Character) -> Bool {
    
    switch ch {
    case "a"..."z":
        return true
    case "A"..."Z":
        return true
    case "0"..."9":
        return true
    case "-":
        return true
    case "_":
        return true
    default:
        return false
    }
}
