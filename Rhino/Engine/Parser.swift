//
//  Parser.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation

public class Parser {
    
    /// current position
    var pos: Int = 0
    /// source code
    var input: String
    ///
    var startIndex: String.Index {
        return input.index(input.startIndex, offsetBy: self.pos)
    }
    /// is current position end of file
    var eof: Bool {
        return pos >= input.count
    }
    
    public init(input: String) {
        self.input = input
    }
}


public extension Parser {
    
    
    func startWith(_ str: String) -> Bool {
        
        return input[startIndex...].hasPrefix(str)
    }
    
    func nextChar() -> Character {
        
        return input[self.pos]
    }
    
    
    @discardableResult
    func consumeChar() -> Character {
        
        defer {
            pos += 1
        }
        return input[pos]
    }
    
    
    func consumeWhiteSpace() {
        consumeWhile { $0.isWhitespace }
    }
    
    @discardableResult
    func consumeWhile(_ test: (Character) -> Bool) -> String {
        
        var chars = [Character]()
        while !eof && test(nextChar()) {
            
            chars.append(consumeChar())
        }
        return String(chars)
    }
}
